
open_config <- function() {
    config_path <- here::here("config.yml")
    if(requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
        rstudioapi::navigateToFile(config_path)
    } else {
        message("RStudio API is niet beschikbaar of bestand bestaat niet.")
    }
}

