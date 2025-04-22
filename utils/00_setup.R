.onLoad <- function(libname, pkgname) {
    # Set clock for devtools::check() verify current time to pass
    Sys.setenv(R_CHECK_SYSTEM_CLOCK = 0)
}

source("utils/dev_functions.R")

platform <- get_platform()

if (platform == "macOS") {
    source("utils/install_mac_os_system_deps.R")
}

if (platform == "windows") {
    source("utils/install_windows_system_deps.R")
}

source("utils/manage_packages.R")

clear_script_objects(filepath = "utils/dev_functions.R")

load_all()
