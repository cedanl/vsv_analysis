# Library's --------------------------------------------------------------------
library(tidyverse)

# VSV normen inlezen -----------------------------------------------------------
VSVnormen <- read_csv2(here::here("data","VSV_normen.csv"),
                       na = "NULL") |>
  mutate(NormDUOVSV = NormDUOVSV/1000) |>
  suppressMessages()

# CSV bestanden inlezen --------------------------------------------------------


# Starterset bestand maken -----------------------------------------------------


# Starterset
# NRSP bestand inlezen met bestandsnaam als kolom BESTANDSNAAM
bestanden <- c(list.files( path="C:/Users/s.kalkers/Graafschap College/M-Magister beheer - VSV/2022", full.names=TRUE ),
               list.files( path="C:/Users/s.kalkers/Graafschap College/M-Magister beheer - VSV/2023", full.names=TRUE ),
               list.files( path="C:/Users/s.kalkers/Graafschap College/M-Magister beheer - VSV/2024", full.names=TRUE ),
               list.files( path="C:/Users/s.kalkers/Graafschap College/M-Magister beheer - VSV/2025", full.names=TRUE ))


NRSP_totaal <- fs::fs_path(bestanden[grep("NRSP", bestanden)]) %>% 
  set_names(x = ., nm = .) |>
  map_dfr(read_csv2, .id = "BESTANDSNAAM" ) |>
  mutate(BESTANDSNAAM = str_sub(BESTANDSNAAM, start = -18, end = -1)) |>
  rename (BURGERSERVICENUMMER = `#BURGERSERVICENUMMER`) |>
  # Gelijk maken aan DPO tabellen  
  mutate(
    DatumRapportage = case_when(
      grepl("VI", BESTANDSNAAM) ~ ymd(paste0(as.integer(substr(BESTANDSNAAM, 5, 8)) + 1, "-03-01")),
      grepl("DI", BESTANDSNAAM) ~ ymd(paste0(as.integer(substr(BESTANDSNAAM, 5, 8)) + 1, "-11-01"))
    ),
    Peildatum1Okt = ymd(paste0(as.integer(substr(BESTANDSNAAM, 5, 8)) - 1, "-10-01")),
    Peildatum30sep = ymd(paste0(as.integer(substr(BESTANDSNAAM, 5, 8)) - 1, "-09-30")),
    KoppelNummer = as.character(ifelse(BURGERSERVICENUMMER == 0, ONDERWIJSNUMMER, BURGERSERVICENUMMER)),
    RapportageMaand = case_when(
      grepl("VI", BESTANDSNAAM) ~ "16-NenR-V",
      grepl("DI", BESTANDSNAAM) ~ "17-NenR-D"
    ),
    Teljaar = paste0(as.integer(substr(BESTANDSNAAM, 5, 8)) - 1, "-", substr(BESTANDSNAAM, 5, 8)),
    Volgnummer = NA,
    Bestand = case_when(
      grepl("VI", BESTANDSNAAM) ~ "NRSP-V",
      grepl("DI", BESTANDSNAAM) ~ "NRSP-D"
    ),
    Duo_Gemeentecode = as.character(GEMCODE),
    Duo_RMC_regio = as.character(RMC_REGIO),
    RAPPORTAGE_MAAND = NA,
    #Deze kolommen bevat het DPO bestand niet:
    Geboortedatum = as.Date(as.character(GEBOORTEDATUM), format = "%Y%m%d"),
    #Geboortedatum = dmy(GEBOORTEDATUM),
    Postcode = as.character(POSTCODE_CIJFERS),
    Woongemeente = NA, 
    Woonplaats = NA,
    Niveau_num = as.integer(ifelse(regmatches(NIVEAU, gregexpr("[0-9]+", NIVEAU)) == 0, NA, regmatches(NIVEAU, gregexpr("[0-9]+", NIVEAU)))),
    Indicatie_startkwalificatie = NA
  ) |>
  select(#Rapportage_Maand = RAPPORTAGE_MAAND, 
        Bestandsnaam = BESTANDSNAAM, RapportageMaand, DatumRapportage, Peildatum1Okt, Peildatum30sep, Crebocode = CREBO, KoppelNummer, RapportageMaand, Teljaar, Leerweg = ONDERWIJSSOORT, 
         Volgnummer, 
         Bestand, Duo_Gemeentecode, Duo_RMC_regio,
         #Deze kolommen bevat het DPO bestand niet:
         CreboOmschrijving = CREBO_OMSCHRIJVING, GemeenteNaam = GEMEENTENAAM, Geslacht = GESLACHT, Geboortedatum, Woongemeente, Woonplaats,
         PostcodeCijfers = POSTCODE_CIJFERS, Postcode,
         Niveau = NIVEAU, OnderwijsSoort = ONDERWIJSSOORT, Indicatie_startkwalificatie, Duo_RMC_regioNaam = RMC_REGIO_NAAM, BRIN,
         OnderwijsAanbieder_Code = ONDERWIJSAANBIEDER_CODE, Sector = ONDERWIJSAANBIEDER_NAAM,
         #OnderwijsAanbieder_Naam = ONDERWIJSAANBIEDER_NAAM, 
         OnderwijsLocatie_Code = ONDERWIJSLOCATIE_CODE, OnderwijsLocatie_Postcode = ONDERWIJSLOCATIE_POSTCODE,
         Niveau_num
  )  |>
  suppressMessages()


