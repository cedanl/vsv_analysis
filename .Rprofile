# Renv settings
Sys.setenv(
    # To not distract beginner users
    RENV_CONFIG_STARTUP_QUIET = TRUE,
    RENV_PATHS_RENV = file.path("utils/renv"),
    RENV_PATHS_LOCKFILE = file.path("utils/proj_settings/renv.lock"),

    ## Renv settings
    RENV_INSTALL_STAGED = "FALSE",

    # Performance
    # RENV_CONFIG_PAK_ENABLED = TRUE, # Pak gives error with solving dependencies, so disabled
    RENV_CONFIG_INSTALL_JOBS = 4, # Pak does parallelization by default, so not needed

    # Specfic settings, renv is within setup scripts checked and synchronized if needed
    RENV_CONFIG_SYNCHRONIZED_CHECK = FALSE,

    # Ensure renv uses local library instead of cache (needed because renv::init() isn't run)
    RENV_PATHS_LIBRARY = file.path("utils/renv/library")
)

# More renv options
options(pkg.install.staged.warn = FALSE)
options(pkgType = "binary")

source("utils/renv/activate.R")


# Pal settings
# TODO: The default of pal is Anthropic, for setting model see:
# https://simonpcouch.github.io/pal/articles/pal.html#choosing-a-model
# Keep prompts in this directory to ensure completeness and ease of modification
options(.pal_dir = "utils/pal_prompts")


# TODO Set azure deployment, endpoints and api-key
# azure_deployment_id = "gpt-4o"
Sys.setenv(AZURE_OPENAI_ENDPOINT = "https://ceda-chatgpt-sweden.openai.azure.com",
           AZURE_OPENAI_DEPLOYMENT_ID = "03-mini"
)

if (requireNamespace("ellmer", quietly = TRUE)) {
    options(.gander_chat = ellmer::chat_azure(deployment_id = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_ID")))
    options(.pal_chat = ellmer::chat_azure(deployment_id = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_ID")))
}

# Gander settings
options(.gander_dims = c(0, 250))
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
