# Prefer Posit Package Manager binary builds for Ubuntu noble.
options(
  repos = c(
    CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest"
  )
)

# Bridge vscode-R / Cursor R debugger sessions to the vscode-R init hook.
if (Sys.getenv("VSCODE_DEBUG_SESSION") == "1") {
  Sys.setenv(TERM_PROGRAM = "vscode")
  source(file.path(
    Sys.getenv(if (.Platform$OS.type == "windows") "USERPROFILE" else "HOME"),
    ".vscode-R",
    "init.R"
  ))
}

# Skip the NIST clock check during R CMD check.
# Note: `R CMD check` runs with --vanilla, so this only helps when you call
# check from an R session that already sourced this file (e.g. remotes::check).
# For shell `R CMD check`, export in ~/.zshrc or the workflow env instead:
#   export _R_CHECK_SYSTEM_CLOCK_=FALSE
Sys.setenv("_R_CHECK_SYSTEM_CLOCK_" = "FALSE")

# AutoZyme (https://autozyme.com/docs/users/usage-guide/): installed but OFF
# by default. Wrappers still honour AUTOZYME_DISABLED / is_disabled() at call
# time (see §6 Turn it off). Flip the option when you want speedups.
#
# Enable for this session, then activate patch families you need:
#   options(autozyme.disabled = FALSE)
#   Sys.unsetenv("AUTOZYME_DISABLED")
#   library(autozyme)
#   autozyme::list_patches(installed = TRUE)
#   autozyme::activate(c("seurat", "wgcna"))  # examples; see patch catalog
#
# Disable again:
#   options(autozyme.disabled = TRUE)
#   Sys.setenv(AUTOZYME_DISABLED = "1")
#   # or per-block:  autozyme::with_disabled({ ... })
#   # or per-patch:  autozyme::deactivate("seurat")
#   # or per-call:   fn(..., zyme = FALSE)  # where supported
options(autozyme.disabled = TRUE)
if (isTRUE(getOption("autozyme.disabled", TRUE))) {
  Sys.setenv(AUTOZYME_DISABLED = "1")
} else {
  Sys.unsetenv("AUTOZYME_DISABLED")
}
