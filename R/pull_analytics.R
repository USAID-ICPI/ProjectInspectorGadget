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
      httr::GET(timeout(60)) %>% 
      httr::content("text") %>% 
      jsonlite::fromJSON(flatten=TRUE) 
  
  #extract key elements
    df <- purrr::pluck(extract)
    
  if(extract == "rows"){
    #extract tabular data from json and convert values from string to numeric
    df <- dplyr::mutate(df, Value = as.numeric(Value))
    #add column names extracted from json
    names(df) <- json$headers$column
  }
  
  return(df)
}