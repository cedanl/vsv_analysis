# Renv settings
Sys.setenv(
    # To not distract beginner users
    RENV_CONFIG_STARTUP_QUIET = TRUE,
    RENV_PATHS_RENV = file.path("utils/renv"),
    RENV_PATHS_LOCKFILE = file.path("utils/proj_settings/renv.lock"),

    ## Renv settings
    RENV_INSTALL_STAGED = "FALSE",

    # Performance
    RENV_CONFIG_PAK_ENABLED = TRUE, # Pak gives error with solving dependencies, so disabled
    RENV_CONFIG_INSTALL_JOBS = 4, # Pak does parallelization by default, so not needed

    # Specfic settings, renv is within setup scripts checked and synchronized if needed
    RENV_CONFIG_SYNCHRONIZED_CHECK = FALSE,

    # Ensure renv uses local library instead of cache (needed because renv::init() isn't run)
    RENV_PATHS_LIBRARY = file.path("utils/renv/library")
)

# More renv options
options(pkg.install.staged.warn = FALSE)
options(pkgType = "binary")
options(renv.config.install.binary = TRUE)

source("utils/renv/activate.R")

# Trigger load
if (interactive() && file.exists("utils/00_setup.R")) {
    # Safer cross-platform prompt approach
    message("Setup script detected. Run 00_setup.R? (press ENTER or 'y' to run, any other key to skip):")

    # Use tryCatch to handle potential readline errors
    response <- tryCatch({
        user_input <- readLines(n=1)
        if (length(user_input) == 0 || user_input == "") "" else user_input
    }, error = function(e) {
        message("Error reading input, defaulting to not run setup.")
        "n"
    })

    # Check if response is empty (ENTER) or starts with "y"
    if (response == "" || tolower(substr(response, 1, 1)) == "y") {
        message("Running setup script...")
        source("utils/00_setup.R")
    } else {
        message("Setup script skipped.")
    }
}

    # Check response and run if appropriate
    if (tolower(substr(response, 1, 1)) == "y") {
        message("Running setup script...")
        source("utils/00_setup.R")
    } else {
        message("Setup script skipped.")
    }
}
