import excel ///
  using "Rawdata/Wuhan_case_data.xlsx", ///
  clear firstrow case(lower)
drop if missing(id)
rename latitude _Y
rename longitude _X
gen huanan_flag = cond(huanan_linked=="yes",1,0)
rename id caseid
save "Datasets/Wuhan_case_data.dta", replace
