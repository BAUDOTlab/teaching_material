#!/usr/bin/env bash
# Fix Ubuntu 24.04 (Noble) AppArmor/dhclient vs NetworkManager path mismatch.
# See: LP #2083017, #2116733 — nm-dhcp-helper moved to /usr/libexec/
set -euo pipefail

PROFILE=/etc/apparmor.d/sbin.dhclient
BACKUP="/etc/apparmor.d/sbin.dhclient.bak.$(date +%Y%m%d%H%M%S)"

if ! grep -q '/usr/libexec/nm-dhcp-helper' "$PROFILE"; then
  cp -a "$PROFILE" "$BACKUP"
  echo "Backed up profile to $BACKUP"

  # Allow dhclient to exec the new helper path
  sed -i \
    '/\/usr\/lib\/NetworkManager\/nm-dhcp-helper[[:space:]]*Pxrm,/a\  \/usr\/libexec\/nm-dhcp-helper                     Pxrm,\n  signal (receive) peer=\/usr\/libexec\/nm-dhcp-helper,' \
    "$PROFILE"

  # Allow reading /etc/hostid (also denied in logs)
  if ! grep -q '/etc/hostid' "$PROFILE"; then
    sed -i '/# Site-specific additions/i\  \/etc\/hostid r,\n' "$PROFILE"
  fi

  # Add a dedicated profile for the libexec helper (mirrors the old path block)
  if ! grep -q '^/usr/libexec/nm-dhcp-helper {' "$PROFILE"; then
    cat >>"$PROFILE" <<'EOF'

/usr/libexec/nm-dhcp-helper {
  #include <abstractions/base>
  #include <abstractions/dbus>
  /usr/libexec/nm-dhcp-helper mr,

  /run/NetworkManager/private-dhcp rw,
  signal (send) peer=/sbin/dhclient,

  /var/lib/NetworkManager/*lease r,
  signal (receive) peer=/usr/sbin/NetworkManager,
  ptrace (readby) peer=/usr/sbin/NetworkManager,
  network inet dgram,
  network inet6 dgram,
}
EOF
  fi
  echo "Updated $PROFILE"
else
  echo "Profile already mentions /usr/libexec/nm-dhcp-helper — skipping edit"
fi

# Prefer Wi-Fi powersave off (helps Intel iwlwifi DHCP reliability)
if [[ -f /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf ]]; then
  tee /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf >/dev/null <<'EOF'
[connection]
wifi.powersave = 2
EOF
fi

# Prefer ISC dhclient under NetworkManager (matches the AppArmor fix above)
tee /etc/NetworkManager/conf.d/dhcp-client.conf >/dev/null <<'EOF'
[main]
dhcp=dhclient
EOF

apparmor_parser -r "$PROFILE"
systemctl restart NetworkManager
sleep 2

echo
echo "=== Verifying helper path is allowed ==="
grep -n 'libexec/nm-dhcp-helper' "$PROFILE" || true
echo
echo "Reconnect Wi-Fi, then check:"
echo "  ip -br addr show <iface>   # e.g. wlp2s0f0"
echo "  ping -4 -c 2 1.1.1.1"
