# scripts/01_preparo_dados.R
# Leitura, limpeza e junção dos dados para data/processed/

# Pacotes
req <- c("tidyverse", "janitor", "lubridate", "here")
new <- req[!req %in% installed.packages()[,1]]
if (length(new)) install.packages(new, dependencies = TRUE)
invisible(lapply(req, library, character.only = TRUE))

# Caminhos
raw_dir <- here::here("data", "raw")
proc_dir <- here::here("data", "processed")
if (!dir.exists(proc_dir)) dir.create(proc_dir, recursive = TRUE)

# Leitura
occ <- readr::read_csv(file.path(raw_dir, "ocorrencias_herpetofauna_2024_2025.csv")) %>%
  janitor::clean_names()

loc <- readr::read_csv(file.path(raw_dir, "locais_amostragem.csv")) %>%
  janitor::clean_names()

# Tratamento básico
occ <- occ %>%
  mutate(
    data = lubridate::as_date(data),
    especie = stringr::str_squish(especie),
    abundancia = as.numeric(abundancia)
  )

# Junção
dados <- occ %>% left_join(loc, by = "site_id")

# Validar colunas essenciais
stopifnot(all(c("site_id","data","especie","abundancia","tipo_habitat") %in% names(dados)))

# Exportar
out_csv <- file.path(proc_dir, "ocorrencias_tratadas.csv")
readr::write_csv(dados, out_csv)
message("Salvo: ", out_csv)
