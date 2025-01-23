
#' Read DUO File
#'
#' @description
#' Read and process a DUO (Dutch Education Executive Agency) data file
#'
#' @param filename A single string specifying the file to read
#'
#' @returns
#' A tibble containing the processed DUO data with standardized column names
#' and additional metadata columns extracted from the filename
#'
#' @importFrom readr read_csv2
#' @importFrom stringr str_glue str_c
#' @importFrom dplyr rename mutate
#'
#' @export
read_duo_file <- function(filename) {
    extracted_info <- extract_info_from_filename(filename)
    file_code <- extracted_info$file_code

    read_csv2(str_glue("data/synthetic/{file_code}/{filename}")) |>
        rename(
            Crebocode = ILT.CREBO,
            KoppelNummer = BSN_ONDERWIJSNR,
            Leerweg = LEERWEG,
            Volgnummer = INSCHR_VLGNR,
            Duo_Gemeentecode = GEMCODE,
            Duo_RMC_regio = RMC_REGIO
        ) |>
        mutate(
            year = extracted_info$year,
            RAPPORTAGE_MAAND = extracted_info$year |>
                str_c(extracted_info$month),
            Bestand = file_code,
            BRIN = extracted_info$brin
        )
}

read_nrsp_file <- function(filename) {
    info <- extract_info_from_nrsp_filename(filename)

    read_csv2(str_glue("data/synthetic/NRSP/{filename}")) |>
        rename(
            Crebocode = CREBO,
            Leerweg = ONDERWIJSSOORT,
            Duo_Gemeentecode = GEMCODE,
            Duo_RMC_regio = RMC_REGIO
        ) |>
        mutate(year = info$year,
               type = info$type)
}
