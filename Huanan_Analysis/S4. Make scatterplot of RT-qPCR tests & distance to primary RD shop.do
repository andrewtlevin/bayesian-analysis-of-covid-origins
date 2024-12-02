* Get data on RT-qPCR tests and distances to raccoon dog sellers (distRD)
use "Datasets/Huanan vendor to RD629 distances.dta", clear
keep if idate==4
merge 1:1 _ID using "Datasets/environmental_test_vendor_index.dta"
keep if _merge==3 & !missing(totpos) & !missing(totneg) 
drop _merge
gen pos_flag = cond(totpos > 0,1, 0)

* Categorize observations into deciles of distRD
gen obs = 1
gen distRD = 1000*geodist_RD629
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
by decile_id: egen decile_avgprob = mean(pos_prob)
by decile_id: egen decile_avgdistRD = mean(distRD)
gen decile_distRD = cond(decile_avgdistRD > 75, 75, decile_avgdistRD)

* Binned scatterplot 
quietly colorpalette HTML, global
twoway bar decile_avgprob decile_distRD if decile_ii==1, ///
      barwidth(5) fcolor($DarkTurquoise) lcolor(none) ///
      ytitle("Probability (%)" " ", placement(n) orient(horizontal) height(10)) ///
	  ylabel(0 5 10 15 20 25 30) yscale(r(0 30) noextend titlegap(-20)) ///
	  xtitle("Mean Distance from Primary Raccoon Dog Shop {it:(m)}") ///
	  xlabel(0(15)60 75 "75+", nogrid) xmtick(0(5)75) plotregion(margin(0 0 0 10)) ///
 || pci `mean_prob' 0 `mean_prob' 77, ///
        lpattern(dash) lwidth(0.7) lcolor($DarkViolet) legend(off) ///
 || scatteri `mean_prob' 60 (1) "{it:Mean Probability}", ///
    msymbol(none) mlabsize(medium) mlabcolor($DarkViolet) ///
    name(decile_RD629_graph, replace)
graph export "Figures/Binned_Tests_and RD629_Distances.tif", replace  
  
