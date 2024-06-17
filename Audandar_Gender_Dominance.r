# Load necessary libraries
library(devtools)
library(geokz)
library(dplyr)
library(sf)
library(tmap)

devtools::install_github("arodionoff/geokz")

Population_Density_df <- read.csv('C:/Users/User/Desktop/R/Audandar-male-female.csv', sep = ";", fileEncoding = "ISO-8859-1") %>%
  dplyr::select(ADM2_PCODE, ADM2_EN, Area, Population, Male, Female) %>%
  dplyr::rename(ISO_3166_2 = ADM2_PCODE, Region = ADM2_EN) %>%
  dplyr::mutate(
    Population_Density = round(Population / Area, 1),
    Male = as.numeric(gsub(" ", "", Male)),
    Female = as.numeric(gsub(" ", "", Female)),
    Gender_Dominance = ifelse(Male > Female, "Male", "Female")
  )

Population_Density_df$ISO_3166_2 <- trimws(Population_Density_df$ISO_3166_2)
rayons_map <- get_kaz_rayons_map(Year = 2024)
rayons_map$ADM2_PCODE <- trimws(rayons_map$ADM2_PCODE)

Population_Density_df$ISO_3166_2 <- as.character(Population_Density_df$ISO_3166_2)
rayons_map$ADM2_PCODE <- as.character(rayons_map$ADM2_PCODE)

print(unique(Population_Density_df$ISO_3166_2))
print(unique(rayons_map$ADM2_PCODE))

map_data <- dplyr::inner_join(
  x = rayons_map,
  y = Population_Density_df[, c("ISO_3166_2", "Gender_Dominance")],
  by = c("ADM2_PCODE" = "ISO_3166_2")
)

print(map_data)

map_plot <- tmap::tm_shape(map_data) +
  tmap::tm_fill("Gender_Dominance", palette = c("1" = "blue", "2" = "red"), title = "Gender Dominance") +
  tmap::tm_borders()

tmap::tmap_save(map_plot, "C:/Users/User/Desktop/Audandar_Gender_Dominance.jpeg")