
# --- Borrar todos los objetos
rm(list = objects())

#  --- Carga de librerias
library(lubridate)
library(rvest)
library(utils)
library(xml2)
library(yaml)

# -----------------------------------------------------------------------------#
# --- Lectura de archivo de configuracion ----

args           <- commandArgs(trailingOnly = TRUE)
archivo.config <- args[1]
if (is.na(archivo.config)) {
  # No vino el archivo de configuracion por linea de comandos. Utilizo un archivo default
  archivo.config <- paste0(getwd(), "/configuracion.yml")
}
if (! file.exists(archivo.config)) {
  stop(paste0("El archivo de configuracion de ", archivo.config, " no existe\n"))
} else {
  cat(paste0("Leyendo archivo de configuracion ", archivo.config, "...\n"))
  config <- yaml::yaml.load_file(archivo.config)
}

rm(args, archivo.config); gc()
# ------------------------------------------------------------------------------

# -----------------------------------------------------------------------------#
# --- Funcion para buscar links con un pattern en una URL ----

FindLinks <- function(url, pattern) {
  hrefs <- xml2::read_html(url) %>%
    rvest::html_nodes(., css = "a") %>%
    rvest::html_attr(., "href")
  return (hrefs[grep(x = hrefs, pattern = pattern)])
}
# ------------------------------------------------------------------------------

# -----------------------------------------------------------------------------#
# --- Funcion para bajar un archivo ----

DownloadFile <- function(url, username, password, output.dir) {
  if (! dir.exists(output.dir)) {
    dir.create(output.dir)
  }

  file.parts <- strsplit(url, "/")[[1]]
  file.date  <- file.parts[length(file.parts)-1]
  file.name  <- file.parts[length(file.parts)]
  destfile   <- paste0(output.dir, "/", file.date, "_", file.name)
  utils::download.file(url, destfile, method="wget", mode="wb",
                       extra=c(paste0("--user=", username),
                        paste0("--password=", password)))
}
# ------------------------------------------------------------------------------

# Obtener fechas

base.url <- paste0(config$server$url$scheme, "://",
  config$server$credentials$user, ":",
  config$server$credentials$pass, "@",
  config$server$url$host,
  config$server$url$path)

dates.path <- FindLinks(base.url, "\\d{4}\\.\\d{2}\\.\\d{2}")

# Para cada carpeta de fecha, buscar los archivos con los patterns seleccionados
# Esto se hace si y solo si la fecha esta dentro del rango de fechas aceptables

file.list <- c()

for (date.path in dates.path) {
  date.path.part <- strsplit(date.path, "/")[[1]]
  date.parts     <- strsplit(date.path.part, "\\.")[[1]]
  date           <- lubridate::ymd(paste0(sprintf("%s-%s-%s", date.parts[1], date.parts[2], date.parts[3])))
  if ((date >= config$filter$date.range$from) && (date <= config$filter$date.range$to)) {
    cat(paste0("Buscando archivos para fecha ", date))
    date.url <- paste0(base.url, date.path)
    for (pattern in config$filter$file.name.patterns) {
      date.pattern.list <- FindLinks(date.url, pattern)
      cat(paste0(" (", length(date.pattern.list), ")\n"))
      if (length(date.pattern.list) > 0) {
        file.list <- c(file.list, paste0(date.url, date.pattern.list))
      }
    }
  }
}
cat(paste0("Se encontraron ", length(file.list), " archivos para descargar\n\n"))

if (config$download) {
  for (file in file.list) {
    cat(paste0("Descargando ", file, "\n"))
    DownloadFile(file, config$server$credentials$user, config$server$credentials$pass, config$dir$output)
  }
} else {
  cat("Listado de archivos a descargar\n")
  for (file in file.list) {
    cat(paste0(file, "\n"))
  }
}