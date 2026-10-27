********************************************************************************
*** 05_merge.do                                                              ***
*** Merges all sources into the municipality x decade analysis dataset.      ***
*** Inputs:  data/derived/controls_5111.dta                (01_controls_istat.do)
***          data/derived/n_voluntary_associations_wide_updt.dta  (04_...do)
***          data/derived/turnout_referendum_wide_yearly_updt.dta (02_...do)
***          data/derived/turnout_europee_wide_updt.dta    (03_...do)
***          data/raw/nannicini_social_capital/SOCIAL_CAPITAL.dta
***          data/raw/rai_tv_fee/matched_annuari_rai_canone_allvars_code.dta
*** Outputs: data/derived/tv_tax_social_capital.dta  (analysis dataset)      ***
***          data/derived/maps_tv_tax.dta, maps_sc_munis.dta, maps_sc_provs.dta
***          (inputs of the R maps)                                          ***
*** Source:  original economics_letters_2.do, lines 25-213. Only file paths  ***
***          were changed; the data steps are unchanged.                     ***
********************************************************************************
version 18


***********************************
**# ***	  DATA PREPARATION	 	***
***********************************

**# Controls Dataset **
use "$derived/controls_5111.dta", clear


**# Merge with number of voluntary associations data **
merge 1:1 codcom using "$derived/n_voluntary_associations_wide_updt.dta", gen(mm)
keep if mm != 2
drop mm
replace comune = Comune2010 if comune == ""
replace comune = "brione (bs)" if comune == "brione" & province == "Brescia"
replace comune = "brione (tn)" if comune == "brione" & province != "Brescia"
replace comune = "calliano (at)" if comune == "calliano" & province == "Asti"
replace comune = "calliano (tn)" if comune == "calliano" & province != "Asti"
replace comune = "livo (co)" if comune == "livo" & province == "Como"
replace comune = "livo (tn)" if comune == "livo" & province != "Como"
replace comune = "peglio (co)" if comune == "peglio" & province == "Como"
replace comune = "peglio (pu)" if comune == "peglio" & province != "Como"
replace comune = "samone (to)" if comune == "samone" & province == "Torino"
replace comune = "samone (tn)" if comune == "samone" & province != "Torino"
replace comune = "san teodoro (ss)" if comune == "san teodoro" & regione == "Sardegna"
replace comune = "san teodoro (me)" if comune == "san teodoro" & regione != "Sardegna"
replace comune = "valverde (ct)" if comune == "valverde" & province == "Catania"
replace comune = "valverde (pv)" if comune == "valverde" & province != "Catania"
rename civic81 civic1980
rename civic91 civic1990
rename civic01 civic2000
replace civic1980 = civic1980 * 10
replace civic1990 = civic1990 * 10
replace civic2000 = civic2000 * 10


**# Merge with referendum election data **
merge 1:1 comune using "$derived/turnout_referendum_wide_yearly_updt.dta", gen(mm)
keep if mm != 2
drop mm
drop regione_ref1946 provincia_ref1946 regione_ref1974 provincia_ref1974 regione_ref1981 provincia_ref1981 regione_ref2011 provincia_ref2011 regione_ref2016 provincia_ref2016
rename turnout_ref1946 turnout_ref1950
egen turnout_ref1970 = rowmean(turnout_ref1974 turnout_ref1978)
rename turnout_ref1981 turnout_ref1980
egen turnout_ref2000 = rowmean(turnout_ref2009 turnout_ref2011)
egen turnout_ref2010 = rowmean(turnout_ref2016 turnout_ref2020)
drop turnout_ref1978 turnout_ref2009 turnout_ref2020


**# Merge with european election data **
merge 1:1 comune using "$derived/turnout_europee_wide_updt.dta", gen(mm)
keep if mm != 2
drop mm
drop elettori_euro1979 votanti_euro1979 elettori_euro1984 votanti_euro1984 elettori_euro1989 votanti_euro1989 elettori_euro1994 votanti_euro1994 elettori_euro1999 votanti_euro1999 elettori_euro2004 votanti_euro2004 elettori_euro2009 votanti_euro2009 elettori_euro2014 votanti_euro2014 avg_turnout_europee avg_turnout_europee_00 avg_turnout_europee_90 avg_turnout_europee_70
rename turnout_europee1979 turnout_europee1970
egen turnout_europee1980 = rowmean(turnout_europee1984 turnout_europee1989)
egen turnout_europee1990 = rowmean(turnout_europee1994 turnout_europee1999)
egen turnout_europee2000 = rowmean(turnout_europee2004 turnout_europee2009)
rename turnout_europee2014 turnout_europee2010


**# Merge with other social capital measures from Nannicini **
gen id_city_istat = codcom
merge 1:1 id_city_istat using "$raw/nannicini_social_capital/SOCIAL_CAPITAL.dta", gen(mm)
keep if mm != 2
drop mm
rename nonprof_empl nonprof_empl2000
rename donation donation2000
rename eps_registered eps_registered1990
rename eps_assoc eps_assoc1990
rename coni_registered coni_registered1990
rename coni_assoc coni_assoc1990
rename daily_newsp daily_newsp2000
rename tolerance tolerance2000
rename trust trust2000


