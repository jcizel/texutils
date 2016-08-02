##' @export
sparkfigures <-function(data,
                        idcol,
                        xcol,
                        ycol,
                        dir.output = NULL,
                        dir.figs = NULL,
                        plotname = '',
                        plotterfun = NULL,
                        fig.height = 5,
                        fig.width = 10){

  if (is.null(dir.output)){
    dir.root <- '/Users/jankocizel/Documents/Dropbox/Projects/PhD Thesis/R/PACKAGES/texutils/'
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
    plotter <- .plotter
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
                            sprintf("spark_%s_%s_%s_%s",plotname,id,xcol,ycol) %>>%
                              gsub(pattern = "[[:punct:]]",replacement = "") %>>%
                              sprintf(fmt = "%s.pdf"))
        ggsave(p,filename = figpath,height = fig.height, width = fig.width)


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


.plotter <- function(data){
  mins = data %>>% subset(y == min(y, na.rm = TRUE)) %>>%
    mutate(label = y %>>% formatC(format = 'f', digits = 2))
  maxs = data %>>% subset(y == max(y, na.rm = TRUE)) %>>%
    mutate(label = y %>>% formatC(format = 'f', digits = 2))
  ends = data %>>% subset(!is.na(y)) %>>%
    subset(x == max(x,na.rm = TRUE)) %>>%
    mutate(label = y %>>% formatC(format = 'f', digits = 2))

  size.lab = 7
  data %>>%
    ggplot(
      aes(
        x = x,
        y = y
      )
    ) +
    geom_line(size=1) +
    geom_point(data = mins, col = 'red', size = 3) +
    geom_point(data = maxs, col = 'blue', size = 3) +
    geom_text(data = mins, aes(label = label), vjust = -1, colour = 'red', size = size.lab) +
    geom_text(data = maxs, aes(label = label), vjust = +1.5, colour = 'blue', size = size.lab) +
    geom_text(data = ends, aes(label = label), hjust = 0, nudge_x = 1, size = size.lab) +
    ggthemes::theme_tufte(base_size = 15, base_family = "Helvetica") +
    theme(axis.title = element_blank(),
          axis.text.y = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks = element_blank(),
          strip.text = element_blank()) ->
    p

  return(p)
}
