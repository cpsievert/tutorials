library(htmltools)

options(htmltools.dir.version = FALSE)

save_widget <- function(p, file, ...) {
  save_html(p, file, libdir = "index_files")
}