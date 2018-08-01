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
    api_hts <- dismember(api_hts) %>% 
      dplyr::select(org_unit, dataelement, indicator, disaggregate, numeratordenom, indicatortype, resulttarget, value)
    
  # Check #1
   
