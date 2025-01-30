* Import World Bank data on GDP per capita as of 2019
import excel using "Excel/World Bank 2019 GDPPC.xlsx", ///
  clear sheet("Data") firstrow case(lower)
save "Temp/GDPPC_2019.dta", replace
  
* Import World Bank population data as of 2019
* Note: this spreadsheet also includes GADM41 shapefile _ID 
import excel using "Excel/World Bank 2019 population data.xlsx", ///
  clear firstrow case(lower)
rename _id _ID  
save "Temp/population_2019.dta", replace

* Merge bat virus research data with GDP per capita
use "Datasets/PubMed BatCov Records.dta", clear
keep if author_num==1
sort country
by country: gen irec = _n
by country: egen lead_authors = total(author_num)
keep if irec==1
keep isoalpha country lead_authors

* Merge with data on gdp per capita
* Note: Taiwan gdp per capita obtained from IMF 
*       _merge = 1 for small islands & Kosovo
*       _merge = 2 for World Bank aggregates
merge 1:1 isoalpha using "Temp/GDPPC_2019.dta"
list isoalpha country if _merge==1
list isoalpha countryname if _merge==2
keep if _merge==3 | isoalpha=="TWN"
replace gdppc_2019 = 55244 if isoalpha=="TWN"
drop _merge countryname

* Merge with population data 
merge 1:1 isoalpha using "Temp/population_2019.dta"

* Compute US research and risk index to serve as benchmarks
rename lead_authors batcov_research 
gen usa_resval = cond(isoalpha=="USA", batcov_research, 0)
egen usa_research = max(usa_resval)
gen usa_riskval = cond(isoalpha=="USA", batcov_research/gdppc_2019, 0)
egen usa_risk = max(usa_riskval)

* Compute country-specific measures of research and risk
replace batcov_research = 0 if missing(batcov_research)
gen batcov_risk = cond(missing(gdppc_2019), 0, batcov_research/gdppc_2019)
gen batcov_risk_index = batcov_risk/usa_risk

* Compute country-specific shares of global research & risk
egen tot_batcov_research = total(batcov_research)
egen tot_batcov_risk = total(batcov_risk)
gen pct_batcov_research = 100*batcov_research/tot_batcov_research
gen pct_batcov_risk = 100*batcov_risk/tot_batcov_risk

* Compute alternative index excluding countries with minimal research
gen alt_risk = cond(batcov_research==1, 0, batcov_risk)
egen tot_alt_risk = total(alt_risk)
gen pct_alt_risk = 100*alt_risk/tot_alt_risk

* Tabulate results
gen gdppc_th = 0.001*gdppc_2019
format pct_batcov_research pct_batcov_risk pct_alt_risk %3.1f
format batcov_risk_index %4.2f
format gdppc_2019 %7.0fc
format gdppc_th %5.1fc
gsort - batcov_risk_index
gen ccode = _n
labmask ccode, values(country)
tabstat batcov_research ///
  gdppc_2019 batcov_risk_index ///
  pct_batcov_research pct_batcov_risk pct_alt_risk ///
  if batcov_research > 0, by(ccode) format stat(sum)

* Make illustrative maps 
quietly replace batcov_research = . if batcov_research < 0.1
quietly colorpalette HTML, global
grmap batcov_research ///
  using "Maps/gadm41_world_shp.dta", ///
  id(_ID) clmethod(custom) clbreaks(0 4 9 20 100) ///
  fcolor($LemonChiffon $Khaki $LightPink $LightCoral ) ndfcolor($GhostWhite) ///
  graphregion(color(ltblue*0.33)) ///
  plotregion(margin(-80 -40 0 -5)) ///
  legend(order(6 5 4 3 2 1) ///
    label(1 "None") label(2 "1 to 4") ///
    label(3 "5 to 9") label(4 "10 to 20") ///
	label(5 "More than 20") size(medsmall) ///
    title("{bf:Research Papers}" "{bf:Posted in PubMed}", ///
	      size(medsmall))  /// 
	bmargin(80 0 4 0) ///
    region(lwidth(thick) lcolor(black) fcolor(white))) ///
  name(batcov_research, replace)
graph export "Figures/batcov_research_map.tif", replace

quietly replace batcov_risk_index = . if batcov_risk_index < 0.1
grmap batcov_risk_index ///
  using "Maps/gadm41_world_shp.dta", ///
  id(_ID) clmethod(custom) clbreaks(0 0.25 0.5 1 5) ///
  fcolor($LemonChiffon $Khaki $LightPink $LightCoral) ndfcolor($GhostWhite) ///   
  graphregion(color(ltblue*0.33)) ///
  plotregion(margin(-80 -40 0 -5)) ///
  legend(order(6 5 4 3 2 1) ///
    label(1 "None") label(2 "0.1 to 0.25") label(3 "0.25 to 0.5") ///
    label(4 "0.5 to 1") label(5 "More than 1") size(medium) ///
    title("{bf:Risk Index}", size(medsmall))  /// 
	bmargin(85 0 4 0) ///
    region(lwidth(thick) lcolor(black) fcolor(white))) ///
  name(batcov_risk, replace)
graph export "Figures/batcov_risk_map.tif", replace