# Totaal A05 bestand maken
# Dit wordt de basis voor het A05 bestand:
A05_totaal <- fs::fs_path(bestanden[grep("A05", bestanden)]) %>% 
  set_names(x = ., nm = .) |>
  map_dfr(read_csv2, .id = "BESTANDSNAAM" ) |>
  mutate(BESTANDSNAAM = str_sub(BESTANDSNAAM, start = -18, end = -1)) |>
#A05_totaal <- bestanden[grep("A05", bestanden)] |> 
#  map_dfr( read_csv2 ) |> 
  rename (BRIN = `#BRIN`,
          Leerweg = LEERWEG,
          Crebocode = `ILT/CREBO`,
          #KoppelNummer = BSN_ONDERWIJSNR,
          Duo_RMC_regio = RMC_REGIO) |>
  mutate(
    DatumRapportage = ymd(paste0(RAPPORTAGE_MAAND, "01")),
    Peildatum1Okt = ymd(ifelse(as.integer(substr(RAPPORTAGE_MAAND, 5, 6)) %in% 10:12,
                               paste0(substr(RAPPORTAGE_MAAND, 1, 4), "-10-01"),
                               paste0(as.integer(substr(RAPPORTAGE_MAAND, 1, 4)) - 1, "-10-01"))),
    Peildatum30sep = ymd(ifelse(as.integer(substr(RAPPORTAGE_MAAND, 5, 6)) %in% 10:12,
                                paste0(substr(RAPPORTAGE_MAAND, 1, 4), "-09-30"),
                                paste0(as.integer(substr(RAPPORTAGE_MAAND, 1, 4)) - 1, "-09-30"))),
    RapportageMaand = case_when(
      substr(RAPPORTAGE_MAAND, 5, 6) == "10" ~ "1-Oktober",
      substr(RAPPORTAGE_MAAND, 5, 6) == "11" ~ "2-November",
      substr(RAPPORTAGE_MAAND, 5, 6) == "12" ~ "3-December",
      substr(RAPPORTAGE_MAAND, 5, 6) == "01" ~ "4-Januari",
      substr(RAPPORTAGE_MAAND, 5, 6) == "02" ~ "5-Februari",
      substr(RAPPORTAGE_MAAND, 5, 6) == "03" ~ "6-Maart",
      substr(RAPPORTAGE_MAAND, 5, 6) == "04" ~ "7-April",
      substr(RAPPORTAGE_MAAND, 5, 6) == "05" ~ "8-Mei",
      substr(RAPPORTAGE_MAAND, 5, 6) == "06" ~ "9-Juni",
      substr(RAPPORTAGE_MAAND, 5, 6) == "07" ~ "10-Juli",
      substr(RAPPORTAGE_MAAND, 5, 6) == "08" ~ "11-Augustus",
      substr(RAPPORTAGE_MAAND, 5, 6) == "09" ~ "12-September"
    ),
    Teljaar = ifelse(as.integer(substr(RAPPORTAGE_MAAND, 5, 6)) %in% 10:12,
                     paste0(substr(RAPPORTAGE_MAAND, 1, 4),
                            "-",
                            as.integer(substr(RAPPORTAGE_MAAND, 1, 4)) + 1),
                     paste0(as.integer(substr(RAPPORTAGE_MAAND, 1, 4)) - 1,
                            "-",
                            substr(RAPPORTAGE_MAAND, 1, 4))),
    Volgnummer = gsub("C", "", INSCHR_VLGNR),
    KoppelNummer = as.character(BSN_ONDERWIJSNR),
    Bestand = "A05",
    Duo_Gemeentecode = as.character(GEMCODE),
    
    #Deze kolommen bevat het DPO bestand niet:
    GemeenteNaam = "",
    Geslacht = "",
    #Geboortedatum = as.Date(GEBOORTEDATUM, format = "%d-%m-%Y"),
    Geboortedatum = dmy(GEBOORTEDATUM),
    PostcodeCijfers = as.integer(substr(POSTCODE, 1, 4)),
    OnderwijsSoort = "",
    Duo_RMC_regioNaam = "",
    Niveau_num = as.integer(ifelse(regmatches(NIVEAU, gregexpr("[0-9]+", NIVEAU)) == 0, NA, regmatches(NIVEAU, gregexpr("[0-9]+", NIVEAU)))),
    Indicatie_startkwalificatie = INDICATIE_STARTKWALIFICATIE
  ) |>
  
  select(#Rapportage_Maand = RAPPORTAGE_MAAND, 
        Bestandsnaam = BESTANDSNAAM, RapportageMaand, DatumRapportage, Peildatum1Okt, Peildatum30sep, Crebocode, KoppelNummer,
         RapportageMaand, Teljaar, Leerweg, Volgnummer, Bestand, Duo_Gemeentecode, Duo_RMC_regio,
         #Deze kolommen bevat het DPO bestand niet:
         CreboOmschrijving = `ILT/CREBO_OMS`, GemeenteNaam, Geslacht, Geboortedatum, Woongemeente = WOONGEMEENTE, Woonplaats = WOONPLAATS,
         PostcodeCijfers, Postcode = POSTCODE,
         Niveau = NIVEAU, OnderwijsSoort, Indicatie_startkwalificatie, Duo_RMC_regioNaam, BRIN,
         OnderwijsAanbieder_Code = ONDERWIJSAANBIEDERCODE,Sector = ONDERWIJSAANBIEDER_NAAM, 
         OnderwijsLocatie_Code = ONDERWIJSLOCATIECODE, OnderwijsLocatie_Postcode = ONDERWIJSLOCATIE_POSTCODE,
         Niveau_num) |>
  suppressMessages()  


