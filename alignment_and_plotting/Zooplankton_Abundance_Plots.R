rm(list = ls())

library(tidyverse)
library(readxl)
library(hms)
library(sf)
library(sfheaders)
library(lubridate)
library(marmap)
library(rstatix)
library(R.utils)
library(ggpubr)
library(ggnewscale)
library(rnaturalearth)
library(tcltk)
library(cowplot)

# home_dir = "H:/dm1679/Data/"
home_dir = "C:/Users/Delphine/Box/"

#####

## Delta concentration/biomass figures

# This file is made by Zooplankton_Abundance_Modeling.R
# load("H:/dm1679/Data/Glider Data/RMI_Zoop_FTLE_Correlation_Data_Full.rda")

load(paste0(home_dir,"Glider Data/ru39-20230420T1636/Derived Biomass Data/Processed_Abundance_Biomass_Data.rda"))
assign("zoop_data_spring_2023", data3)
rm(data3)

load(paste0(home_dir,"Glider Data/ru39-20231103T1413/Derived Biomass Data/Processed_Abundance_Biomass_Data.rda"))
assign("zoop_data_fall_2023", data3)
rm(data3)

load(paste0(home_dir,"Glider Data/ru39-20240215T1646/Derived Biomass Data/Processed_Abundance_Biomass_Data.rda"))
assign("zoop_data_winter_2024", data3)
rm(data3)

load(paste0(home_dir,"Glider Data/ru39-20240429T1522/Derived Biomass Data/Processed_Abundance_Biomass_Data.rda"))
assign("zoop_data_spring_2024", data3)
rm(data3)

load(paste0(home_dir,"Glider Data/ru43-20240904T1539/Derived Biomass Data/Processed_Abundance_Biomass_Data.rda"))
assign("zoop_data_summer_2024", data3)
rm(data, data2, data3, data4, data_filenames, data_ldf)

zoop_data_spring_2023$Season = "Spring"
zoop_data_fall_2023$Season = "Fall"
zoop_data_winter_2024$Season = "Winter"
zoop_data_spring_2024$Season = "Spring"
zoop_data_summer_2024$Season = "Summer"

zoop_data_full = rbind(zoop_data_spring_2023,zoop_data_fall_2023,zoop_data_winter_2024,zoop_data_spring_2024,zoop_data_summer_2024) %>% 
  filter(Abundance > 0) %>%
  arrange(Date) %>% st_drop_geometry()
zoop_data_full$Season = factor(zoop_data_full$Season, levels = c("Spring","Summer","Fall","Winter"), ordered = T)

fname = "H:/dm1679/Data/Glider Data/RMI_Zoop_Correlation_Data_Full.rda"
save(zoop_data_full, file = fname)

load("H:/dm1679/Data/Glider Data/RMI_Zoop_Correlation_Data_Full.rda")

zoop_data_full_delta = zoop_data_full %>%
  mutate(Year = year(Date)) %>%
  group_by(Year, Season, Species) %>%
  reframe(Avg_Abundance = mean(Abundance)) %>%
  slice(1:4,9,10,5:8) %>%
  group_by(Species) %>%
  mutate(Delta_A = ifelse(row_number() == 1,
                          0,
                          Avg_Abundance - lag(Avg_Abundance, 1))) %>%
  mutate(Delta_A = ifelse(Delta_A > 0,
                          log10(Delta_A),
                          -1 * log10(abs(Delta_A))),
         YearSeason = paste0(Year, " ", Season)) %>%
  mutate(YearSeason = factor(YearSeason, levels = YearSeason, ordered = T))
zoop_data_full_delta$Delta_A[1:2] = 0

#####

ggplot() + 
  geom_boxplot(data = zoop_data_full, aes(y = Abundance)) + 
  scale_fill_viridis_d(guide = NULL, begin = 0.2) +
  scale_y_continuous(trans="log10") +
  labs(y = "Log10 of Concentration (individuals/m^3)") +
  facet_grid(~Season)

ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Seasonal_Concentration_Boxplot.png", scale = 2)

ggplot() + 
  geom_boxplot(data = zoop_data_full, aes(x = Species, fill = Species, y = Abundance)) + 
  scale_fill_viridis_d(guide = NULL, begin = 0.2) +
  scale_y_continuous(trans="log10") +
  labs(y = "Log10 of Concentration (individuals/m^3)") +
  facet_grid(~Season)

ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Seasonal_Concentration_Copepods_Boxplot.png", scale = 2)

