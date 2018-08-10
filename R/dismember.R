#' Dismember data element into its distinct components
#'
#' @param df dataframe to adjust
#'
#' @export
#'

dismember <- function(df) {
  df %>% 
    dplyr::filter(!stringr::str_detect(dataelement, "(NARRATIVE|NGI|MOH|T_PSNU|NA,|NA\\))")) %>% 
    dplyr::mutate(disaggregate = stringr::str_extract(dataelement, "\\((.*?)\\)") %>% stringr::str_remove_all("^.*(DSD|TA), |\\)"),
                  disaggregate = ifelse(stringr::str_detect(disaggregate, "(DSD|TA)"), "Total Numerator", disaggregate),
                  indicator = stringr::str_extract(dataelement, "^.*\\(") %>% stringr::str_replace_all("\\(|\\s", ""),
                  numeratordenom = stringr::str_extract(dataelement, "\\((N|D),") %>% stringr::str_replace_all("\\(|,", ""),
                  indicatortype = stringr::str_extract(dataelement, "DSD|TA"),
                  resulttarget = ifelse(stringr::str_detect(dataelement, "TARGET"), "TARGET", "RESULT")) %>% 
    dplyr::select(org_unit, dataelement, indicator, disaggregate, numeratordenom, indicatortype, resulttarget, period, value)
}
  # dplyr::mutate(
  #   modality = stringr::str_replace(dataelement,"/", "!") %>% stringr::str_extract("^.*!") %>%  stringr::str_replace("!", ""),
  #   corecomp = stringr::str_replace(dataelement, ".*results ", "") %>% stringr::str_trim()
  # ) %>% 
  # tidyr::separate(corecomp, c("age", "sex", "resultsstatus"), sep = ",")  
