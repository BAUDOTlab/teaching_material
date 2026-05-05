# fastest way to install R packages for Linux, as pre-compiled tarballs
options(
  repos = c(
    CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest"
  )
)

# ensure in VS Code debugger that wecan properly view, and debug, R plots and datasets
if (Sys.getenv("VSCODE_DEBUG_SESSION") == "1") {
  Sys.setenv(TERM_PROGRAM = "vscode")
  source(file.path(
    Sys.getenv(if (.Platform$OS.type == "windows") "USERPROFILE" else "HOME"),
    ".vscode-R",
    "init.R"
  ))
}
