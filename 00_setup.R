.onLoad <- function(libname, pkgname) {
    # Set clock for devtools::check() verify current time to pass
    Sys.setenv(R_CHECK_SYSTEM_CLOCK = 0)
}

source("utils/dev_functions.R")

old_lib_paths <- .libPaths()
.libPaths(c(user_lib, .libPaths()))
# pak is needed for renv, otherwise install it
if (!requireNamespace("pak", quietly = TRUE)) {
    install.packages("pak")
}
.libPaths(old_lib_paths)

source("utils/manage_packages.R")

load_all()
