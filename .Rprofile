# Renv settings
Sys.setenv(
    RENV_CONFIG_STARTUP_QUIET = TRUE,
    RENV_CONFIG_SYNCHRONIZED_CHECK = FALSE,
    RENV_PATHS_RENV = file.path("utils/renv"),
    RENV_PATHS_LOCKFILE = file.path("utils/proj_settings/renv.lock")
)
source("utils/renv/activate.R")

# Pal settings
# TODO: The default of pal is Anthropic, for setting model see:
# https://simonpcouch.github.io/pal/articles/pal.html#choosing-a-model
# Keep prompts in this directory to ensure completeness and ease of modification
options(.pal_dir = "utils/pal_prompts")

# Gander settings
#options(.gander_style = "Use tidyverse style and,when relevant, tidyverse packages. For example, when asked to plot something, use ggplot2, or when asked to transform data, using dplyr and/or tidyr unless explicitly instructed otherwise. Ensure your code is self-documenting so use appropriately named helper variables. Return a r-quarto block when only given text and only code when give code.")

# Trigger load
if (interactive() && file.exists("00_setup.R")) {
    # prompt of readline doesn't work from Rrofile
    message("Setup script detected. Run 00_setup.R? (press ENTER to run, ESC to skip):")
    response <- readline(" ")
    if (tolower(response) == "" || tolower(response) == "y") {
        source("00_setup.R")
    }
    rm(response)
}
