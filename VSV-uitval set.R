WITH CTE_Basisset_duo AS (
  SELECT 
  DatumRapportage					= CAST(duo.RAPPORTAGE_MAAND+'01' AS DATE)
  ,Peildatum1Okt						= CAST(CONCAT(CASE WHEN CAST(RIGHT(duo.RAPPORTAGE_MAAND,2) AS INT) BETWEEN 10 AND 12 THEN LEFT(duo.RAPPORTAGE_MAAND,4)
                                    WHEN CAST(RIGHT(duo.RAPPORTAGE_MAAND,2) AS INT) BETWEEN 1 AND 9   THEN LEFT(duo.RAPPORTAGE_MAAND,4) -1 END
                                    ,'-10-01') AS DATE)
  ,Peildatum30sep						= CAST(CONCAT(CASE WHEN CAST(RIGHT(duo.RAPPORTAGE_MAAND,2) AS INT) BETWEEN 10 AND 12 THEN LEFT(duo.RAPPORTAGE_MAAND,4)
                                     WHEN CAST(RIGHT(duo.RAPPORTAGE_MAAND,2) AS INT) BETWEEN 1 AND 9   THEN LEFT(duo.RAPPORTAGE_MAAND,4) -1 END
                                     ,'-09-30') AS DATE)
  ,Crebocode							= duo.[ILT/CREBO]
  ,KoppelNummer						= duo.BSN_ONDERWIJSNR
  ,RapportageMaand					= CASE  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 10 THEN '1-Oktober'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 11 THEN '2-November'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 12 THEN '3-December'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 1  THEN '4-Januari'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 2  THEN '5-Februari'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 3  THEN '6-Maart'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 4  THEN '7-April'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 5  THEN '8-Mei'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 6  THEN '9-Juni'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 7  THEN '10-Juli'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 8  THEN '11-Augustus'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 9  THEN '12-September' END
  ,Teljaar							= CASE	WHEN CAST(RIGHT(duo.RAPPORTAGE_MAAND,2) AS INT) BETWEEN 10 AND 12 
  THEN CONCAT(LEFT(duo.RAPPORTAGE_MAAND,4) ,'-', LEFT(duo.RAPPORTAGE_MAAND,4) +1)
  WHEN CAST(RIGHT(duo.RAPPORTAGE_MAAND,2) AS INT) BETWEEN 1 AND 9   
  THEN CONCAT(LEFT(duo.RAPPORTAGE_MAAND,4)-1 ,'-', LEFT(duo.RAPPORTAGE_MAAND,4)) END
  ,Leerweg							= duo.LEERWEG
  ,MeldingVerzuimloketWettelijk		= CASE WHEN MELDING_VERZUIMLOKET_WETTELIJK = 'J' THEN 1 ELSE 0 END 
  ,MeldingVerzuimloketNietWettelijk	= CASE WHEN MELDING_VERZUIMLOKET_NIET_WETTELIJK = 'J' THEN 1 ELSE 0 END 
  ,Duo_Gemeentecode					= GEMCODE
  ,Duo_RMC_regio						= RMC_REGIO
  ,Duo_Reden_uitstroom				= REDEN_UITSTROOM
  ,Duo_Reden							= REDEN
  ,Volgnummer							= REPLACE(INSCHR_VLGNR , 'C', '')
  ,Bestand							= 'A04'
  ,ObjectConnectionId					= duo.OBJECTCONNECTIONID
  --FROM [s_duo].[A04] duo
  FROM Interface.s_duo_A04		duo
  
  UNION ALL 
  
  SELECT 
  DatumRapportage						= CAST(duo.RAPPORTAGE_MAAND+'01' AS DATE)
  ,Peildatum1Okt						= CAST(CONCAT(LEFT(duo.RAPPORTAGE_MAAND,4)-1,'-10-01') AS date)
  ,Peildatum30sep						= CAST(CONCAT(LEFT(duo.RAPPORTAGE_MAAND,4)-1,'-09-30') AS date)
  ,Crebocode							= duo.[ILT/CREBO]
  ,KoppelNummer						= duo.BSN_ONDERWIJSNR
  ,RapportageMaand					= CASE WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 10 THEN '13-Oktober'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 11 THEN '14-November'
  WHEN RIGHT(duo.RAPPORTAGE_MAAND,2) = 12 THEN '15-December' END
  ,Teljaar							= CONCAT(LEFT(duo.RAPPORTAGE_MAAND,4)-1,'-', LEFT(duo.RAPPORTAGE_MAAND,4))
  ,Leerweg							= duo.LEERWEG
  ,MeldingVerzuimloketWettelijk		= CASE WHEN MELDING_VERZUIMLOKET_WETTELIJK = 'J' THEN 1 ELSE 0 END 
  ,MeldingVerzuimloketNietWettelijk	= CASE WHEN MELDING_VERZUIMLOKET_NIET_WETTELIJK = 'J' THEN 1 ELSE 0 END 
  ,Duo_Gemeentecode					= GEMCODE
  ,Duo_RMC_regio						= RMC_REGIO
  ,Duo_Reden_uitstroom				= REDEN_UITSTROOM
  ,Duo_Reden							= REDEN
  ,Volgnummer							= REPLACE(INSCHR_VLGNR , 'C', '')
  ,Bestand							= 'A14'
  ,ObjectConnectionId			= duo.OBJECTCONNECTIONID
  --FROM [s_duo].[A14] duo
  FROM Interface.s_duo_A14		duo
  
  UNION ALL 
  
  SELECT 
  DatumRapportage						= CAST(CASE WHEN duo.BESTANDSNAAM LIKE '%VI%'
                              THEN CONCAT(SUBSTRING(duo.BESTANDSNAAM,5,4)+1,'-03-01')
                              WHEN duo.BESTANDSNAAM LIKE '%DI%' 
                              THEN CONCAT(SUBSTRING(duo.BESTANDSNAAM,5,4)+1,'-11-01') END AS DATE)
  ,Peildatum1Okt						= CAST(CONCAT(SUBSTRING(duo.BESTANDSNAAM,5,4)-1,'-10-01') AS date)
  ,Peildatum30sep						= CAST(CONCAT(SUBSTRING(duo.BESTANDSNAAM,5,4)-1,'-09-30') AS date)
  ,Crebocode							= duo.CREBO
  ,KoppelNummer						= CASE WHEN duo.#BURGERSERVICENUMMER = 0 THEN duo.ONDERWIJSNUMMER ELSE duo.#BURGERSERVICENUMMER END
  ,RapportageMaand					= CASE WHEN duo.BESTANDSNAAM LIKE '%VI%' THEN '16-NenR-V'
  WHEN duo.BESTANDSNAAM LIKE '%DI%' THEN '17-NenR-D' END 
  ,Teljaar							= CONCAT(SUBSTRING(duo.BESTANDSNAAM,5,4)-1,'-',SUBSTRING(duo.BESTANDSNAAM,5,4))
  ,Leerweg							= duo.ONDERWIJSSOORT
  ,MeldingVerzuimloketWettelijk		= NULL
  ,MeldingVerzuimloketNietWettelijk	= NULL
  ,Duo_Gemeentecode					= GEMCODE
  ,Duo_RMC_regio						= RMC_REGIO
  ,Duo_Reden_uitstroom				= NULL
  ,Duo_Reden							= NULL
  ,Volgnummer							= NULL
  ,Bestand							= CASE	WHEN duo.BESTANDSNAAM LIKE '%VI%' THEN 'NenR-V'
  WHEN duo.BESTANDSNAAM LIKE '%DI%' THEN 'NenR-D' END
  ,ObjectConnectionId					= duo.OBJECTCONNECTIONID
  --FROM [s_duo].[NenR] duo
  FROM Interface.s_duo_NenR		duo