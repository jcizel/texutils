##' @export
sparkfigures <-function(data,
                        idcol,
                        xcol,
                        ycol,
                        dir.output = NULL,
                        dir.figs = NULL,
                        plotname = '',
                        plotterfun = NULL){

  dir.root <- '/Users/jankocizel/Documents/Dropbox/Projects/PhD Thesis/R/PACKAGES/Projects2016.Macropru/'

  if (is.null(dir.output)){
     dir.output <- file.path(dir.root,'inst/output',Sys.Date())
     dir.create(dir.output)
  }

  dir.old = getwd()
  setwd(dir.output)

  if(is.null(dir.figs)){
    dir.figs <- file.path(".","figs")
    dir.create(dir.figs)
  } else {
    dir.create(dir.figs)
  }

  data %>>%
    copy %>>%
    setnames(
      old = c(idcol,xcol,ycol),
      new = c('id','x','y')
    ) %>>%
    dplyr::select(
      id,x,y
    ) %>>%
    split(.[['id']]) ->
    l.data

  ## ------------------------------------------------------------------------ ##
  ## PLOTTING FUNCTION                                                        ##
  ## ------------------------------------------------------------------------ ##
  if (is.null(plotterfun)){
    plotter <- function(dt2plot){
      dt2plot %>>%
        ggplot(
          aes(
            x = x,
            y = y
          )
        ) +
        geom_line(size=0.3) +
        ggthemes::theme_tufte(base_size = 15, base_family = "Helvetica") +
        theme(axis.title = element_blank(), axis.text.y = element_blank(),
              axis.text.x = element_blank(),
              axis.ticks = element_blank(), strip.text = element_blank()) ->
        p
      return(p)
    }
  } else {
    plotter <- plotterfun
  }


  l.data %>>%
    list.map({
      dt = .
      id = .name
      message(id)

      p = try({dt %>>% plotter})

      if (sum(!is.na(dt[['y']]) * 1) < 3){
        obj = NULL
      } else {
        figpath = file.path('.',
                            basename(dir.figs),
                            sprintf("spark_%s_%s",plotname,id) %>>%
                              gsub(pattern = "[[:punct:]]",replacement = "") %>>%
                              sprintf(fmt = "%s.pdf"))
        ggsave(p,filename = figpath,height = 2, width = 10)


        data.table(
          id = id,
          figpath = figpath,
          plot = sprintf("\\graph{1}{1}{%s}",figpath)
        ) ->
          obj
      }

      obj
    }) %>>%
  Filter(f = function(x) !is.null(x)) %>>%
  rbindlist -> out

  setwd(dir.old)
  return(out)
}
