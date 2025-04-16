.onLoad <- function(libname, pkgname) {
    # Set clock for devtools::check() verify current time to pass
    Sys.setenv(R_CHECK_SYSTEM_CLOCK = 0)
}

source("utils/dev_functions.R")
source("utils/manage_packages.R")

load_all()
