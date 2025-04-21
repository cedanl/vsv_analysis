
open_config <- function() {
    config_path <- here::here("config.yml")
    if(requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
        rstudioapi::navigateToFile(config_path)
    } else {
        message("RStudio API is niet beschikbaar of bestand bestaat niet.")
    }
}




## Tabel sorteren en opmaak functie


#' Sorteer een tabel op maandnummer en andere kolommen
#'
#' @param data De dataframe die je wilt sorteren
#' @param maand_kolom De naam van de kolom met maandnamen (default: "RapportageMaand")
#' @param jaar_kolom De naam van de kolom met jaarnamen (default: "Teljaar")
#' @param bestandsnaam_kolom De naam van de kolom met bestandsnamen (default: "Bestandsnaam")
#' @return Een gesorteerde dataframe
sorteer_tabel <- function(data,
                          maand_kolom = "RapportageMaand",
                          jaar_kolom = "Teljaar",
                          bestandsnaam_kolom = "Bestandsnaam") {

    # Maak een hulpkolom om te sorteren op maandnummer
    data_sorted <- data %>%
        # Extraheer het maandnummer uit de maand_kolom
        mutate(MaandNummer = as.numeric(sub("(\\d+)-.+", "\\1", .data[[maand_kolom]]))) %>%
        # Sorteer op jaar_kolom, dan MaandNummer, dan bestandsnaam_kolom
        arrange(.data[[jaar_kolom]], MaandNummer, .data[[bestandsnaam_kolom]]) %>%
        # Verwijder de hulpkolom voor het tonen
        select(-MaandNummer)

    return(data_sorted)
}




#' Maak een gestylede datatable
#'
#' @param data De dataframe die je wilt weergeven
#' @param caption Titel voor de tabel (default: "Aantal leerlingen in Startpopulatie per ingelezen A05 bestand")
#' @param page_length Aantal rijen per pagina (default: 21)
#' @param achtergrond_kleur Achtergrondkleur voor oneven rijen (default: "seashell")
#' @param lettertype_kleur Kleur van de lettertypes (default: "#8B8682")
#' @param kolomnaam_kleur Kleur van de kolomnamen (default: "#8B8682")
#' @return Een DT::datatable object
maak_gestylede_datatable <- function(data,
                                     caption = "Aantal leerlingen in Startpopulatie per ingelezen A05 bestand",
                                     page_length = 21,
                                     achtergrond_kleur = "seashell",
                                     lettertype_kleur = "#8B8682",
                                     kolomnaam_kleur = "#8B8682") {

    DT::datatable(
        data,
        options = list(
            pageLength = page_length,
            dom = 'ft',
            ordering = TRUE,
            autoWidth = TRUE,
            search = list(regex = TRUE, caseInsensitive = TRUE),
            initComplete = DT::JS(
                sprintf(
                    "function(settings, json) {
            $(this.api().table().container()).css({'font-family': 'Arial, sans-serif', 'color': '%s'});
            $(this.api().columns().header()).css({'color': '%s'});
          }", lettertype_kleur, kolomnaam_kleur
                )
            ),
            rowCallback = DT::JS(
                sprintf(
                    "function(row, data, index) {
            if (index %% 2 === 0) {
              $(row).css({'background-color': 'white', 'color': '%s'});
            } else {
              $(row).css({'background-color': '%s', 'color': '%s'});
            }
          }", lettertype_kleur, achtergrond_kleur, lettertype_kleur
                )
            )
        ),
        rownames = TRUE,
        filter = 'top',
        class = 'cell-border',
        caption = htmltools::tags$caption(
            style = sprintf('caption-side: top; text-align: center; font-size: 20px; font-weight: bold; font-family: Arial, Helvetica, sans-serif; color: %s;', lettertype_kleur),
            caption
        )
    )
}


