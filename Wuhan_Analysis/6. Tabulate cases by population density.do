use "Maps/Wuhan_narrowcore_popdensity.dta", clear
tab d3_flag

use "Datasets/Wuhan_narrowcore_cases.dta", clear
sort cluster onset_period
by cluster: gen icluster = _n
by cluster: gen ncluster = _N
keep if icluster==1 | missing(cluster)
drop icluster
merge m:1 _ID using "Maps/Wuhan_narrowcore_popdensity.dta"
tab d3_flag onset_period
