add_base_dates <- function(df) {
    df |>
        mutate(
            DatumRapportage = ymd(str_c(RAPPORTAGE_MAAND, "01")),
            month_num = as.integer(str_sub(RAPPORTAGE_MAAND, 5, 6))
        )
}

add_peildatums <- function(df) {
    df |>
        mutate(
            Peildatum1Okt = if_else(
                month_num %in% 10:12,
                ymd(str_c(str_sub(RAPPORTAGE_MAAND, 1, 4), "-10-01")),
                ymd(str_c(as.integer(str_sub(RAPPORTAGE_MAAND, 1, 4)) - 1, "-10-01"))
            ),
            Peildatum30sep = if_else(
                month_num %in% 10:12,
                ymd(str_c(str_sub(RAPPORTAGE_MAAND, 1, 4), "-09-30")),
                ymd(str_c(as.integer(str_sub(RAPPORTAGE_MAAND, 1, 4)) - 1, "-09-30"))
            )
        )
}

add_labels <- function(df, labels = month_labels, join_by = "month_num") {
    if (!is.null(labels)){
        df |>
            left_join(labels, by = join_by) |>
            rename(RapportageMaand = label)
    }
}

finalize_duo_data <- function(df) {

    standard_columns <- c(
        "DatumRapportage",
        "Peildatum1Okt",
        "Peildatum30sep",
        "Crebocode",
        "KoppelNummer",
        "RapportageMaand",
        "Teljaar",
        "Leerweg",
        "Volgnummer",
        "Bestand",
        "Duo_Gemeentecode",
        "Duo_RMC_regio"
    )

    df |>
        mutate(
            # TODO: Check if this simplification is correct
            Teljaar = year,
            # if_else(
            #     month_num %in% 10:12,
            #     str_c(str_sub(RAPPORTAGE_MAAND, 1, 4), "-",
            #           as.integer(str_sub(RAPPORTAGE_MAAND, 1, 4)) + 1),
            #     str_c(as.integer(str_sub(RAPPORTAGE_MAAND, 1, 4)) - 1, "-",
            #           str_sub(RAPPORTAGE_MAAND, 1, 4))
            # ),
            # TODO: It is generally considered bad practice to change variables
            # without renaming them
            Volgnummer = str_remove(Volgnummer, "C"),
            Duo_RMC_regio = ifelse(is.character(Duo_RMC_regio),
                                    parse_number(Duo_RMC_regio),
                                    Duo_RMC_regio)
        ) |>
        select(any_of(standard_columns))
}

add_nrsp_dates <- function(df) {
    df |>
        mutate(
            DatumRapportage = if_else(
                type == "VI",
                ymd(paste0(as.integer(year) + 1, "-03-01")),
                ymd(paste0(as.integer(year) + 1, "-11-01"))
            )
        )
}

prepare_nrsp_data <- function(df) {
    df |>
        mutate(
            RapportageMaand = if_else(type == "VI", "16-NenR-V", "17-NenR-D"),
            Bestand = if_else(type == "VI", "NRSP-V", "NRSP-D"),
            KoppelNummer = if_else(BURGERSERVICENUMMER == 0, ONDERWIJSNUMMER, BURGERSERVICENUMMER),
            Volgnummer = NA
        )
}
