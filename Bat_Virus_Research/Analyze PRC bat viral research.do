* Tabulate PRC location for lead authors and other authors

use "Datasets/PubMed BatCov Records.dta", clear
keep if country=="China"
drop country isoalpha
gen author_type = cond(author_num==1, 1, 2)
gen wuhan_flag = cond(strpos(affiliation,"Wuhan")>0, 1, 0)
gen wiv_flag = cond(strpos(affiliation,"Wuhan Institute of Virology")>0, 1, 0)
gen wuhanuniv_flag = cond(strpos(affiliation,"Wuhan University")>0, 1, 0)
gen huazhong_flag = cond(strpos(affiliation,"Huazhong")>0, 1, 0)
gen affil_flag = cond(wiv_flag, 1, ///
                 cond(huazhong_flag, 2, ///
				 cond(wuhanuniv_flag, 3, 4)))
table author_type, stat(fvfrequency affil_flag)	stat(frequency)			 
table author_type, ///
  stat(freq) stat(fvfrequency wuhan_flag) stat(fvpercent wuhan_flag)
list pmid if author_num==1 & wiv_flag, noobs
