* Import global shapefile
import delimited using "Shapedata/gadm41_world_shp.csv", ///
  clear delim(",") varnames(1) case(preserve)
sort _ID shape_order  
save "Maps/gadm41_world_shp.dta", replace

* Import Country-ISO crosswalk
import excel using "Excel/Index of isoalpha by country.xlsx", ///
  clear firstrow case(lower)
save "Temp/country_isoalpha_index.dta", replace

* Import country & affiliation for 14 records with missing author affiliations
import excel using "Excel/PMID lead-author addendum (14 records).xlsx", ///
  clear firstrow case(lower)
save "Temp/addendum_leadauthor_affiliations.dta", replace

* Import PubMed records
import delimited xstring ///
  using "Excel/PubMed Batcov Research (2015-19).txt", ///
  clear delim("!") emptylines(skip) stringcols(_all) stripquotes(yes) varnames(nonames)
  
* Identify PMID of each article
gen pmid_flag = cond(substr(xstring,1,4)=="PMID", 1, 0)  
gen pmid_num = cond(pmid_flag, real(substr(xstring,strpos(xstring,"-")+1,.)),.)
gen rec_num = sum(pmid_flag)

* Identify authors of each article
drop if substr(xstring,1,4)=="AUID"
gen fauthor_flag = cond(substr(xstring,1,3)=="FAU", 1, 0)
gen author_flag = cond(substr(xstring,1,2)=="AU", 1, 0)
sort rec_num 
by rec_num: gen irec = _n
by rec_num: egen pmid = max(pmid_num)
by rec_num: gen author_num = sum(author_flag)
by rec_num: gen fauthor_num = sum(fauthor_flag)
gen dev_flag = author_num - fauthor_num
tab dev_flag if author_flag+fauthor_flag==0

* Identify affiliation of each author
gen affil_flag = cond(substr(xstring,1,2)=="AD", 1, 0)
gen lang_flag = cond(substr(xstring,1,2)=="LA", 1, 0)
replace affil_flag = 1 if affil_flag[_n-1]==1 ///
  & author_flag+fauthor_flag+lang_flag==0
  
* Identify 14 papers that do not provide any author affiliations
by rec_num: egen check_flag = max(affil_flag)
tab check_flag if irec==1
list pmid if check_flag==0 & irec==1, noobs
keep if affil_flag==1 | check_flag==0 & irec==1
replace xstring = "" if check_flag==0
replace author_num = 1 if check_flag==0
keep rec_num pmid author_num xstring

