.onLoad <- function(libname, pkgname) {
    # Set clock for devtools::check() verify current time to pass
    Sys.setenv(R_CHECK_SYSTEM_CLOCK = 0)
}

source("utils/dev_functions.R")

renv_lib_paths <- .libPaths()

# Set only user_lib to library path
assign(".lib.loc", user_lib, envir = environment(.libPaths))

print(.libPaths())
# pak is needed for renv, otherwise install it
if (!("pak" %in% rownames(installed.packages(lib.loc = user_lib)))) {
    install.packages("pak", lib = .libPaths())
}
.libPaths(renv_lib_paths)

source("utils/manage_packages.R")

load_all()
