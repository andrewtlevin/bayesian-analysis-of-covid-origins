* Extract bottom and left edges of each grid cell 
use "Maps/Wuhan_1km_grid_shp.dta", clear
keep if shape_order==5
keep _ID _X _Y
save "Temp/gridcell_edges.dta", replace

* Merge initial case data with horizontal gridlines
* and find left edges that are adjacent to initial cases
use "Temp/gridcell_edges.dta", clear
keep _X
duplicates drop
append using "Datasets/Wuhan_case_data.dta"
keep caseid _X
sort _X
gen edge_flag = cond(missing(caseid) & !missing(caseid[_n+1]), 1, 0)
gen edge_id = cond(!missing(caseid)|edge_flag==1, sum(edge_flag), .)
keep if !missing(edge_id)
sort edge_id _X
by edge_id: egen left_edge = min(_X)
drop if missing(caseid)
merge 1:1 caseid using "Datasets/Wuhan_case_data.dta"
keep caseid left_edge
save "Temp/cases_left_edges.dta", replace

* Merge initial case data with vertical gridlines
* and find bottom edges that are adjacent to initial cases
use "Temp/gridcell_edges.dta", clear
keep _Y
duplicates drop
append using "Datasets/Wuhan_case_data.dta"
keep caseid _Y
sort _Y
gen edge_flag = cond(missing(caseid) & !missing(caseid[_n+1]), 1, 0)
gen edge_id = cond(!missing(caseid)|edge_flag==1, sum(edge_flag), .)
keep if !missing(edge_id)
sort edge_id _Y
by edge_id: egen bottom_edge = min(_Y)
drop if missing(caseid)
keep caseid bottom_edge
save "Temp/cases_bottom_edges.dta", replace

* Combine edges and find ID of grid cell
use "Temp/cases_left_edges.dta", clear
merge 1:1 caseid using "Temp/cases_bottom_edges.dta"
drop _merge
rename left_edge _X
rename bottom_edge _Y
merge m:1 _X _Y using "Temp/gridcell_edges.dta"
drop if _merge<3
drop _merge _X _Y
merge 1:1 caseid ///
  using "Datasets/Wuhan_case_data.dta"
drop _merge
rename _X _PX
rename _Y _PY
save "Datasets/Wuhan_gridded_cases.dta", replace

* Make illustrative map
use "Datasets/Wuhan_gridded_cases.dta", clear
sort _ID
by _ID: gen icount = _n
by _ID: gen ncount = _N
count
keep if icount==1
grmap ncount using "Maps/Wuhan_1km_grid_shp.dta", ///
  id(_ID) clmethod(unique) fcolor(Accent) ocolor(none ..) ///
  name(Wuhan_gridded_cases, replace)


