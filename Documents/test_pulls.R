##   PROJECT INSPECTOR GADGET
##   A.Chafetz
##   Purpose: DATIM API pulls to conduct Nigeria's MER data validation
##   Date: 2018.08.01
##   Updated:


# Dependencies ------------------------------------------------------------

  library(devtools)
  library(magrittr)


# Load user information ---------------------------------------------------

  # baseurl: https://pisa.datim.org/
  datimvalidation::loadSecrets()

api_hts_tst <- pull_ind("HTS_TST")
api_tx_curr <- pull_ind("TX_CURR")
api_tx_new <- pull_ind("TX_NEW")
api_tx_new_targ <- pull_ind("TX_NEW", "THIS_FINANCIAL_YEAR") %>% 
  dplyr::filter(resulttarget == "TARGET")

pmtct_art_new <- pull_ind("PMTCT_ART", catopcomb = "Life-long%20ART,%20New")


# HTS - Validation --------------------------------------------------------

# - 1. Only one disaggregation type is used for Age/Sex/Result
# - 2. *Numerator = Sum of all modality (Excludes KP) 
# - 3. HTS_TST_POS = sum of HTS_TST_POS for each modality 
# - 4. All sites with targets reported results.
# - 5. Sites with results in previous quarters reported results this quarter (same FY)
# - 6. HTS _TST_POS (ANC) >= PMTCT_STAT (New Positives)

  #create list of all relevant HTS indicators to pull
    deurl <- "api/dataElements?paging=false&filter=name:like:HTS_TST"
    
    lst_hts <- 
      pull_analytics(deurl, extract = "dataElements") %>% 
      dplyr::filter(stringr::str_detect(displayName, "HTS_TST \\(N, (DSD|TA)\\):") | stringr::str_detect(displayName, "\\/(Age|Age Aggregated)\\/Sex\\/Result\\):")) %>% 
      dplyr::pull(id) %>% 
      paste0(collapse = ";")
    
    
  #HTS pivot table created in DATIM
    pivoturl <- paste0("api/26/analytics.json?dimension=dx:", lst_hts,"&dimension=ou:LEVEL-4;PqlFzhuPcF1&filter=pe:2018Q1&displayProperty=NAME&outputIdScheme=NAME")
    
  #HTS API pull
    api_hts <- pull_analytics(pivoturl)
  
  #clean up data element
    api_hts <- dismember(api_hts)
    
  # Check #1
   check1 <- api_hts %>% 
     dplyr::filter(disaggregate != "Total Numerator") %>% 
     dplyr::mutate(type = dplyr::case_when(stringr::str_detect(disaggregate, "Age Aggregated") ~ "Aggregated",
                                           stringr::str_detect(disaggregate, "Age")            ~ "Fine")) %>% 
     tidyr::spread()
                     

# TX_NEW - Validation -----------------------------------------------------


# 1. - *Numerator = Sum of Age/Sex disaggregation
# 2. - *TX_CURR >=TX_NEW
# 3. - TX_NEW (Preg/Feeding) = PMTCT_ART (newly initiating ART)
# 4. - All sites with targets reported results.
# 5. - Sites with results in previous quarters reported results this quarter (same FY)
# 6. - *Percent variance from previous quarter (Dramatic change between quarters can be a flag, but should also consider absolute difference as small changes to some results can be a large % difference)
# 7. - NET_NEW < = TX_NEW 
# 8. - NET_NEW Decreased (Neg) while TX_NEW Increased or remained high (Flag where this occurs)


  #Check #1   
    check1 <- api_tx_new %>% 
      dplyr::filter(disaggregate %in% c("HIVStatus", "Age/Sex/HIVStatus")) %>% 
      dplyr::mutate(type = dplyr::case_when(disaggregate == "Age/Sex/HIVStatus" ~ "Age/Sex",
                                            TRUE                                ~ "Numerator")) %>% 
      dplyr::select(org_unit, indicator, indicatortype, type, value) %>% 
      tidyr::spread(type, value) %>% 
      dplyr::mutate(tx_check1 = `Age/Sex` != Numerator) %>% 
      dplyr::filter(tx_check1 == TRUE)
    
  #Check #2
    grp <- list(api_tx_new, api_tx_curr)
    check2 <- 
      purrr::map_dfr(.x = grp, .f = ~ dplyr::filter(.x, disaggregate == "HIVStatus")) %>% 
      dplyr::select(-dataelement) %>% 
      tidyr::spread(indicator, value) %>% 
      dplyr::mutate(tx_check2 = TX_CURR <= TX_NEW) %>% 
      dplyr::filter(tx_check2 == TRUE)
    rm(grp)
    
  #Check #3
    #TODO
    
  #Check #4
    grp <- list(api_tx_new, api_tx_new_targ)
    check4 <- 
      purrr::map_dfr(.x = grp, .f = ~ dplyr::filter(.x, disaggregate %in%  c("HIVStatus", "Total Numerator"))) %>% 
      dplyr::select(-dataelement, -disaggregate) %>% 
      tidyr::spread(resulttarget, value) %>% 
      dplyr::mutate(tx_check4 = (is.na(RESULT) | RESULT == 0)) %>% 
      dplyr::filter(tx_check4 == TRUE)
    
    
    