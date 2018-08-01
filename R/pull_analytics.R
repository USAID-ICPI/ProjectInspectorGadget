#' Run an Analytics API call on DATIM
#'
#' @param url api url, after base url
#' @param baseurl default = "https://pisa.datim.org/"
#'
#' @export
#' @importFrom dplyr %>%
#'
pull_analytics <- function(url, baseurl = "https://pisa.datim.org/"){
  
  #concatenate url
    full_url <- paste0(baseurl, url)
    
  #pull json
    json <- URLencode(full_url) %>%
      httr::GET(timeout(60)) %>% 
      httr::content("text") %>% 
      jsonlite::fromJSON(flatten=TRUE) 
  
  #extract tabular data from json and convert values from string to numeric
  df <- tibble::as.tibble(json$rows) %>% 
    dplyr::mutate(Value = as.numeric(Value))
  
  names(df) <- json$headers$column
  
  return(df)
}