################################################################################
### figure_3.R                                                               ###
### Figure 3: TV fee compliance geographical distribution, by decade.        ###
### Input:  data/derived/maps_tv_tax.dta (written by code/05_merge.do)       ###
###         data/raw/shapefiles/Com2011_WGS84.shp, Reg2011_WGS84.shp         ###
### Output: output/figures/figure_3.png                                      ###
### Source: original maps.R, lines 1-186. Only paths changed; the unused     ###
###         library() calls are commented out; the second ggsave to the      ###
###         authors' Overleaf folder is removed.                             ###
### Run from master.do (root passed as argument) or set `root` below.        ###
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

## import layers of italy administrative units ##

# municipalities ##
munis <- st_read("Com2011_WGS84.shp")

# provinces #
regs <- st_read("Reg2011_WGS84.shp")

# main data #
main_data <- read_stata(file.path(derived, "maps_tv_tax.dta"))


## merge main data with shapefiles ##

# maps data #
maps <- merge(x = munis, y = main_data, by.x= "PRO_COM", by.y = "codcom", all.x = T)



#### Plots: TV tax compliance rate * 100, by decade ####

# 1950 #
plot_tvtax_50 <- ggplot(data = maps) +
  geom_sf(aes(fill = d100f_tv_1950), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, name = "TV tax compliance", na.value = "white", limits = c(0, 100), breaks = seq(0, 100, 20)) +  # Use the "Blues" palette with normal direction
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



# 1960 #
plot_tvtax_60 <- ggplot(data = maps) +
  geom_sf(aes(fill = d100f_tv_1960), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, na.value = "white") +  # Use the "Blues" palette with normal direction
  geom_sf(data = regs, fill = NA, color = "black", size = 1) +  # Add borders from regs_cn
  theme_minimal() +
  theme(panel.border = element_blank(),  # Remove panel border
        axis.title = element_blank(),    # Remove axis titles
        axis.line = element_blank(),    # Remove axis lines
        axis.text = element_blank(),    # Remove axis text
        axis.ticks = element_blank(),   # Remove axis ticks
        panel.grid = element_blank(),
        plot.margin = margin(0, 0, 0, 0, "cm"))   # Remove grid lines


# 1970 #
plot_tvtax_70 <- ggplot(data = maps) +
  geom_sf(aes(fill = d100f_tv_1970), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, na.value = "white") +  # Use the "Blues" palette with normal direction
  geom_sf(data = regs, fill = NA, color = "black", size = 1) +  # Add borders from regs_cn
  theme_minimal() +
  theme(panel.border = element_blank(),  # Remove panel border
        axis.title = element_blank(),    # Remove axis titles
        axis.line = element_blank(),    # Remove axis lines
        axis.text = element_blank(),    # Remove axis text
        axis.ticks = element_blank(),   # Remove axis ticks
        panel.grid = element_blank(),
        plot.margin = margin(0, 0, 0, 0, "cm"))   # Remove grid lines


# 1980 #
plot_tvtax_80 <- ggplot(data = maps) +
  geom_sf(aes(fill = d100f_tv_1980), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, na.value = "white") +  # Use the "Blues" palette with normal direction
  geom_sf(data = regs, fill = NA, color = "black", size = 1) +  # Add borders from regs_cn
  theme_minimal() +
  theme(panel.border = element_blank(),  # Remove panel border
        axis.title = element_blank(),    # Remove axis titles
        axis.line = element_blank(),    # Remove axis lines
        axis.text = element_blank(),    # Remove axis text
        axis.ticks = element_blank(),   # Remove axis ticks
        panel.grid = element_blank(),
        plot.margin = margin(0, 0, 0, 0, "cm"))   # Remove grid lines


# 1990 #
plot_tvtax_90 <- ggplot(data = maps) +
  geom_sf(aes(fill = d100f_tv_1990), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, na.value = "white") +  # Use the "Blues" palette with normal direction
  geom_sf(data = regs, fill = NA, color = "black", size = 1) +  # Add borders from regs_cn
  theme_minimal() +
  theme(panel.border = element_blank(),  # Remove panel border
        axis.title = element_blank(),    # Remove axis titles
        axis.line = element_blank(),    # Remove axis lines
        axis.text = element_blank(),    # Remove axis text
        axis.ticks = element_blank(),   # Remove axis ticks
        panel.grid = element_blank(),
        plot.margin = margin(0, 0, 0, 0, "cm"))   # Remove grid lines


# 2000 #
plot_tvtax_00 <- ggplot(data = maps) +
  geom_sf(aes(fill = d100f_tv_2000), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, na.value = "white") +  # Use the "Blues" palette with normal direction
  geom_sf(data = regs, fill = NA, color = "black", size = 1) +  # Add borders from regs_cn
  theme_minimal() +
  theme(panel.border = element_blank(),  # Remove panel border
        axis.title = element_blank(),    # Remove axis titles
        axis.line = element_blank(),    # Remove axis lines
        axis.text = element_blank(),    # Remove axis text
        axis.ticks = element_blank(),   # Remove axis ticks
        panel.grid = element_blank(),
        plot.margin = margin(0, 0, 0, 0, "cm"))   # Remove grid lines

# 2010 #
plot_tvtax_10 <- ggplot(data = maps) +
  geom_sf(aes(fill = d100f_tv_2010), color = NA, size = 0) +  # Set color = NA to remove borders
  scale_fill_distiller(palette = "Blues", direction = 1, na.value = "white") +  # Use the "Blues" palette with normal direction
  geom_sf(data = regs, fill = NA, color = "black", size = 1) +  # Add borders from regs_cn
  theme_minimal() +
  theme(panel.border = element_blank(),  # Remove panel border
        axis.title = element_blank(),    # Remove axis titles
        axis.line = element_blank(),    # Remove axis lines
        axis.text = element_blank(),    # Remove axis text
        axis.ticks = element_blank(),   # Remove axis ticks
        panel.grid = element_blank(),
        plot.margin = margin(0, 0, 0, 0, "cm"))   # Remove grid lines

# common plot #
ggsave(file.path(figures, "figure_3.png"),
       ggarrange(plot_tvtax_50, NULL,
                 plot_tvtax_60, NULL,
                 plot_tvtax_70, NULL,
                 plot_tvtax_80, NULL,
                 plot_tvtax_90, NULL,
                 plot_tvtax_00, NULL,
                 plot_tvtax_10,
                 common.legend = TRUE, legend="bottom", ncol = 6, nrow = 3, align = "hv",
                 widths = c(1,-0.2,1,-0.2,1,-0.2,1),
                 labels = c("1950","","1960","","1970","","1980","","1990","","2000","","2010")),
       dpi = 300, width = 9, height = 9, scale = 1)
