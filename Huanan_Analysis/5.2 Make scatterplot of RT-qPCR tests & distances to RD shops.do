* Get data on RT-qPCR tests and distances to raccoon dog sellers (distRD)
use "Datasets/Huanan vendor-raccoondog distances", clear
keep if idate==4
merge 1:1 _ID using "Datasets/environmental_test_vendor_index.dta"
keep if _merge==3 & !missing(totpos) & !missing(totneg) 
drop _merge
gen pos_flag = cond(totpos > 0,1, 0)

* Categorize observations into deciles of distRD
gen obs = 1
gen distRD = 1000*geodist_nearestRD
gen pos_prob = 100*pos_flag
sort distRD 
gen decile_id = min(10,floor((_n-1)/14)+1)
table decile_id, stat(total obs) stat(max distRD) stat(mean distRD pos_prob) ///
  nformat(%6.1f) nformat(%2.0f total) 
summ pos_prob, detail
local mean_prob = r(mean)
  
* Compute decile statistics  
sort decile_id
by decile_id: gen decile_ii = _n
by decile_id: gen decile_count = _N
by decile_id: egen decile_avgprob = mean(pos_prob)
by decile_id: egen decile_avgdistRD = mean(distRD)
gen decile_distRD = cond(decile_avgdistRD > 75, 75, decile_avgdistRD)
replace decile_avgprob = 0.25 if decile_avgprob==0
list decile_id decile_count decile_avgprob decile_distRD if decile_ii==1

* Binned scatterplot 
quietly colorpalette HTML, global
twoway bar decile_avgprob decile_distRD if decile_ii==1 & building=="West", ///
      barwidth(4) fcolor($LightSeaGreen) lcolor(none) ///
      ytitle("Probability (%)" " ", placement(n) orient(horizontal) height(10)) ///
	  ylabel(0 5 10 15 20 25 30 35) yscale(r(0 35) noextend titlegap(-25)) ///
	  xtitle("Mean Distance from Shops Selling Raccoon Dogs {it:(m)}") ///
	  xlabel(0(15)60 75 "75+", nogrid) xmtick(0(5)75) plotregion(margin(0 0 0 10)) ///
	  legend(label(1 "West Building Shops")) ///
 || bar decile_avgprob decile_distRD if decile_ii==1 & building=="East", ///
      barwidth(4) fcolor($MediumSlateBlue) lcolor(none) ///
      ytitle("Probability (%)" " ", placement(n) orient(horizontal) height(10)) ///
	  legend(label(2 "East Building Shops")) ///
 || pci `mean_prob' 0 `mean_prob' 77, ///
        lpattern(dash) lwidth(0.7) lcolor($Navy) ///
 || scatteri `mean_prob' 60 (1) "{it:Mean Probability}", ///
    msymbol(none) mlabsize(medium) mlabcolor($Navy) ///
    legend(ring(0) pos(2) order(1 2) region(lcolor(black) fcolor($White))) ///
    name(decile_graph, replace)
graph export "Figures/Binned Tests & Distances to RD Shops.tif", replace  
  
