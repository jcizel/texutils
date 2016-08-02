##' @import data.table pipeR rlist openxlsx ggplot2
##' @importFrom dplyr mutate select arrange
##' @importFrom stringr str_trim
##' @importFrom whisker whisker.render
NULL


.onLoad <- function(libname = find.package("texutils"), pkgname = "texutils") {
  message(rep("*",70))
  message("texutils")
  message("By Janko Cizel, 2016. All rights reserved.")
  message("www.jankocizel.com")
  message(rep("*",70))
}