#RapportageMaand = 9 uit het A05 bestand wordt RapportageMaand 13-oktober
A05_dpo_13okt <- A05_totaal %>%
  filter(month(DatumRapportage) == 9) %>%
  mutate(RapportageMaand = "13-Oktober")


#RapportageMaand = 9 uit het A05 bestand wordt RapportageMaand 14-november
A05_dpo_14nov <- A05_totaal %>%
  filter(month(DatumRapportage) == 9) %>%
  mutate(RapportageMaand = "14-November")


#RapportageMaand = 9 uit het A05 bestand wordt RapportageMaand 15-december
A05_dpo_15dec <- A05_totaal %>%
  filter(month(DatumRapportage) == 9) %>%
  mutate(RapportageMaand = "15-December")


#Totaal bestand A05 maken
#Hier worden de databestand aan elkaar gekoppeld (UNION ALL in tsql):
A05_dpo_totaal <- bind_rows(A05_totaal,
                            A05_dpo_13okt,
                            A05_dpo_14nov,
                            A05_dpo_15dec,
                            NRSP_totaal)

#Normen koppplen aan totaal bestand A05 
#Hier worden de databestand aan elkaar gekoppeld (JOIN in tsql):
Starterset <- A05_dpo_totaal |>
  left_join(VSVnormen, 
            by = join_by(Niveau_num == Niveau, Teljaar == Teljaar)) |>
  mutate(VSV_ID = paste0(Teljaar, RapportageMaand, KoppelNummer))


# VSV bestand maken ------------------------------------------------------------



# VSV
# NRSP bestand inlezen met bestandsnaam als kolom BESTANDSNAAM
bestanden <- c(list.files( path="C:/Users/s.kalkers/Graafschap College/M-Magister beheer - VSV/2022", full.names=TRUE ),
               list.files( path="C:/Users/s.kalkers/Graafschap College/M-Magister beheer - VSV/2023", full.names=TRUE ),
               list.files( path="C:/Users/s.kalkers/Graafschap College/M-Magister beheer - VSV/2024", full.names=TRUE ),
               list.files( path="C:/Users/s.kalkers/Graafschap College/M-Magister beheer - VSV/2025", full.names=TRUE ))