ggplot() + 
  geom_boxplot(data = zoop_data_full[!is.na(zoop_data_full$Shelf_Type),], aes(y = Abundance)) + 
  scale_fill_viridis_d(guide = NULL, begin = 0.2) +
  scale_y_continuous(trans="log10") +
  labs(y = "Log10 of Concentration (individuals/m^3)") +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank()) +
  facet_grid(Season~Shelf_Type)

ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Shelf_Type_Concentration_Boxplot.png", scale = 2)

ggplot() + 
  geom_boxplot(data = zoop_data_full[!is.na(zoop_data_full$Shelf_Type),], aes(x = Species, fill = Species, y = Abundance)) + 
  scale_fill_viridis_d(guide = NULL, begin = 0.2) +
  scale_y_continuous(trans="log10") +
  labs(y = "Log10 of Concentration (individuals/m^3)") +
  theme_bw() + 
  facet_grid(Season~Shelf_Type)

ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Shelf_Type_Concentration_Copepods_Boxplot.png", scale = 2)

ggplot() + 
  geom_boxplot(data = zoop_data_full[!is.na(zoop_data_full$Depth_Type),], aes(y = Abundance)) + 
  scale_fill_viridis_d(guide = NULL, begin = 0.2) +
  scale_y_continuous(trans="log10") +
  labs(y = "Log10 of Concentration (individuals/m^3)") +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank()) +
  facet_grid(Season~Depth_Type)

ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Depth_Type_Concentration_Boxplot.png", scale = 2)

ggplot() + 
  geom_boxplot(data = zoop_data_full[!is.na(zoop_data_full$Depth_Type),], aes(x = Species, fill = Species, y = Abundance)) + 
  scale_fill_viridis_d(guide = NULL, begin = 0.2) +
  scale_y_continuous(trans="log10") +
  labs(y = "Log10 of Concentration (individuals/m^3)") +
  theme_bw() + 
  facet_grid(Season~Depth_Type)

ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Depth_Type_Concentration_Copepods_Boxplot.png", scale = 2)

#####

zoop_data_full$Shelf_Type[is.na(zoop_data_full$Shelf_Type)] = "Offshore"

zoop_data_full[,5:6] = log10(zoop_data_full[,5:6])

zoop_data_full = (complete(zoop_data_full, Season, Species, Shelf_Type, fill = list(Abundance = 0, Biomass = 0), explicit  = F))

ggplot(data = zoop_data_full[zoop_data_full$Species == "Small Copepod",], 
       aes(x = Season, color = Shelf_Type, y = Abundance)) + 
  geom_boxplot(linewidth = 0.75,
               notch = T) +
  stat_summary(fun = mean, geom = "point", show.legend = F, position = position_dodge(0.75), shape=4, size=4, stroke = 1) +
  scale_color_viridis_d(begin = 0, end = 0.8) +
  scale_y_log10(limits = c(1,10000000), breaks = c(1, 100, 10000, 1000000)) +
  labs(y = "Log10 of Small Copepod\nConcentration (individuals/m^3)",
       color = "NOAA Strata\nAssignment") +
  theme_bw()

ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Shelf_Type_Concentration_Small_Copepods_Boxplot.png", scale = 2)

ggplot(data = zoop_data_full[zoop_data_full$Species == "Small Copepod",], 
       aes(x = Season, color = Shelf_Type, y = Biomass)) + 
  geom_boxplot(linewidth = 0.75,
               notch = T) +
  stat_summary(fun = mean, geom = "point", show.legend = F, position = position_dodge(0.75), shape=4, size=4, stroke = 1) +
  scale_color_viridis_d(begin = 0, end = 0.8) +
  scale_y_log10(limits = c(0.0001,100), breaks = c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100)) +
  labs(y = "Log10 of Small Copepod\nBiomass (g/m^3)",
       color = "NOAA Strata\nAssignment") +
  theme_bw()

ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Shelf_Type_Biomass_Small_Copepods_Boxplot.png", scale = 2)

ggplot(data = zoop_data_full[zoop_data_full$Species == "Large Copepod",], 
       aes(x = Season, color = Shelf_Type, y = Abundance)) + 
  geom_boxplot(linewidth = 0.75,
               notch = T) +
  scale_color_viridis_d(begin = 0, end=0.8) +
  stat_summary(fun = mean, geom = "point", show.legend = F, position = position_dodge(0.75), shape=4, size=4, stroke = 1) +
  scale_y_log10(limits = c(1,10000000), breaks = c(1, 100, 10000, 1000000)) +
  labs(y = "Log10 of Large Copepod\nConcentration (individuals/m^3)",
       color = "NOAA Strata\nAssignment") +
  theme_bw()

ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Shelf_Type_Concentration_Large_Copepods_Boxplot.png", scale = 2)

