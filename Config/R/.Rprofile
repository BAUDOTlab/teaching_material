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
