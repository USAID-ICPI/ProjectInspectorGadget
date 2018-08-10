#' Pull indicator data from DATIM
#'
#' @param ind indicator to pull down 
#'
#' @export
#' @importFrom dplyr %>%

pull_ind <- function(ind){
  
  #add indicator to dataElements url to identify full list of uids to pull
    deurl <- paste0("api/dataElements?paging=false&filter=name:like:", ind)
    
  #use URL to pull relevant indicator UIDS and combine in list
    lst_ind_uids <- 
      pull_analytics(deurl, extract = "dataElements") %>% 
      dplyr::filter(stringr::str_detect(displayName, paste0(ind," \\(N, (DSD|TA)")), !stringr::str_detect(displayName, "(NARRATIVE|NGI|MOH|T_PSNU|NA,|NA\\))")) %>% 
      dplyr::pull(id) %>% 
      paste0(collapse = ";")
  
  #use list to create pivot url
    pivoturl <- paste0("api/26/analytics.json?dimension=dx:", lst_ind_uids,"&dimension=ou:LEVEL-4;PqlFzhuPcF1&filter=pe:2018Q1&displayProperty=NAME&outputIdScheme=NAME")
  
  #extract data from DATIM using url
    api_pull <- pull_analytics(pivoturl)
  
  #clean up data element
    api_pull <- dismember(api_pull) 

}