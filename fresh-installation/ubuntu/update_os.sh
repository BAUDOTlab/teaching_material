#!/bin/bash
# Safer Ubuntu upgrade helper.
# Blocks kernel upgrades when any installed DKMS module fails to build for
# the running or newest boot kernel (e.g. webcam relays, NVIDIA, VirtualBox).
#
# Override only if you accept a broken DKMS stack:
#   sudo FORCE_KERNEL_UPGRADE=1 ./update_os.sh
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
FORCE_KERNEL_UPGRADE="${FORCE_KERNEL_UPGRADE:-0}"

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

wait_for_apt_locks() {
  local waited=0
  while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 \
     || fuser /var/lib/dpkg/lock >/dev/null 2>&1 \
     || fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do
    (( waited >= 300 )) && die "apt/dpkg locked for >5 minutes."
    echo "Waiting for apt/dpkg lock... (${waited}s)"
    sleep 5
    waited=$((waited + 5))
  done
}

check_space() {
  local avail_kb
  avail_kb=$(df -Pk / | awk 'NR==2 {print $4}')
  (( avail_kb < 524288 )) && die "/ has less than 512MiB free."
  df -h / /boot
}

# All DKMS modules present under /var/lib/dkms (excluding source trees).
list_dkms_modules() {
  local d
  [[ -d /var/lib/dkms ]] || return 0
  for d in /var/lib/dkms/*/; do
    [[ -d $d ]] || continue
    basename "$d"
  done
}

dkms_ok_for_kernel() {
  local mod=$1 ver=$2
  dkms status -m "$mod" -k "$ver" 2>/dev/null | grep -Eq 'installed|built'
}

# Non-zero if any installed DKMS module is missing/broken for kernel $1.
any_dkms_broken_for_kernel() {
  local ver=$1 mod broken=0
  while IFS= read -r mod; do
    [[ -n $mod ]] || continue
    if ! dkms_ok_for_kernel "$mod" "$ver"; then
      echo "DKMS module '${mod}' is NOT built/installed for ${ver}" >&2
      dkms status -m "$mod" 2>/dev/null || true
      broken=1
    fi
  done < <(list_dkms_modules)
  (( broken == 0 ))
}

newest_boot_kernel() {
  basename "$(readlink -f /boot/vmlinuz 2>/dev/null || true)" | sed 's/^vmlinuz-//'
}

kernel_packages_would_change() {
  apt-get -s dist-upgrade 2>/dev/null \
    | grep -E '^(Inst|Remv) linux-(image|headers|modules|generic)' \
    >/tmp/update_os_kernel_plan.$$ || true
  if [[ -s /tmp/update_os_kernel_plan.$$ ]]; then
    cat /tmp/update_os_kernel_plan.$$
    rm -f /tmp/update_os_kernel_plan.$$
    return 0
  fi
  rm -f /tmp/update_os_kernel_plan.$$
  return 1
}

hold_hwe_metapackages() {
  # Hold common HWE metapackages when present (ignore missing names).
  apt-mark hold \
    linux-generic-hwe-24.04 \
    linux-image-generic-hwe-24.04 \
    linux-headers-generic-hwe-24.04 \
    >/dev/null 2>&1 || true
  echo "Held HWE kernel metapackages where available."
}

refuse_unsafe_kernel_upgrade() {
  [[ $FORCE_KERNEL_UPGRADE == 1 ]] && {
    echo "FORCE_KERNEL_UPGRADE=1 — allowing kernel package changes."
    return 0
  }

  local mods
  mods=$(list_dkms_modules || true)
  [[ -z ${mods} ]] && return 0
  kernel_packages_would_change || {
    echo "No kernel package changes planned."
    return 0
  }

  echo >&2
  echo "Refusing kernel upgrade: DKMS modules are installed on this system." >&2
  echo "A new kernel is only safe when every DKMS module builds for it." >&2
  echo "Installed modules:" >&2
  echo "${mods}" >&2
  echo >&2
  echo "Options:" >&2
  echo "  1) Upgrade non-kernel packages only (recommended; HWE held)." >&2
  echo "  2) After DKMS builds for the new kernel:" >&2
  echo "       sudo FORCE_KERNEL_UPGRADE=1 $0" >&2
  hold_hwe_metapackages
  die "Kernel upgrade blocked because DKMS modules are present."
}

repair_missing_initramfs() {
  local k ver
  for k in /boot/vmlinuz-*-generic; do
    [[ -e $k ]] || continue
    ver=${k#/boot/vmlinuz-}
    if [[ ! -s /boot/initrd.img-${ver} ]]; then
      log "Building missing initramfs for ${ver}"
      update-initramfs -c -k "${ver}" || update-initramfs -u -k "${ver}" || true
    fi
  done
}

# ---------- main ----------
log "Pre-flight checks"
wait_for_apt_locks
check_space

if list_dkms_modules | grep -q .; then
  log "DKMS modules detected — kernel upgrades require a healthy DKMS build"
  dkms status 2>/dev/null || true
fi

log "Finishing any interrupted dpkg transactions"
dpkg --configure -a || true
apt-get -f install -y || true

log "apt-get update"
apt-get update

log "Simulating dist-upgrade for kernel / DKMS safety"
refuse_unsafe_kernel_upgrade

log "apt-get upgrade"
apt-get upgrade -y

log "apt-get dist-upgrade"
apt-get dist-upgrade -y

log "Post-upgrade: initramfs + DKMS"
dpkg --configure -a
apt-get -f install -y
repair_missing_initramfs
dkms autoinstall -k "$(uname -r)" || true

if list_dkms_modules | grep -q .; then
  if ! any_dkms_broken_for_kernel "$(uname -r)"; then
    :
  else
    hold_hwe_metapackages
    die "One or more DKMS modules failed for $(uname -r). Fix DKMS before changing the default kernel."
  fi
  newest=$(newest_boot_kernel)
  if [[ -n $newest && $newest != "$(uname -r)" ]]; then
    if ! any_dkms_broken_for_kernel "$newest"; then
      echo "Newest kernel ${newest} also has a healthy DKMS stack."
    else
      echo "WARNING: newest kernel ${newest} lacks a full DKMS stack — prefer $(uname -r) until fixed." >&2
      hold_hwe_metapackages
    fi
  fi
fi

update-grub || true

log "Cleanup"
apt-get autoremove -y
apt-get autoclean -y

log "Final status"
echo "Running kernel: $(uname -r)"
echo "apt holds:"; apt-mark showhold || true
dkms status 2>/dev/null || true
echo
echo "Upgrade finished."