ggplot(data = zoop_data_full[zoop_data_full$Species == "Large Copepod",], 
       aes(x = Season, color = Shelf_Type, y = Biomass)) + 
  geom_boxplot(linewidth = 0.75,
               notch = T) +
  stat_summary(fun = mean, geom = "point", show.legend = F, position = position_dodge(0.75), shape=4, size=4, stroke = 1) +
  scale_color_viridis_d(begin = 0, end = 0.8) +
  scale_y_continuous(trans="log10", limits = c(0.0001,100), breaks = c(0.0001, 0.001, 0.01, 0.1, 1, 10, 100)) +
  labs(y = "Log10 of Large Copepod\nBiomass (g/m^3)",
       color = "NOAA Strata\nAssignment") +
  theme_bw()

ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Shelf_Type_Biomass_Large_Copepods_Boxplot.png", scale = 2)

#####

ggplot() + 
  geom_col(dat = zoop_data_full_delta, position = position_dodge(), aes(x = Species, y = Delta_A, group = YearSeason, fill = YearSeason)) +
  scale_fill_viridis_d(
    breaks = c("2023 Spring", "2023 Fall", "2024 Winter", "2024 Spring", "2024 Summer")
  ) +
  labs(x = "Species",
       y = "log10 of Change in Average Concentration",
       fill = "Year and Season")
ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Avg_Concentration_Change_Plot.png", scale = 2)

# ggplot() + 
#   geom_col(dat = zoop_data_full_delta, position = position_dodge(), aes(x = Species, y = log10(Abundance), group = YearSeason, fill = YearSeason)) +
#   scale_fill_viridis_d(
#     breaks = c("2023 Spring", "2023 Fall", "2024 Winter", "2024 Spring", "2024 Summer")
#   ) +
#   labs(x = "Species",
#        y = "log10 of Abundance",
#        fill = "Year and Season")
# ggsave("H:/dm1679/Data/Glider Data/RMI_Abundance_Plot.png", scale = 2)

#####

load("H:/dm1679/Data/Glider Data/ru39-20230420T1636/Derived Biomass Data/Processed_Abundance_Biomass_Data.rda")
#zoop_data_spring_2023_d_int = subset(data4, select=-c(pH, temperature, salinity, chlorophyll_a))
assign("zoop_data_spring_2023_d_int", data4)
rm(data4)

load("H:/dm1679/Data/Glider Data/ru39-20231103T1413/Derived Biomass Data/Processed_Abundance_Biomass_Data.rda")
#zoop_data_fall_2023_d_int = subset(data4, select=-c(pH, temperature, salinity, chlorophyll_a))
assign("zoop_data_fall_2023_d_int", data4)
rm(data4)

load("H:/dm1679/Data/Glider Data/ru39-20240215T1646/Derived Biomass Data/Processed_Abundance_Biomass_Data.rda")
#zoop_data_winter_2024_d_int = subset(data4, select=-c(pH, temperature, salinity, chlorophyll_a))
assign("zoop_data_winter_2024_d_int", data4)
rm(data4)

load("H:/dm1679/Data/Glider Data/ru39-20240429T1522/Derived Biomass Data/Processed_Abundance_Biomass_Data.rda")
#zoop_data_spring_2024_d_int = subset(data4, select=-c(pH, temperature, salinity, chlorophyll_a))
assign("zoop_data_spring_2024_d_int", data4)
rm(data4)

load("H:/dm1679/Data/Glider Data/ru43-20240904T1539/Derived Biomass Data/Processed_Abundance_Biomass_Data.rda")
assign("zoop_data_summer_2024_d_int", data4)
rm(data4)

rm(list=c("data_ldf", "data_filenames","data","data2","data3"))

zoop_data_spring_2023_d_int$Season = "Spring"
zoop_data_fall_2023_d_int$Season = "Fall"
zoop_data_winter_2024_d_int$Season = "Winter"
zoop_data_spring_2024_d_int$Season = "Spring"
zoop_data_summer_2024_d_int$Season = "Summer"

zoop_data_full_2 = rbind(zoop_data_spring_2023_d_int,zoop_data_fall_2023_d_int,zoop_data_winter_2024_d_int,zoop_data_spring_2024_d_int,zoop_data_summer_2024_d_int) %>% 
  filter(D_Int_Abundance > 0) %>%
  mutate(Shelf_Type = replace(Shelf_Type, is.na(Shelf_Type), "Offshore"))

zoop_data_full_2$Season = factor(zoop_data_full_2$Season, levels = c("Spring","Summer","Fall","Winter"), ordered = T)

