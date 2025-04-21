
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




#' Maak een staafdiagram van VSV-percentages per sector
#'
#' @param data Een dataframe met VSV-gegevens per sector
#' @param x_var De variabele voor de x-as (default: "Sector")
#' @param y_var De variabele voor de y-as (default: "Deel_VSV")
#' @param group_var De variabele voor groepering (default: "Teljaar")
#' @param label_var De variabele voor de labels op de staven (default: "Percentage_VSV")
#' @param achtergrond_kleur De achtergrondkleur van de plot (default: "seashell")
#' @param titel De titel van de plot (default: "Sector")
#' @param kleurenpalet Vector met kleuren voor de verschillende groepen (default: peachpuff-tinten)
#' @return Een ggplot-object
plot_titel_percentageVSV <- function(data,
                                      x_var = "Sector",
                                      y_var = "Deel_VSV",
                                      group_var = "Teljaar",
                                      label_var = "Percentage_VSV",
                                      achtergrond_kleur = "seashell",
                                      titel = "Sector",
                                      kleurenpalet = NULL) {

    # Controleer of verplichte kolommen bestaan in de data
    nodig_kolommen <- c(x_var, y_var, group_var, label_var)
    aanwezig_kolommen <- nodig_kolommen %in% names(data)

    if (!all(aanwezig_kolommen)) {
        stop(paste("Ontbrekende kolommen:",
                   paste(nodig_kolommen[!aanwezig_kolommen], collapse = ", ")))
    }

    # Bepaal unieke waardes in group_var voor kleurenpalet
    groep_waardes <- unique(data[[group_var]])

    # Standaard kleurenpalet als geen aangepast palet is opgegeven
    if (is.null(kleurenpalet)) {
        # Als er 4 of minder groepen zijn, gebruik peachpuff-tinten
        if (length(groep_waardes) <= 4) {
            kleurenpalet <- setNames(
                c("peachpuff1", "peachpuff2", "peachpuff3", "peachpuff4")[1:length(groep_waardes)],
                groep_waardes
            )
        } else {
            # Als er meer dan 4 groepen zijn, gebruik RColorBrewer
            kleurenpalet <- setNames(
                RColorBrewer::brewer.pal(min(length(groep_waardes), 9), "YlOrBr"),
                groep_waardes
            )
        }
    }

    # Bouw de plot
    p <- ggplot(data,
                aes_string(x = x_var,
                           y = y_var,
                           fill = group_var)) +
        geom_col(position = position_dodge(width = 0.8)) +
        geom_text(aes_string(label = label_var),
                  position = position_dodge(width = 0.8),
                  vjust = 1.2,
                  color = "#483E34",
                  fontface = "bold") +
        scale_fill_manual(values = kleurenpalet) +
        theme_minimal(base_family = "sans") +
        theme(
            plot.background = element_rect(fill = achtergrond_kleur),
            axis.text.y = element_blank(),
            legend.position = "top",
            legend.justification = "left"
        ) +
        labs(
            title = titel,
            x = NULL,
            y = NULL,
            fill = "Schooljaar"
        )

    return(p)
}




## Deze wordt nog niet gebruikt:

#' Bereken VSV-percentages per teljaar en sector voor een specifieke rapportagemaand
#'
#' @param data Een dataframe met VSV-gegevens
#' @param maand_var De naam van de kolom met rapportagemaanden (default: "RapportageMaand")
#' @param keuzemaand De geselecteerde rapportagemaand (default: NULL, gebruikt alle maanden)
#' @param vsv_var De naam van de kolom die aangeeft of iemand VSV is (default: "VSV")
#' @param groep_vars Vector met kolomnamen voor groepering, naast Teljaar en maand_var (default: "Sector")
#' @param accuracy De nauwkeurigheid voor percentages (default: 0.1)
#' @return Een dataframe met VSV-percentages per groep
#'
bereken_vsv_percentages <- function(data,
                                    maand_var = "RapportageMaand",
                                    keuzemaand = NULL,
                                    vsv_var = "VSV",
                                    groep_vars = "Sector",
                                    accuracy = 0.1) {

    # Controleer of vereiste kolommen bestaan
    vereiste_kolommen <- c("Teljaar", maand_var, vsv_var, groep_vars)
    aanwezig_kolommen <- vereiste_kolommen %in% names(data)

    if (!all(aanwezig_kolommen)) {
        stop(paste("Ontbrekende kolommen:",
                   paste(vereiste_kolommen[!aanwezig_kolommen], collapse = ", ")))
    }

    # Filter data op basis van keuzemaand indien opgegeven
    if (!is.null(keuzemaand)) {
        if (!(keuzemaand %in% unique(data[[maand_var]]))) {
            warning(paste("Keuzemaand", keuzemaand, "niet gevonden in data. Alle maanden worden gebruikt."))
        } else {
            data <- data %>% filter(!!sym(maand_var) == keuzemaand)
        }
    }

    # Zorg dat vsv_var een logische waarde is (TRUE/FALSE)
    if (!is.logical(data[[vsv_var]])) {
        # Als het geen logische waarde is, probeer te converteren van 0/1 of andere waarden
        if (all(na.omit(data[[vsv_var]]) %in% c(0, 1))) {
            data[[vsv_var]] <- as.logical(data[[vsv_var]])
        } else {
            warning("VSV variabele is niet logisch en kon niet automatisch worden geconverteerd")
        }
    }

    # Stel alle groepsvariabelen samen
    alle_groep_vars <- c("Teljaar", groep_vars, maand_var)

    # Bereken de VSV-statistieken
    result <- data %>%
        group_by(across(all_of(alle_groep_vars))) %>%
        summarise(
            Aantal_VSV = sum(!!sym(vsv_var), na.rm = TRUE),
            Aantal = n(),
            .groups = "drop"
        ) %>%
        mutate(
            Deel_VSV = Aantal_VSV / Aantal,
            Percentage_VSV = scales::percent(Deel_VSV, accuracy = accuracy)
        )

    return(result)
}
