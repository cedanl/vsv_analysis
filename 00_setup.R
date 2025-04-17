.onLoad <- function(libname, pkgname) {
    # Set clock for devtools::check() verify current time to pass
    Sys.setenv(R_CHECK_SYSTEM_CLOCK = 0)
}

source("utils/dev_functions.R")

# pak is needed for renv, otherwise install it
if (!requireNamespace("pak", quietly = TRUE)) {
    print(user_lib)
    install.packages("pak", lib = user_lib)
}

source("utils/manage_packages.R")

load_all()