NenR_totaal <-fs::fs_path(bestanden[grep("NenR", bestanden)]) %>% 
  set_names(x = ., nm = .) |>
  map_dfr(read_csv2, .id = "BESTANDSNAAM",
          col_types = "ccccccccccccccccccccccccccccc") |> 
  mutate(BESTANDSNAAM = str_sub(BESTANDSNAAM, start = -18, end = -1)) |>
  rename (BURGERSERVICENUMMER = `#BURGERSERVICENUMMER`) |>
  # Gelijk maken aan DPO tabellen  
  mutate(
    KoppelNummer = ifelse(BURGERSERVICENUMMER == 0, ONDERWIJSNUMMER, BURGERSERVICENUMMER),
    RapportageMaand = case_when(
      grepl("VI", BESTANDSNAAM) ~ "16-NenR-V",
      grepl("DI", BESTANDSNAAM) ~ "17-NenR-D"
    ),
    Teljaar = paste0(as.integer(substr(BESTANDSNAAM, 5, 8)) - 1, "-", substr(BESTANDSNAAM, 5, 8)),
    Duo_Reden_uitstroom = NA,
    Duo_Reden = NA,
    MeldingVerzuimloketWettelijk = NA,
    MeldingVerzuimloketNietWettelijk = NA,
    #Deze kolommen bevat het DPO bestand niet:
    Bekostigd = ifelse(EXAMEN == 'J' & is.na(IND_BEKOSTIGING), 0,
                       ifelse(IND_BEKOSTIGING == 'J' & is.na(EXAMEN), 1, 999))
  ) |>
  select(BestandsnaamVSV = BESTANDSNAAM,RapportageMaand, KoppelNummer, Teljaar, 
         Duo_Reden_uitstroom, Duo_Reden, MeldingVerzuimloketWettelijk, MeldingVerzuimloketNietWettelijk,
         #Deze kolommen bevat het DPO bestand niet:
         Bekostigd
  )  |>
  suppressMessages()



# Totaal A04 bestand maken
#Dit wordt de basis voor het A04 bestand:
A04_totaal <- fs::fs_path(bestanden[grep("A04", bestanden)]) %>% 
  set_names(x = ., nm = .) |>
  map_dfr(read_csv2, .id = "BESTANDSNAAM",
          col_types = "ccccccccccccccccccccccccccccccccccccccc") |>
  mutate(BESTANDSNAAM = str_sub(BESTANDSNAAM, start = -18, end = -1)) |>
# A04_totaal <- bestanden[grep("A04", bestanden)] |> 
#  map_dfr(read_csv2,
#          col_types = "ccccccccccccccccccccccccccccccccccccccc") |> 
  rename (
    KoppelNummer = PERSOONSGEBONDENNUMMER)|>
  mutate(
    RapportageMaand = case_when(
      substr(RAPPORTAGEMAAND, 5, 6) == "10" ~ "1-Oktober",
      substr(RAPPORTAGEMAAND, 5, 6) == "11" ~ "2-November",
      substr(RAPPORTAGEMAAND, 5, 6) == "12" ~ "3-December",
      substr(RAPPORTAGEMAAND, 5, 6) == "01" ~ "4-Januari",
      substr(RAPPORTAGEMAAND, 5, 6) == "02" ~ "5-Februari",
      substr(RAPPORTAGEMAAND, 5, 6) == "03" ~ "6-Maart",
      substr(RAPPORTAGEMAAND, 5, 6) == "04" ~ "7-April",
      substr(RAPPORTAGEMAAND, 5, 6) == "05" ~ "8-Mei",
      substr(RAPPORTAGEMAAND, 5, 6) == "06" ~ "9-Juni",
      substr(RAPPORTAGEMAAND, 5, 6) == "07" ~ "10-Juli",
      substr(RAPPORTAGEMAAND, 5, 6) == "08" ~ "11-Augustus",
      substr(RAPPORTAGEMAAND, 5, 6) == "09" ~ "12-September"
    ),
    Teljaar = case_when(
      as.integer(substr(RAPPORTAGEMAAND, nchar(RAPPORTAGEMAAND)-1, nchar(RAPPORTAGEMAAND))) %in% 10:12 ~ 
        paste0(substr(RAPPORTAGEMAAND, 1, 4), "-", as.integer(substr(RAPPORTAGEMAAND, 1, 4)) + 1),
      as.integer(substr(RAPPORTAGEMAAND, nchar(RAPPORTAGEMAAND)-1, nchar(RAPPORTAGEMAAND))) %in% 1:9 ~ 
        paste0(as.integer(substr(RAPPORTAGEMAAND, 1, 4)) - 1, "-", substr(RAPPORTAGEMAAND, 1, 4))
    ),
    Duo_Reden_uitstroom = REDEN_UITSTROOM,
    Duo_Reden = REDEN,
    MeldingVerzuimloketWettelijk = ifelse(MELDING_VERZUIM_WETTELIJK == 'J', 1, 0),
    MeldingVerzuimloketNietWettelijk = ifelse(MELDING_VERZUIM_NIET_WETTELIJK == 'J', 1, 0),
    
    #Deze kolommen bevat het DPO bestand niet:
    Bekostigd = NA
  ) |>
  
  select(BestandsnaamVSV = BESTANDSNAAM, RapportageMaand, KoppelNummer, Teljaar, 
         Duo_Reden_uitstroom, Duo_Reden, MeldingVerzuimloketWettelijk, MeldingVerzuimloketNietWettelijk,
         #Deze kolommen bevat het DPO bestand niet:
         Bekostigd
  ) |>
  suppressMessages()