**# Merge with Rai data **
rename codcom istat_code_110
merge 1:1 istat_code_110 using "$raw/rai_tv_fee/matched_annuari_rai_canone_allvars_code.dta", gen(mm)
keep if mm != 2
drop mm

* drop useless vars and rename and generate decade data *
forvalues x=6/9 {
	foreach y in "ab_" "fam_" "n_tv_" "d100f_tv_" {
		egen `y'_19`x'0 = rowmean(`y'19`x'1 `y'19`x'5)
	}
}
forvalues x=6/7 {
	foreach y in "n_rad" "d100f_rad" {
		egen `y'_19`x'0 = rowmean(`y'_19`x'1 `y'_19`x'5)
	}
}
forvalues x=0/1 {
	foreach y in "ab_" "fam_" "n_tv_" "d100f_tv_" {
		egen `y'_20`x'0 = rowmean(`y'20`x'1 `y'20`x'5)
	}
}
foreach y in "fam_" "n_tv_" "d100f_tv_" {
	rename `y'1955 `y'1950
}
foreach y in "n_rad" "d100f_rad" {
	rename `y'_1955 `y'_1950
	rename `y'_1981 `y'_1980
}
drop ab_2005 fam_2005 n_tv_2005 d100f_tv_2005 n_page_2005 id_2005 ab_2001 fam_2001 n_tv_2001 d100f_tv_2001 n_page_2001 id_2001 ab_1995 fam_1995 n_tv_1995 d100f_tv_1995 n_page_1995 id_1995 ab_1991 fam_1991 n_tv_1991 d100f_tv_1991 n_page_1991 id_1991 ab_1985 fam_1985 n_tv_1985 d100f_tv_1985 n_page_1985 id_1985 ab_1981 fam_1981 n_tv_1981 d100f_tv_1981 n_page_1981 id_1981 ab_1975 fam_1975 n_tv_1975 d100f_tv_1975 n_page_1975 id_1975 ab_1971 fam_1971 n_tv_1971 d100f_tv_1971 n_page_1971 id_1971 ab_1965 fam_1965 n_tv_1965 d100f_tv_1965 id_1965 n_page_1965 ab_2015 fam_2015 n_tv_2015 d100f_tv_2015 ab_2011 fam_2011 n_tv_2011 d100f_tv_2011 ab_1961 fam_1961 n_tv_1961 d100f_tv_1961 n_page_1961 id_1961 page_1955 province_1955 n_rad_1975 n_rad_1971 n_rad_priv_1965 n_rad_spec_1965 n_rad_1965 n_rad_priv_1961 n_rad_spec_1961 n_rad_1961 d100f_rad_1975 d100f_rad_1971 d100f_rad_1965 d100f_rad_1961 n_tv_priv_2005 d100f_tv_priv_2005 n_tv_spec_2005 n_tvc_1985 d100f_tvc_1985 n_tvbn_1985 d100f_tvbn_1985 n_tvbn_1981 d100f_tvbn_1981 n_tvc_1981 d100f_tvc_1981 n_tvrad_1981 d100f_tvrad_1981 d100ab_tv_1975 n_tvrad_1975 d100ab_tvrad_1975 d100f_tvrad_1975 d100ab_tv_1971 n_tvrad_1971 d100ab_tvrad_1971 d100f_tvrad_1971 n_tv_priv_1965 n_tv_spec_1965 d100ab_tv_1965 n_tv_priv_1961 n_tv_spec_1961 d100ab_tv_1961
forvalues x=1960(10)2010 {
	foreach y in "ab_" "fam_" "n_tv_" "d100f_tv_" {
		rename `y'_`x' `y'`x'
	}
}

* remove outliers TV tax *
summ d100f_tv_1950 d100f_tv_1960 d100f_tv_1970 d100f_tv_1980 d100f_tv_1990 d100f_tv_2000 d100f_tv_2010, d
replace d100f_tv_1960 = . if d100f_tv_1960 > 100 & d100f_tv_1960 != .
replace d100f_tv_1970 = . if d100f_tv_1970 > 100 & d100f_tv_1970 != .
replace d100f_tv_1980 = . if d100f_tv_1980 > 100 & d100f_tv_1980 != .
replace d100f_tv_1980 = . if d100f_tv_1980 < 0 & d100f_tv_1980 != .
replace d100f_tv_1990 = . if d100f_tv_1990 > 100 & d100f_tv_1990 != .
replace d100f_tv_2000 = . if d100f_tv_2000 > 100 & d100f_tv_2000 != .
replace d100f_tv_2010 = . if d100f_tv_2010 > 100 & d100f_tv_2010 != .

* replace missing controls with province median *
rename id_city_istat codcom
replace prov = 7 if province_2005 == "valle d'aosta"
replace prov = 22 if province_2005 == "trento"
replace prov = 13 if province_2005 == "como"
replace prov = 13 if province_2001 == "como"
replace prov = 30 if province_2005 == "udine"
drop if prov == .
sort codcom
foreach x of varlist popolazione_residente* densita_demografica* indice_vecchiaia* ampiezza_media_famiglie* inc_abitazioni_proprieta* diff_genere_istr_sup* incidenza_analfabeti* part_mercato_lavoro_f* part_mercato_lavoro* tasso_occupazione* tasso_occ_agric* tasso_occ_industr* tasso_occ_terz* tasso_occ_comm* {
	bys prov: egen temp_med = median(`x')
	bys codcom: replace `x' = temp_med if `x' == .
	drop temp_med
}
sort codcom

* remove outliers in turnout_europee *
summ turnout_europee1970 turnout_europee2010 turnout_europee1980 turnout_europee1990 turnout_europee2000, d
replace turnout_europee1970 = . if turnout_europee1970 > 1 & turnout_europee1970 != .
replace turnout_europee1980 = . if turnout_europee1980 > 1 & turnout_europee1980 != .
replace turnout_europee1990 = . if turnout_europee1990 > 1 & turnout_europee1990 != .
replace turnout_europee2000 = . if turnout_europee2000 > 1 & turnout_europee2000 != .
replace turnout_europee2010 = . if turnout_europee2010 > 1 & turnout_europee2010 != .

* replace missing in dependent variables with province median *
sort codcom
foreach x of varlist d100f_tv_1950 d100f_tv_1960 d100f_tv_1970 d100f_tv_1980 d100f_tv_1990 d100f_tv_2000 d100f_tv_2010 civic1980 civic1990 civic2000 turnout_ref1950 turnout_ref1980 turnout_ref1970 turnout_ref2000 turnout_ref2010 turnout_europee1970 turnout_europee2010 turnout_europee1980 turnout_europee1990 turnout_europee2000 donation2000 eps_registered1990 eps_assoc1990 coni_registered1990 coni_assoc1990 daily_newsp2000 tolerance2000 trust2000 {
	bys prov: egen temp_med = median(`x')
	bys codcom: replace `x' = temp_med if `x' == .
	drop temp_med
}
sort codcom

* replace missing in reg *
replace reg = 2 if regione == "ValleDA"
replace reg = 3 if regione == "Lombardia"
replace reg = 4 if regione == "Trentino"
replace reg = 6 if regione == "Friuli VG"

* gen macro areas *
gen mac_area = "N" if inrange(reg,1,8)
replace mac_area = "C" if inrange(reg,9,12)
replace mac_area = "S" if reg >= 13

* keep, reshape and save *
keep codcom reg prov mac_area popolazione_residente* densita_demografica* indice_vecchiaia* ampiezza_media_famiglie* inc_abitazioni_proprieta* diff_genere_istr_sup* incidenza_analfabeti* part_mercato_lavoro_f* part_mercato_lavoro* tasso_occupazione* tasso_occ_agric* tasso_occ_industr* tasso_occ_terz* tasso_occ_comm* d100f_tv_1950 d100f_tv_1960 d100f_tv_1970 d100f_tv_1980 d100f_tv_1990 d100f_tv_2000 d100f_tv_2010 civic1980 civic1990 civic2000 turnout_ref1950 turnout_ref1980 turnout_ref1970 turnout_ref2000 turnout_ref2010 turnout_europee1970 turnout_europee2010 turnout_europee1980 turnout_europee1990 turnout_europee2000 donation2000 eps_registered1990 eps_assoc1990 coni_registered1990 coni_assoc1990 daily_newsp2000 tolerance2000 trust2000 nonprof_empl2000
order codcom reg prov
reshape long popolazione_residente densita_demografica indice_vecchiaia ampiezza_media_famiglie inc_abitazioni_proprieta diff_genere_istr_sup incidenza_analfabeti part_mercato_lavoro_f part_mercato_lavoro tasso_occupazione tasso_occ_agric tasso_occ_industr tasso_occ_terz tasso_occ_comm d100f_tv_ civic turnout_ref turnout_europee donation eps_registered eps_assoc coni_registered coni_assoc daily_newsp tolerance trust nonprof_empl, i(codcom) j(decade)
foreach x of varlist popolazione_residente densita_demografica indice_vecchiaia ampiezza_media_famiglie inc_abitazioni_proprieta diff_genere_istr_sup incidenza_analfabeti part_mercato_lavoro_f part_mercato_lavoro tasso_occupazione tasso_occ_agric tasso_occ_industr tasso_occ_terz tasso_occ_comm {
	bys codcom decade: gen temp = `x' if decade == 1950
	bys codcom (decade): egen `x'1950 = max(temp)
	drop temp
}
save "$derived/tv_tax_social_capital.dta", replace

* datasets for the R maps (Figures 3, A.1, A.2) *
preserve
keep codcom prov reg decade d100f_tv_
reshape wide d100f_tv_, i(codcom) j(decade)
save "$derived/maps_tv_tax.dta", replace
restore
preserve
collapse (mean) civic turnout_ref turnout_europee, by(codcom)
save "$derived/maps_sc_munis.dta", replace
restore
preserve
collapse (firstnm) donation coni_assoc daily_newsp trust, by(prov)
save "$derived/maps_sc_provs.dta", replace
restore
