################################################################################
### figure_A1.R                                                              ###
### Figure A.1: Geographical distribution of social capital measures at the  ###
###             municipal level.                                             ###
### Input:  data/derived/maps_sc_munis.dta (written by code/05_merge.do)     ###
###         data/raw/shapefiles/Com2011_WGS84.shp, Reg2011_WGS84.shp         ###
### Output: output/figures/figure_A1a.png (referendum turnout)               ###
###         output/figures/figure_A1b.png (European elections turnout)       ###
###         output/figures/figure_A1c.png (N. voluntary associations)        ###
### Source: original maps.R, lines 1-51 and 189-256. Only paths changed; the ###
###         unused library() calls are commented out; the second ggsave to   ###
###         the authors' Overleaf folder is removed.                         ###
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

# municipalities ##
munis <- st_read("Com2011_WGS84.shp")

# regions #
regs <- st_read("Reg2011_WGS84.shp")

# main data muni #
main_data_muni <- read_stata(file.path(derived, "maps_sc_munis.dta"))

# merge #
maps_sc_muni <- merge(x = munis, y = main_data_muni, by.x= "PRO_COM", by.y = "codcom", all.x = T)



#### Plots: civic ref and euro ####
maps_sc_muni$turnout_ref <- maps_sc_muni$turnout_ref*100
referendum <- ggplot(data = maps_sc_muni) +
  geom_sf(aes(fill = turnout_ref), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Avg. Referendum Turnout", na.value = "white", limits = c(0, 100)) +  # Use the "Blues" palette with normal direction
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
ggsave(file.path(figures, "figure_A1a.png"),
       ggarrange(referendum,
                 common.legend = TRUE, legend="bottom", ncol = 1, nrow = 1, align = "hv"),
       dpi = 300, width = 9, height = 9, scale = 1)

maps_sc_muni$turnout_europee <- maps_sc_muni$turnout_europee*100
european <- ggplot(data = maps_sc_muni) +
  geom_sf(aes(fill = turnout_europee), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Avg. European Elections Turnout", na.value = "white", limits = c(0, 100)) +  # Use the "Blues" palette with normal direction
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
ggsave(file.path(figures, "figure_A1b.png"),
       ggarrange(european,
                 common.legend = TRUE, legend="bottom", ncol = 1, nrow = 1, align = "hv"),
       dpi = 300, width = 9, height = 9, scale = 1)

civic <- ggplot(data = maps_sc_muni) +
  geom_sf(aes(fill = civic), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Avg. N. of Civic Associations p. 1000 inhabitants", na.value = "white") +  # Use the "Blues" palette with normal direction
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
ggsave(file.path(figures, "figure_A1c.png"),
       ggarrange(civic,
                 common.legend = TRUE, legend="bottom", ncol = 1, nrow = 1, align = "hv"),
       dpi = 300, width = 9, height = 9, scale = 1)
