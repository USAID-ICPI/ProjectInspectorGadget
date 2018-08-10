#' Run an Analytics API call on DATIM
#'
#' @param url api url, after base url
#' @param baseurl default = "https://pisa.datim.org/"
#' @param extract what element of the json file do you want to use, rows, dataElement
#'
#' @export
#' @importFrom dplyr %>%
#'
pull_analytics <- function(url, baseurl = "https://pisa.datim.org/", extract = "rows"){
  
  #concatenate url
    full_url <- paste0(baseurl, url)
    
  #pull json
    json <- URLencode(full_url) %>%
      httr::GET(httr::timeout(60)) %>% 
      httr::content("text") %>% 
      jsonlite::fromJSON(flatten=TRUE) 
  
  #extract key elements
    df <- purrr::pluck(json, extract) %>% 
      tibble::as_tibble()
    
  if(extract == "rows"){
    #add column names extracted from json
    names(df) <- json$headers$column
    df <- df %>% 
      dplyr::rename(dataelement = Data,
                    org_unit = `Organisation unit`,
                    value = Value)
    #clean up 
    df <- df %>% 
      dplyr::mutate(value = as.numeric(value),                   #convert values from string to numeric
                    period = json$metaData$dimensions$pe) %>%    #add period in
      dplyr::select(org_unit, dataelement, period, value)        #reorder
    }
  
   return(df)
}