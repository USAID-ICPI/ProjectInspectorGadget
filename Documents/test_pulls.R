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

  #HTS pivot table created in DATIM
    pivoturl <- "api/26/analytics.json?dimension=dx:K6f6jR0NOcZ;FJSew4Ks0j3&dimension=ou:LEVEL-4;PqlFzhuPcF1&filter=pe:2018Q1&displayProperty=NAME&outputIdScheme=NAME"
  
  #HTS API pull
    api_hts <- pull_analytics(pivoturl)
