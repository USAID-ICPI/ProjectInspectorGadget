#' Pull indicator data from DATIM
#'
#' @param ind indicator to pull down 
#' @param pd period to pull, eg "2018Q1" or multiple "2017Q4;2018Q1"
#' @param catopcomb like statement to match categoryoptioncombo, eg "Life-long%20ART,%20New"
#'
#' @export
#' @importFrom dplyr %>%

pull_ind <- function(ind, pd = "2018Q1", catopcomb = NULL){
  
  #add indicator to dataElements url to identify full list of uids to pull
  if(is.null(catopcomb)){
    deurl <- paste0("api/dataElements?paging=false&filter=name:like:", ind)
    ext <- "dataElements"
  } else {
    deurl <- paste0("api/dataElementOperands?paging=false&filter=name:like:", catopcomb)
    ext <- "dataElementOperands"
  }
  #use URL to pull relevant indicator UIDS and combine in list
    lst_ind_uids <- 
      pull_analytics(deurl, extract = ext) %>% 
      dplyr::filter(stringr::str_detect(displayName, paste0(ind," \\(N, (DSD|TA)")), !stringr::str_detect(displayName, "(NARRATIVE|NGI|MOH|T_PSNU|NA,|NA\\))")) %>% 
      dplyr::pull(id) %>% 
      paste0(collapse = ";")
  
  #use list to create pivot url
    pivoturl <- paste0("api/26/analytics.json?dimension=dx:", lst_ind_uids,"&dimension=ou:LEVEL-4;PqlFzhuPcF1&dimension=pe:", pd, "&displayProperty=NAME&outputIdScheme=NAME")
  
  #extract data from DATIM using url
    api_pull <- pull_analytics(pivoturl)
  
  #clean up data element
    api_pull <- dismember(api_pull) 

}