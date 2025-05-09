.onLoad <- function(libname, pkgname) {
    # Set clock for devtools::check() verify current time to pass
    Sys.setenv(R_CHECK_SYSTEM_CLOCK = 0)
}

source("utils/dev_functions.R")

platform <- get_platform()

if (platform == "macOS") {
    source("utils/install_mac_os_system_deps.R")
}

# TODO Only needed for dev-branch where packages need to be installed, rtools detection
# is buggy
# if (platform == "windows") {
#     source("utils/install_windows_system_deps.R")
# }

source("utils/manage_packages.R")

source("utils/set_rstudio_prefs.R")

load_all()

message("Render voor analyse: Totaalbestand maken van losse VSV bestanden.qmd")
# TODO Starting in R Studio works, interactive is more general, later on might need
# to verify if this works in VS Code / Positron etc
if (interactive() && rstudioapi::isAvailable()) {
    rstudioapi::navigateToFile("config.yml")
    rstudioapi::navigateToFile("Totaalbestand maken van losse VSV bestanden.qmd")
}

rm(list = ls())
