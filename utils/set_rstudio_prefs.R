system_username <- tolower(Sys.getenv("USERNAME"))

rstudio_prefs_path <- paste0(
    "C:/Users/",
    system_username,
    "/AppData/Roaming/RStudio/rstudio-prefs.json"
)

prefs_content <- readLines(rstudio_prefs_path, warn = FALSE)

## check if rmd_chunk_output_inline in prefs_content
if (TRUE %in% grepl("rmd_chunk_output_inline", prefs_content)) {
    message(
        "The setting 'rmd_chunk_output_inline' already exists in rstudio-prefs.json."
    )
} else {
    ## add it to the file with standard value false
    message("The setting 'rmd_chunk_output_inline' is missing.")
    message(
        "Adding 'rmd_chunk_output_inline' with the default value (false) to rstudio-prefs.json."
    )
    updated_prefs_content <- gsub(
        "}",
        ",\n  \"rmd_chunk_output_inline\": false\n}",
        prefs_content
    )
    cat(updated_prefs_content, file = rstudio_prefs_path, sep = "\n")
    rm(updated_prefs_content)
}
