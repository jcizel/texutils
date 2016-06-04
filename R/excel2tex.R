#' @export
excel2tex <-
  function(file,
           outfile,
           sheet = 1,
           skip = 0,
           firstcolwidth = 2,
           colwidth = 1.2,
           escaperows = NULL,
           escapecols = NULL,
           caption = '',
           textsize = 'scriptsize',
           label = 'table',
           notes = '',
           type = 'longtable' ## c('siunitx','shorttable','longtable')
           ){

    read_excel(file, sheet = sheet, skip=skip, col_names = FALSE) %>>%
      data.frame ->
      data

    par.ncol <- (data %>>% NCOL) - 1

    if (!is.null(escaperows)){
      for (r in escaperows){
        if (type == 'number'){
          data[r,] %>>%
            sapply(function(c){
              c[is.na(c)] <- ""
              sprintf(
                fmt = "\\multicolumn{1}{C{%s cm}}{%s}",
                ## fmt = "{\\shortstack{%s}}"
                colwidth,
                c
              )
            }) %>>% as.character ->
            new

          data[r,] <- new
        } else {
          data[r,] %>>%
            sapply(function(c){
              c[is.na(c)] <- ""
              c %>>%
                sprintf(
                  fmt = "\\multicolumn{1}{c}{%s}"
                )
            }) %>>% as.character ->
            new

          data[r,] <- new
        }
      }
    }

    if (!is.null(escapecols)){
      for (c in escapecols){
        data[-escaperows,c] %>>%
          sapply(function(r){
            r[is.na(r)] <- ""
            sprintf(
              fmt = "{%s}",
              r
            )
          }) %>>% as.character ->
          new

        data[-escaperows,c] <- new
      }
    }

    data %>>%
      lapply(function(c){
        c %>>%
          as.character ->
          c
        c[is.na(c)] <- ""
        c %>>%
          sanitizexl
      }) %>>%
      data.frame %>>%
      apply(1,
            function(r){
              r %>>%
                paste(
                  collapse = " & "
                ) %>>%
                sprintf(
                  fmt = "%s \\\\"
                )
            }) ->
      ## paste(
      ##   collapse = "\n"
      ## ) ->
      CONTENT

    ## ---------------------------------------------------------------------- ##
    ## OUTPUT FILE                                                            ##
    ## ---------------------------------------------------------------------- ##
    if (type == 'siunitx'){
      template <- readLines(system.file('./latex_templates/latex_table_numbers.tex',package = 'texutils'))
      list(
        caption = caption,
        textsize = textsize,
        header = CONTENT[1L] %>>% paste(collapse = "\n"),
        content = CONTENT[-1L] %>>% paste(collapse = "\n"),
        firstcolwidth = firstcolwidth,
        colwidth = colwidth,
        ncol = par.ncol,
        label = label,
        notes = notes
      ) ->
        info
    } else if (type == 'shorttable') {
      template <- readLines(system.file('./latex_templates/latex_table_shorttable.tex',package = 'texutils'))
      list(
        caption = caption,
        textsize = textsize,
        header = CONTENT[1L] %>>% paste(collapse = "\n"),
        content = CONTENT[-1L] %>>% paste(collapse = "\n"),
        firstcolwidth = firstcolwidth,
        colwidth = colwidth,
        ncol = par.ncol,
        label = label,
        notes = notes
      ) ->
        info
    } else if (type == 'longtable'){
      template <- readLines(system.file('./latex_templates/latex_table_text_longtable.tex',package = 'texutils'))
      list(
        caption = caption,
        textsize = textsize,
        header = CONTENT[1L] %>>% paste(collapse = "\n"),
        content = CONTENT[-1L] %>>% paste(collapse = "\n"),
        firstcolwidth = firstcolwidth,
        colwidth = colwidth,
        ncol = par.ncol,
        label = label,
        notes = notes
      ) ->
        info
    } else {
      stop("Select the type of output table!")
    }

    whisker.render(template, info) ->
      out

    if (!is.null(outfile)){
      out %>>%
        writeLines(con = sprintf(fmt = "%s", outfile))
      cat(sprintf(fmt = "File written to: %s.\n", outfile))
    }

    return(out)
  }