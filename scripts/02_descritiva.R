# scripts/02_descritiva.R
# Estatística descritiva por especie x tipo_habitat

req <- c("tidyverse", "here")
new <- req[!req %in% installed.packages()[,1]]
if (length(new)) install.packages(new, dependencies = TRUE)
invisible(lapply(req, library, character.only = TRUE))

proc_dir <- here::here("data", "processed")
tab_dir  <- here::here("outputs", "tabelas")
fig_dir  <- here::here("outputs", "figuras")

for (d in c(tab_dir, fig_dir)) if (!dir.exists(d)) dir.create(d, recursive = TRUE)

dados <- readr::read_csv(file.path(proc_dir, "ocorrencias_tratadas.csv"))

# Estatística descritiva
desc <- dados %>%
  group_by(especie, tipo_habitat) %>%
  summarise(
    n_amostras = n(),
    soma_abund = sum(abundancia, na.rm = TRUE),
    media = mean(abundancia, na.rm = TRUE),
    dp = sd(abundancia, na.rm = TRUE),
    minimo = min(abundancia, na.rm = TRUE),
    maximo = max(abundancia, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(especie, tipo_habitat)

out_csv <- file.path(tab_dir, "estatistica_descritiva_especie_habitat.csv")
readr::write_csv(desc, out_csv)
message("Salvo: ", out_csv)

# Figura (boxplot)
p <- ggplot(dados, aes(x = especie, y = abundancia)) +
  geom_boxplot() +
  labs(x = "Espécie", y = "Abundância", title = "Abundância por espécie") +
  theme_minimal()

out_png <- file.path(fig_dir, "boxplot_abundancia_por_especie.png")
ggsave(out_png, p, width = 9, height = 5, dpi = 300)
message("Salvo: ", out_png)