zoop_data_full_delta_2 = zoop_data_full_2 %>%
  mutate(Year = year(Date)) %>%
  group_by(Year, Season, Species, Depth_Type) %>%
  reframe(Avg_D_Int_Abundance = mean(D_Int_Abundance)) %>%
  slice(1:12, 25:30, 13:24) %>%
  mutate(YearSeason = paste0(Year, " ", Season)) %>%
  group_by(Species, Depth_Type) %>%
  mutate(Delta = ifelse(row_number() == 1,
                        0,
                        Avg_D_Int_Abundance - lag(Avg_D_Int_Abundance, 1))) %>%
  mutate(Delta = ifelse(Delta > 0,
                        log10(Delta),
                        -1 * log10(abs(Delta)))) %>%
  mutate(YearSeason = factor(YearSeason, levels = YearSeason, ordered = T))
zoop_data_full_delta_2$Delta[1:6] = 0

#####

ggplot() + 
  geom_boxplot(data = zoop_data_full_2, aes(x = Species, fill = Species, y = D_Int_Abundance)) + 
  scale_fill_viridis_d(guide = NULL, begin = 0.2) +
  scale_y_continuous(trans="log10") +
  labs(y = "Log10 of Concentration (individuals/m^3)") +
  facet_grid(rows=vars(Depth_Type), cols=vars(Season))
ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Seasonal_Concentration_Depth_Boxplot.png", scale = 2)

ggplot() + 
  geom_col(dat = zoop_data_full_delta_2, position = position_dodge(), aes(x = Species, y = Delta, group = YearSeason, fill = YearSeason)) +
  scale_fill_viridis_d(
    breaks = c("2023 Spring", "2023 Fall", "2024 Winter", "2024 Spring", "2024 Summer")
  ) +
  labs(x = "Species",
       y = "log10 of Change in Abundance",
       fill = "Year and Season") +
  facet_grid(~Depth_Type)
ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Concentration_Change_Depth_Type_Plot.png", scale = 2)

#####

zoop_data_full_delta_3 = zoop_data_full_2 %>%
  mutate(Year = year(Date)) %>%
  group_by(Year, Season, Species, Shelf_Type) %>%
  reframe(Avg_D_Int_Abundance = mean(D_Int_Abundance)) %>%
  slice(1:12, 24:27, 13:23) %>%
  mutate(YearSeason = paste0(Year, " ", Season))

## Need to do some fiddling to account for missing seasons

padding = data.frame(Year = 2024,
                     Season = c("Winter","Winter","Summer"),
                     Species = c("Large Copepod","Small Copepod","Large Copepod"),
                     Shelf_Type = "Inshore",
                     Avg_D_Int_Abundance = 0,
                     YearSeason = c("2024 Winter","2024 Winter","2024 Summer"))

zoop_data_full_delta_3 = rbind(zoop_data_full_delta_3, padding)

zoop_data_full_delta_3 = zoop_data_full_delta_3 %>%
  slice(1:12,28,13:14,29,15:22,30,23:27) %>%
  group_by(Species, Shelf_Type) %>%
  mutate(Delta = ifelse(row_number() == 1,
                        0,
                        Avg_D_Int_Abundance - lag(Avg_D_Int_Abundance, 1))) %>%
  mutate(Delta = ifelse(Delta > 0,
                        log10(Delta),
                        -1 * log10(abs(Delta))))

zoop_data_full_delta_3$Delta[1:6] = 0
zoop_data_full_delta_3$YearSeason = factor(zoop_data_full_delta_3$YearSeason, levels = c("2023 Spring", "2023 Fall", "2024 Winter", "2024 Spring", "2024 Summer"), ordered = T)

#####

ggplot() + 
  geom_boxplot(data = zoop_data_full_2, aes(x = Species, fill = Species, y = D_Int_Abundance)) + 
  scale_fill_viridis_d(guide = NULL, begin = 0.2) +
  scale_y_continuous(trans="log10") +
  labs(y = "Log10 of Concentration (individuals/m^3)") +
  facet_grid(rows=vars(Shelf_Type), cols=vars(Season))
ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Seasonal_Concentration_Shelf_Boxplot.png", scale = 2)

ggplot() + 
  geom_col(dat = zoop_data_full_delta_3, position = position_dodge(), aes(x = Species, y = Delta, group = YearSeason, fill = YearSeason)) +
  scale_fill_viridis_d(
    breaks = c("2023 Spring", "2023 Fall", "2024 Winter", "2024 Spring", "2024 Summer")
  ) +
  labs(x = "Species",
       y = "log10 of Change in Abundance",
       fill = "Year and Season") +
  facet_grid(~Shelf_Type)
ggsave("H:/dm1679/Data/Glider Data/Statistics Plots/RMI_Concentration_Change_Shelf_Type_Plot.png", scale = 2)

