#' @export
excel2tex <-
  function(file,
           outfile,
           sheet = 1,
           skip = 0,
           colwidths = 1.2,
           colorient = 'L',
           escaperows = NULL,
           escapecols = NULL,
           caption = '',
           textsize = 'scriptsize',
           label = 'table',
           notes = '\\item[a] Note 1.',
           type = 'longtable' ## c('siunitx','shorttable','longtable')
           ){

    read.xlsx(file,
              sheet = sheet,
              startRow = skip+1,
              colNames = FALSE) ->
      data.frame ->
      data

    if (length(colorient) == 1){
      colorient = rep(colorient, times = NCOL(data))
    }

    if (length(colwidths) == 1){
      colwidths2 = sprintf(
        "*{ %s }{>{\\hangindent=1em}%s{ %s cm}}",
        data %>>% NCOL,
        colorient[1L],
        colwidths
      )
      colwidths = rep(colwidths,times = NCOL(data))
    } else {
      if (length(colwidths) != NCOL(data)){
        stop("Length of the colwidths vector must be the same as the number of columms in the table.")
      } else {
        colwidths2 = sprintf(
          ">{\\hangindent=1em}%s{ %s cm}",
          colorient,
          colwidths
        ) %>>%
          paste(collapse = "\n")
      }
    }

    par.ncol <- (data %>>% NCOL) - 1

    if (!is.null(escaperows)){
      for (r in escaperows){
        if (type == 'number'){
          mapply(
            data[r,],
            colwidths,
            FUN = function(x,y){
              x[is.na(x)] <- ""
              sprintf(
                fmt = "\\multicolumn{1}{C{%s cm}}{%s}",
                ## fmt = "{\\shortstack{%s}}"
                y,
                x
              )
            }) %>>% as.character ->
            new

          data[r,] <- new
        } else {
          mapply(
            data[r,],
            colwidths,
            FUN = function(x,y){
              x[is.na(x)] <- ""
              sprintf(
                fmt = "\\multicolumn{1}{C{%s cm}}{%s}",
                y,
                x
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
        colwidths = colwidths2,
        header = CONTENT[1L] %>>% paste(collapse = "\n"),
        content = CONTENT[-1L] %>>% paste(collapse = "\n"),
        ## firstcolwidth = firstcolwidth,
        ## colwidth = colwidth,
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
        colwidths = colwidths2,
        header = CONTENT[1L] %>>% paste(collapse = "\n"),
        content = CONTENT[-1L] %>>% paste(collapse = "\n"),
        ## firstcolwidth = firstcolwidth,
        ## colwidth = colwidth,
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
        colwidths = colwidths2,
        header = CONTENT[1L] %>>% paste(collapse = "\n"),
        content = CONTENT[-1L] %>>% paste(collapse = "\n"),
        ## firstcolwidth = firstcolwidth,
        ## colwidth = colwidth,
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
