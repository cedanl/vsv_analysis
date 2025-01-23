


extract_info_from_filename <- function(filename) {
    patterns <- c(
        year = "\\d{4}",
        month = "\\d{2}",
        file_code = "[A-Z0-9]{3}",
        brin = "[A-Z0-9]{4}"
    )

    pattern <- paste0("(", patterns, ")", collapse = "")

    str_match(filename, pattern) |>
        as_tibble() |>
        select(-1) |>
        setNames(names(patterns))
}

extract_info_from_nrsp_filename <- function(filename) {
    # Extract year and VI/DI indicator
    year <- str_sub(filename, 5, 8)
    type <- if_else(str_detect(filename, "VI"), "VI", "DI")
    tibble(year = year, type = type)
}

