library(tidyverse)
library(jsonlite)
library(httr)
library(datimvalidation)

loadSecrets()

baseurl <- "https://pisa.datim.org/"
url <- paste0(baseurl, "api/26/analytics.json?dimension=CKTkg8dLlr7:OxLSARiuCa8;KFZG3Lc0XgW;CeWDIASZw2r;YvO0x3N8iPk;qqV9vdPM2CB;QtnU6PoZwTj;mmef9WanhN1;jSX8elpqcD2;MZYo6lCaIhr;fTuReSq9mrJ;N3ZPt01yI74;UQJZLPV5BcW;Q8GqLayzQHh;sk2aTYKnZNz;y4f2Qs5jnv8;yQ9lXE1Sdm0&dimension=LxhLO68FcXm:f5IPTM7mieH&dimension=ou:LEVEL-3;PqlFzhuPcF1&filter=pe:2018Q1&displayProperty=SHORTNAME&skipMeta=false&hierarchyMeta=true")

api <-
  URLencode(url) %>%
  GET(.,timeout(60)) %>% 
  content(., "text") %>% 
  fromJSON(.,flatten=TRUE)

names(api)

test <- as.tibble(api$rows)

names(test) <- api$headers$column