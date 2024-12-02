* IUCN range of M. plicata
use "Datasets/Chiroptera_betacov_index.dta", clear
gen mops_plicata_flag = cond(_ID==1136, 1, 0)
grmap mops_plicata_flag ///
  using "Datasets/Chiroptera_betacov_adj_shp.dta", ///
  id(_ID) polyfirst clmethod(unique) ///
  fcolor(none purple) ocolor(none purple) ///
  polygon(data("Datasets/gadm41_eastern_hemisphere_shp.dta") ///
          fcolor(eggshell) ocolor(black) osize(vthin)) ///
  plotregion(margin(0 0 0 -5)) ///
  graphregion(color(ltblue*0.33)) legend(off) ///
  name(mplicata_map, replace)
graph export "Figures/IUCN range of M. plicata.tif", replace

* IUCN range of R. pusillus
gen rpusillus_flag = cond(_ID==633, 1, 0)
grmap rpusillus_flag ///
  using "Datasets/Chiroptera_betacov_adj_shp.dta", ///
  id(_ID) polyfirst clmethod(unique) ///
  fcolor(none orange) ocolor(none orange) ///
  polygon(data("Datasets/gadm41_eastern_hemisphere_shp.dta") ///
          fcolor(eggshell) ocolor(black) osize(vthin)) ///
  plotregion(margin(0 0 0 -5)) ///
  graphregion(color(ltblue*0.33)) legend(off) ///
  name(rpusillus_map, replace)
graph export "Figures/IUCN range of R. pusillus.tif", replace
  
* Extant status for bats carryDatasetsing SARS-related viruses 
gen extant_flag = cond(extant_status=="definite", 1, 2)
grmap extant_flag if sarbeco_flag==1 ///
  using "Datasets/Chiroptera_betacov_adj_shp.dta", ///
  id(_ID) polyfirst clmethod(unique) ///
  fcolor(green orange) ocolor(none none) ///
  polygon(data("Datasets/gadm41_eastern_hemisphere_shp.dta") ///
          fcolor(eggshell) ocolor(black) osize(vthin)) ///
  plotregion(margin(0 0 0 -5)) ///
  graphregion(color(ltblue*0.33)) legend(off) ///
  name(sarbeco_bats_map, replace)
graph export "Figures/Extant Status of Sarbeco-Carrying Bats.tif", replace

* Extant status for bats carrying MERS-related viruses
grmap extant_flag if merbeco_flag==1 ///
  using "Datasets/Chiroptera_betacov_adj_shp.dta", ///
  id(_ID) polyfirst clmethod(unique) ///
  fcolor(green orange) ocolor(none none) ///
  polygon(data("Datasets/gadm41_world_streamlined_shp.dta") ///
          fcolor(eggshell) ocolor(black) osize(vthin)) ///
  plotregion(margin(0 0 0 -5)) ///
  graphregion(color(ltblue*0.33)) legend(off) ///
  name(merbeco_bats_map, replace)
graph export "Figures/Extant Status of Sarbeco-Carrying Bats.tif", replace

* Extant status for bats carrying covid-related viruses
tab extant_flag if sarscov2r_flag==1
grmap sarscov2r_flag ///
  using "Datasets/Chiroptera_betacov_adj_shp.dta", ///
  id(_ID) polyfirst clmethod(unique) ///
  fcolor(none green) ocolor(none none) ///
  polygon(data("Datasets/gadm41_southern_asia_borders_shp.dta") ///
          fcolor(eggshell) ocolor(black) osize(vthin)) ///
  plotregion(margin(-150 0 0 -25)) ///
  graphregion(color(ltblue*0.33)) legend(off) ///
  name(covid_bats_map, replace)
graph export "Figures/Extant Status of COVID-Related Bats.tif", replace
