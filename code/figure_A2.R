################################################################################
### figure_A2.R                                                              ###
### Figure A.2: Geographical distribution of social capital measures at the  ###
###             provincial level.                                            ###
### Input:  data/derived/maps_sc_provs.dta (written by code/05_merge.do)     ###
###         data/raw/shapefiles/Prov2011_WGS84.shp, Reg2011_WGS84.shp        ###
### Output: output/figures/figure_A2a.png (blood donations)                  ###
###         output/figures/figure_A2b.png (CONI associations)                ###
###         output/figures/figure_A2c.png (newspapers sold)                  ###
###         output/figures/figure_A2d.png (trust)                            ###
### Source: original maps.R, lines 1-51 and 260-369. Only paths changed; the ###
###         unused library() calls are commented out; the second ggsave to   ###
###         the authors' Overleaf folder is removed; the CONI block, which   ###
###         the original ran twice with identical code, runs once.           ###
################################################################################
rm(list=ls())
Sys.setenv(LANG = "en_US.UTF-8")
# library(plyr)        # not used
library(dplyr)
# library(stargazer)   # not used
library(sf)
# library(tmap)        # not used
library(ggplot2)
# library(lfe)         # not used (and archived on CRAN)
library(haven)
# library(units)       # not used
# library(readxl)      # not used
# library(data.table)  # not used
library(ggpubr)

#### directory ####
args <- commandArgs(trailingOnly = TRUE)
root <- if (length(args) >= 1) args[1] else "C:/path/to/package"   # <- edit if run by hand
maps <- file.path(root, "data", "raw", "shapefiles")
derived <- file.path(root, "data", "derived")
figures <- file.path(root, "output", "figures")
setwd(maps)


#### import and merge data ####

# regions #
regs <- st_read("Reg2011_WGS84.shp")

# provinces #
provs <- st_read("Prov2011_WGS84.shp")

# main data prov #
main_data_prov <- read_stata(file.path(derived, "maps_sc_provs.dta"))

# merge #
maps_sc_prov <- merge(x = provs, y = main_data_prov, by.x= "COD_PROV", by.y = "prov", all.x = T)



#### Plots: donations, CONI, news and trust ####
donations <- ggplot(data = maps_sc_prov) +
  geom_sf(aes(fill = donation), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Avg. N. of Blood donations / 1000 inhabitants", na.value = "white") +  # Use the "Blues" palette with normal direction
  geom_sf(data = regs, fill = NA, color = "black", size = 1) +  # Add borders from regs_cn
  theme_minimal() +
  theme(panel.border = element_blank(),  # Remove panel border
        axis.title = element_blank(),    # Remove axis titles
        axis.line = element_blank(),    # Remove axis lines
        axis.text = element_blank(),    # Remove axis text
        axis.ticks = element_blank(),   # Remove axis ticks
        panel.grid = element_blank(),
        legend.title = element_text(size = 14),
        plot.margin = margin(0, 0, 0, 0, "cm"))   # Remove grid lines
ggsave(file.path(figures, "figure_A2a.png"),
       ggarrange(donations,
                 common.legend = TRUE, legend="bottom", ncol = 1, nrow = 1, align = "hv"),
       dpi = 300, width = 9, height = 9, scale = 1)

coni <- ggplot(data = maps_sc_prov) +
  geom_sf(aes(fill = coni_assoc), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Avg. N. of CONI associations / 1000 inhabitants", na.value = "white") +  # Use the "Blues" palette with normal direction
  geom_sf(data = regs, fill = NA, color = "black", size = 1) +  # Add borders from regs_cn
  theme_minimal() +
  theme(panel.border = element_blank(),  # Remove panel border
        axis.title = element_blank(),    # Remove axis titles
        axis.line = element_blank(),    # Remove axis lines
        axis.text = element_blank(),    # Remove axis text
        axis.ticks = element_blank(),   # Remove axis ticks
        panel.grid = element_blank(),
        legend.title = element_text(size = 14),
        plot.margin = margin(0, 0, 0, 0, "cm"))   # Remove grid lines
ggsave(file.path(figures, "figure_A2b.png"),
       ggarrange(coni,
                 common.legend = TRUE, legend="bottom", ncol = 1, nrow = 1, align = "hv"),
       dpi = 300, width = 9, height = 9, scale = 1)
# (the original repeated the CONI block above verbatim, original maps.R L305-325)

news <- ggplot(data = maps_sc_prov) +
  geom_sf(aes(fill = daily_newsp), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Avg. N. of non-sport newspapers sold / 1000", na.value = "white") +  # Use the "Blues" palette with normal direction
  geom_sf(data = regs, fill = NA, color = "black", size = 1) +  # Add borders from regs_cn
  theme_minimal() +
  theme(panel.border = element_blank(),  # Remove panel border
        axis.title = element_blank(),    # Remove axis titles
        axis.line = element_blank(),    # Remove axis lines
        axis.text = element_blank(),    # Remove axis text
        axis.ticks = element_blank(),   # Remove axis ticks
        panel.grid = element_blank(),
        legend.title = element_text(size = 14),
        plot.margin = margin(0, 0, 0, 0, "cm"))   # Remove grid lines
ggsave(file.path(figures, "figure_A2c.png"),
       ggarrange(news,
                 common.legend = TRUE, legend="bottom", ncol = 1, nrow = 1, align = "hv"),
       dpi = 300, width = 9, height = 9, scale = 1)

trust <- ggplot(data = maps_sc_prov) +
  geom_sf(aes(fill = trust), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Trust (WVS)", na.value = "white") +  # Use the "Blues" palette with normal direction
  geom_sf(data = regs, fill = NA, color = "black", size = 1) +  # Add borders from regs_cn
  theme_minimal() +
  theme(panel.border = element_blank(),  # Remove panel border
        axis.title = element_blank(),    # Remove axis titles
        axis.line = element_blank(),    # Remove axis lines
        axis.text = element_blank(),    # Remove axis text
        axis.ticks = element_blank(),   # Remove axis ticks
        panel.grid = element_blank(),
        legend.title = element_text(size = 14),
        plot.margin = margin(0, 0, 0, 0, "cm"))   # Remove grid lines
ggsave(file.path(figures, "figure_A2d.png"),
       ggarrange(trust,
                 common.legend = TRUE, legend="bottom", ncol = 1, nrow = 1, align = "hv"),
       dpi = 300, width = 9, height = 9, scale = 1)
