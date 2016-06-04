sanitizexl <- function(str){
  str %>>%
    ## gsub(pattern = "\\\\", replacement = "SANITIZE.BACKSLASH") %>>%
    gsub(pattern = "$", replacement = "\\$", fixed = TRUE) %>>%
    gsub(pattern = ">", replacement = "$>$", fixed = TRUE) %>>%
    gsub(pattern = "<", replacement = "$<$", fixed = TRUE) %>>%
    gsub(pattern = "|", replacement = "$|$", fixed = TRUE) %>>%
    ## gsub(pattern = "{", replacement = "\\{", fixed = TRUE) %>>%
    ## gsub(pattern = "}", replacement = "\\}", fixed = TRUE) %>>%
    gsub(pattern = "%", replacement = "\\%", fixed = TRUE) %>>%
    gsub(pattern = "&", replacement = "\\&", fixed = TRUE) %>>%
    gsub(pattern = "_", replacement = "\\_", fixed = TRUE) %>>%
    gsub(pattern = "#", replacement = "\\#", fixed = TRUE) %>>%
  ## gsub(pattern = "~", replacement = "\\~{}", fixed = TRUE) %>>%
    gsub(pattern = "SANITIZE.BACKSLASH", replacement = "$\\backslash$", fixed = TRUE) ->
    result
  return(result)
}

