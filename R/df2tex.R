##' @export
df2tex <- function(df,outfile,...){
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

  excel2tex(file = temp,
            outfile = outfile,
            sheet = 'sheet',...) ->
    out

  unlink(temp)
  return(out)
}
