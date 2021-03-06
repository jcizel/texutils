##' @export
df2pdf <- function(df,outfile,landscape = TRUE,...){
  tempfile(fileext = '.xlsx') ->
    temp

  wb <- createWorkbook()
  addWorksheet(wb,'sheet')
  writeData(
    wb,
    'sheet',
    df)

  saveWorkbook(wb,
               file = temp,
               overwrite = TRUE)

  excel2pdf(file = temp,
            outfile = outfile,
            landscape = landscape,
            sheet = 'sheet',...) ->
    out

  unlink(temp)
  return(out)
}
