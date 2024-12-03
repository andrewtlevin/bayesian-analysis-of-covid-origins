* Import World Bank data on GDP per capita as of 2019
local dirname = "Global Bat Viral Research"
import excel using "`dirname'/World Bank 2019 GDPPC.xlsx", ///
  clear sheet("Data") firstrow case(lower)
save "Temp/GDPPC_2019.dta", replace
  
* Import World Bank population data as of 2019
* Note: this spreadsheet also includes GADM41 shapefile _ID 
local dirname = "Global Bat Viral Research"
import excel using "`dirname'/World Bank 2019 population data.xlsx", ///
  clear firstrow case(lower)
rename _id _ID  
save "Temp/population_2019.dta", replace

* Import bat virus research data from Phelps et al. (2010)
local dirname = "Global Bat Viral Research"
import excel using "`dirname'/Phelps et al. 2019 Table S4.xlsx", ///
  clear sheet("Data") firstrow case(lower)
keep country isoalpha bat_covirus_papers 

* Drop Antarctica and two small islands
list country if missing(isoalpha)
drop if missing(isoalpha)

* Combine data for China, Hong Kong & Macao
sort isoalpha country
by isoalpha: gen idvar = _n
by isoalpha: egen batcov_papers = total(bat_covirus_papers) 
keep if idvar==1
drop idvar bat_covirus_papers

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
* Note: the Dutch part of St. Maarten gets dropped at this stage
merge 1:1 isoalpha ///
 using "Temp/population_2019.dta"
keep if _merge==3 

* Analyze data
gen batcov_research = cond(batcov_papers >=5, batcov_papers, 0)
egen tot_batcov_research = total(batcov_research)
gen pct_batcov_research = 100*batcov_research/tot_batcov_research
gen usa_resval = cond(isoalpha=="USA", batcov_research, 0)
egen usa_research = max(usa_resval)
gen tot_nonusa_research = tot_batcov_research - usa_research
gen pct_nonusa_research = cond(isoalpha=="USA", 0, ///
  100*batcov_research/tot_nonusa_research)
gen batcov_risk = batcov_research/gdppc_2019
gen usa_riskval = cond(isoalpha=="USA", batcov_risk, 0)
egen usa_risk = max(usa_riskval)
gen batcov_risk_index = batcov_risk/usa_risk
egen tot_batcov_risk = total(batcov_risk)
gen pct_batcov_risk = 100*batcov_risk/tot_batcov_risk
gen pct_nonusa_risk = cond(isoalpha=="USA", 0, ///
  100*batcov_risk/(tot_batcov_risk-usa_risk))
gen gdppc_th = 0.001*gdppc_2019
format pct_batcov_research pct_nonusa_research %3.1f
format pct_batcov_risk pct_nonusa_risk %3.1f
format batcov_risk_index %4.2f
format gdppc_2019 %7.0fc
format gdppc_th %5.1fc
gsort - pct_batcov_risk
gen ccode = _n
labmask ccode, values(country)
tabstat batcov_research ///
  gdppc_2019 batcov_risk_index ///
  pct_batcov_research pct_nonusa_research ///
  pct_batcov_risk pct_nonusa_risk ///
  if batcov_research > 0, by(ccode) format stat(sum)

* Make illustrative maps 
replace batcov_research=. if batcov_research==0
grmap batcov_research ///
  using "GADM41/gadm41_world_streamlined_shp.dta", ///
  id(_ID) clmethod(custom) clbreaks(5 10 25 50 100 200 500) ///
  fcolor(Reds) ndfcolor(eggshell) ///
  graphregion(color(ltblue*0.33)) ///
  plotregion(margin(-80 -40 0 -5)) ///
  legend(label(1 "Less Than 5") label(2 "5 to 9") ///
    label(3 "10 to 24") label(4 "25 to 49") ///
    label(5 "50 to 99") label(6 "100 to 199") ///
	label(7 "More than 200") size(medsmall) ///
    title("Research Papers" "Posted in PubMed", ///
	      size(medsmall))  /// 
	bmargin(20 0 5 0) ///
    region(lwidth(thick) lcolor(black) fcolor(white))) ///
  name(batcov_research, replace)
graph export "../../Figures/batcov_research_map.tif", replace

replace batcov_risk_index = . if batcov_risk_index < 0.25
grmap batcov_risk_index ///
  using "GADM41/gadm41_world_streamlined_shp.dta", ///
  id(_ID) clmethod(custom) clbreaks(.25 0.5 0.75 1 10) ///
  fcolor(Reds) ndfcolor(eggshell) ///
  graphregion(color(ltblue*0.33)) ///
  plotregion(margin(-80 -40 0 -5)) ///
  legend(label(1 "Less Than 0.25") label(2 "0.25 to 0.5") ///
    label(3 "0.5 to 0.75") label(4 "0.75 to 1.5") ///
	label(5 "More than 1.5") size(medium) ///
    title("Risk Assessment Index", size(medsmall))  /// 
	bmargin(20 0 5 0) ///
    region(lwidth(thick) lcolor(black) fcolor(white))) ///
  name(batcov_risk, replace)
graph export "../../Figures/batcov_risk_map.tif", replace