# Totaal A14 bestand maken
# Dit wordt de basis voor het A04 bestand:

A14_totaal <- fs::fs_path(bestanden[grep("A14", bestanden)]) %>% 
  set_names(x = ., nm = .) |>
  map_dfr(read_csv2, .id = "BESTANDSNAAM",
          col_types = "ccccccccccccccccccccccccccccccccccccccc") |>
  mutate(BESTANDSNAAM = str_sub(BESTANDSNAAM, start = -18, end = -1)) |>
# A14_totaal <- bestanden[grep("A14", bestanden)] |> 
#  map_dfr(read_csv2,
#          col_types = "ccccccccccccccccccccccccccccccccccccccc") |> 
  rename (
    KoppelNummer = PERSOONSGEBONDENNUMMER
    ) |>
  mutate(
    RapportageMaand = case_when(
      substr(RAPPORTAGEMAAND, 5, 6) == "10" ~ "13-Oktober",
      substr(RAPPORTAGEMAAND, 5, 6) == "11" ~ "14-November",
      substr(RAPPORTAGEMAAND, 5, 6) == "12" ~ "15-December"
    ),
   Teljaar = paste0(as.integer(substr(RAPPORTAGEMAAND, 1, 4)) - 1,
                     "-",
                     substr(RAPPORTAGEMAAND, 1, 4)),
    Duo_Reden_uitstroom = REDEN_UITSTROOM,
    Duo_Reden = REDEN,
    MeldingVerzuimloketWettelijk = ifelse(MELDING_VERZUIM_WETTELIJK == 'J', 1, 0),
    MeldingVerzuimloketNietWettelijk = ifelse(MELDING_VERZUIM_NIET_WETTELIJK == 'J', 1, 0),
    
    #Deze kolommen bevat het DPO bestand niet:
    Bekostigd = NA
  ) |>
  
  select(BestandsnaamVSV = BESTANDSNAAM, RapportageMaand, KoppelNummer, Teljaar, 
         Duo_Reden_uitstroom, Duo_Reden, MeldingVerzuimloketWettelijk, MeldingVerzuimloketNietWettelijk,
         #Deze kolommen bevat het DPO bestand niet:
         Bekostigd
  ) |>
  suppressMessages() 



# Totaal bestand A04 maken
# Hier worden de databestand aan elkaar gekoppeld (UNION ALL in tsql):
VSV <- bind_rows(A04_totaal,
                 A14_totaal,
                 NenR_totaal) |>
  mutate(VSV = 1,
         VSV_ID = paste0(Teljaar, RapportageMaand, KoppelNummer)) 


# Totaalbestand maken van Starterset en VSV ------------------------------------

VSV_totaal <- Starterset |>
  left_join(VSV, 
            by = join_by(VSV_ID == VSV_ID, 
                         Teljaar == Teljaar,
                         RapportageMaand == RapportageMaand,
                         KoppelNummer == KoppelNummer)) |>
  mutate(VSV = ifelse(is.na(VSV), 0, VSV))


# Wegschrijven naar een andere map
write.csv(VSV_totaal, "C:/Users/s.kalkers/OneDrive - Graafschap College/Documenten/__Shirley/CEDA/Data_export_tbv_PowerBI/VSV_totaal.csv") |>
  suppressMessages()