* Reshape multiple lines into one affiliation record per author
sort rec_num author_num
by rec_num author_num: gen line_num = _n
reshape wide xstring, i(rec_num pmid author_num) j(line_num)
gen affiliation = xstring1
forvalues ii=2/10 {
  quietly replace affiliation = affiliation + " " + xstring`ii'
}
drop xstring*
replace affiliation = stritrim(affiliation) 

* Tabulate national affiliations of authors
quietly gen country = "China" ///
  if strpos(affiliation,"China")+strpos(affiliation,"Hong Kong") > 0 | pmid==29887526
quietly replace country = "USA" ///
  if strpos(affiliation,"USA") + strpos(affiliation,"United States") ///
    + strpos(affiliation,", CA") + strpos(affiliation,", NY") ///
    + strpos(affiliation,", MA") + strpos(affiliation,", MD") ///
    + strpos(affiliation,", NH") + strpos(affiliation,", OH") ///
	+ strpos(affiliation,", TN") + strpos(affiliation,", WA") ///
	+ strpos(affiliation,", OK") + strpos(affiliation,"Alabama") ///
	+ strpos(affiliation,"California") + strpos(affiliation,"New York") ///
	+ strpos(affiliation,"North Carolina") + strpos(affiliation,"Washington") > 0
quietly replace country = "Australia" if strpos(affiliation,"Australia")>0
quietly replace country = "Austria" if strpos(affiliation,"Austria")>0
quietly replace country = "Bangladesh" if strpos(affiliation,"Bangladesh")>0
quietly replace country = "Brazil" if strpos(affiliation,"Brazil")>0
quietly replace country = "Cambodia" if strpos(affiliation,"Cambodia")>0
quietly replace country = "Canada" if strpos(affiliation,"Canada")>0
quietly replace country = "Costa Rica" if strpos(affiliation,"Costa Rica")>0
quietly replace country = "Croatia" if strpos(affiliation,"Croatia")>0
quietly replace country = "Denmark" if strpos(affiliation,"Denmark")>0
quietly replace country = "Egypt" if strpos(affiliation,"Egypt")>0
quietly replace country = "France" if strpos(affiliation,"France")>0
quietly replace country = "Germany" if strpos(affiliation,"Germany") ///
    + strpos(affiliation,"Berlin") + strpos(affiliation,"Hannover")>0
quietly replace country = "Ghana" if strpos(affiliation,"Ghana")>0
quietly replace country = "Hungary" if strpos(affiliation,"Hungary")>0
quietly replace country = "India" if strpos(affiliation,"India")>0
quietly replace country = "Ireland" if strpos(affiliation,"Ireland")>0
quietly replace country = "Italy" if strpos(affiliation,"Italy")>0
quietly replace country = "Japan" if strpos(affiliation,"Japan") ///
	 + strpos(affiliation,"Tokyo")>0
quietly replace country = "Jordan" if strpos(affiliation,"Jordan")>0
quietly replace country = "Kenya" if strpos(affiliation,"Kenya")>0
quietly replace country = "Korea" if strpos(affiliation,"Korea")>0
quietly replace country = "Luxembourg" if strpos(affiliation,"Luxembourg")>0
quietly replace country = "Madagascar" if strpos(affiliation,"Madagascar")>0
quietly replace country = "Malaysia" if strpos(affiliation,"Malaysia")>0
quietly replace country = "Laos" if strpos(affiliation,"Lao ")>0
quietly replace country = "Netherlands" if strpos(affiliation,"Netherlands")>0
quietly replace country = "Nigeria" if strpos(affiliation,"Nigeria")>0
quietly replace country = "Poland" if strpos(affiliation,"Poland")>0
quietly replace country = "Portugal" if strpos(affiliation,"Portugal")>0
quietly replace country = "Saudi Arabia" if strpos(affiliation,"Saudi Arabia")>0
quietly replace country = "Singapore" if strpos(affiliation,"Singapore")>0
quietly replace country = "Slovenia" if strpos(affiliation,"Slovenia")>0
quietly replace country = "Spain" if strpos(affiliation,"Spain")>0
quietly replace country = "South Africa" if strpos(affiliation,"South Africa") ///
     + strpos(affiliation,".edu.sa")>0
quietly replace country = "Sri Lanka" if strpos(affiliation,"Sri Lanka")>0
quietly replace country = "Switzerland" if strpos(affiliation,"Switzerland")>0
quietly replace country = "Taiwan" if strpos(affiliation,"Taiwan")>0
quietly replace country = "Thailand" if strpos(affiliation,"Thailand")>0
quietly replace country = "UAE" if strpos(affiliation,"UAE") ///
     + strpos(affiliation,"United Arab Emirates")>0
quietly replace country = "Uganda" if strpos(affiliation,"Uganda")>0
quietly replace country = "United Kingdom" if strpos(affiliation,"United Kingdom") ///
     + strpos(affiliation,"UK")>0
quietly replace country = "Uruguay" if strpos(affiliation,"Uruguay")>0
quietly replace country = "Vietnam" if strpos(affiliation,"Viet")>0
quietly replace country = "Zimbabwe" if strpos(affiliation,"Zimbabwe")>0

* Add country & lead-author affiliation for 14 records with missing affiliations
merge m:1 pmid using "Temp/addendum_leadauthor_affiliations.dta", update replace
drop _merge

* Merge with ISO identifiers
merge m:1 country using "Temp/country_isoalpha_index.dta"
drop if _merge==2
keep pmid author_num country isoalpha affiliation 
order pmid author_num country isoalpha affiliation
save "Datasets/PubMed BatCov Records.dta", replace
