##' @export
excel2pdf <- function(outfile,...){
  DIR.DATA <- "/Users/jankocizel/Documents/Dropbox/Projects/PhD Thesis/R/PACKAGES/texutils/inst/test_output"

  template <- readLines(system.file('./latex_templates/latex_article.tex',package = 'texutils'))

  excel2tex(outfile = outfile,...) ->
    out

  list(
    content = out
  ) ->
    info

  whisker.render(template, info) ->
    out

  if (!is.null(outfile)){
    out %>>%
      writeLines(con = sprintf(fmt = "%s", outfile))
    cat(sprintf(fmt = "File written to: %s.\n", outfile))
  } else {
    outfile = file.path(DIR.DATA,
                        sprintf("%s Test.tex",Sys.time()))
    out %>>%
      writeLines(con = sprintf(fmt = "%s", outfile))
    cat(sprintf(fmt = "File written to: %s.\n", outfile))
  }

  wd.old <- getwd()
  setwd(dirname(outfile))

  system(sprintf('pdflatex "%s"',basename(outfile)))
  system(sprintf('pdflatex "%s"',basename(outfile)))
  outfile.pdf <- gsub("\\.tex$","\\.pdf",outfile)
  system(sprintf('open "%s"',outfile.pdf))
  setwd(wd.old)

  return(out)
}

