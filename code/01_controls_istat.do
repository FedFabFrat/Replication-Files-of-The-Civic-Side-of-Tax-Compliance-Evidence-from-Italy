********************************************************************************
*** 01_controls_istat.do                                                     ***
*** Municipal census controls 1951-2011 (ISTAT, "confini dell'epoca"         ***
*** census tables, one xlsx per region).                                     ***
*** Input:  data/raw/istat_census/confini-epoca_01.xlsx ... _20.xlsx         ***
*** Output: data/derived/controls_5111.dta                                   ***
***         (intermediate files in data/derived/controls_tmp/)               ***
*** Source: original data/contr/controls_5111.do. Only file paths changed    ***
***         (lines marked PACKAGE); the data steps are unchanged.            ***
*** Requires: mipolate, carryforward (SSC).                                  ***
********************************************************************************
version 18

**************************************************************************************************
**************************************************************************************************
**************************************************************************************************

*** set wd ***
cap mkdir "$derived/controls_tmp"
cd "$derived/controls_tmp"   // PACKAGE: was cd "C:\path\to\mafia_social_capital\Economics_Letters\data\contr"



*** open and save in dta raw data ***
foreach x in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"{
	local myfilelist : dir "$raw/istat_census" files"confini-epoca_`x'*.xlsx"
	foreach file of local myfilelist {
		if "`x'"=="01" {
		local reg "Piemonte"
		}
		else if "`x'"=="02" {
		local reg "ValleDA"
		}
		else if "`x'"=="03"{
		local reg "Lombardia"
		}
		else if "`x'"=="04"{
		local reg "Trentino"
		}
		else if "`x'"=="05"{
		local reg "Veneto"
		}
		else if "`x'"=="06"{
		local reg "Friuli VG"
		}
		else if "`x'"=="07"{
		local reg "Liguria"
		}
		else if "`x'"=="08"{
		local reg "EmiliaR"
		}
		else if "`x'"=="09"{
		local reg "Toscana"
		}
		else if "`x'"=="10"{
		local reg "Umbria"
		}
		else if "`x'"=="11"{
		local reg "Marche"
		}
		else if "`x'"=="12"{
		local reg "Lazio"
		}
		else if "`x'"=="13"{
		local reg "Abruzzi"
		}
		else if "`x'"=="14"{
		local reg "Molise"
		}
		else if "`x'"=="15"{
		local reg "Campania"
		}
		else if "`x'"=="16"{
		local reg "Puglia"
		}
		else if "`x'"=="17"{
		local reg "Basilicata"
		}
		else if "`x'"=="18"{
		local reg "Calabria"
		}
		else if "`x'"=="19"{
		local reg "Sicilia"
		}
		else if "`x'"=="20"{
		local reg "Sardegna"
		}
		import excel "$raw/istat_census/`file'", sheet("`reg' 51-11 confepoca") firstrow allstring clear
		destring AnnoCP, replace
// 		keep if AnnoCP<=1981
		rename P1 popolazione_residente
		rename P7 densita_demografica
		rename P13 indice_vecchiaia
		rename F1 ampiezza_media_famiglie
		rename A1 incidenza_abitazioni_proprieta
		rename I1 diff_genere_istr_sup
		rename I4 incidenza_analfabeti
		rename L2 partecipazione_mercato_lavoro_f
		rename L3 partecipazione_mercato_lavoro
		rename L12 tasso_occupazione
		rename L15 tasso_occ_agric
		rename L16 tasso_occ_industr
		rename L17 tasso_occ_terz
		rename L18 tasso_occ_comm
		keep AnnoCP Livelloterritoriale CodiceRegione2011 CodiceProvincia2011 CodiceComuneallepoca ///
		Codicecomune2011 Denominazionedelterritorio Flagcomuniconvariazionianno ///
		popolazione_residente densita_demografica indice_vecchiaia ///
		ampiezza_media_famiglie incidenza_abitazioni_proprieta diff_genere_istr_sup incidenza_analfabeti ///
		partecipazione_mercato_lavoro partecipazione_mercato_lavoro_f tasso_occupazione tasso_occ_agric tasso_occ_industr ///
		tasso_occ_terz tasso_occ_comm
// 		local outfile=subinstr("`file'",".csv","",.)
		gen regione="`reg'"
		save "controls_`x'_all.dta", replace
		}
}



*** append data ***
use controls_01_all.dta, clear
foreach x in "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"{
	local myfilelist : dir . files"controls_`x'_all.dta"
	foreach file of local myfilelist {
		append using `file'
}
}



*** data management ***


** drop missing AnnoCP from import **
drop if AnnoCP == .																// NOTE LINE CHANGED

** destring **
sort Codicecomune2011 AnnoCP
foreach var of varlist Livelloterritoriale CodiceRegione2011 CodiceProvincia2011 CodiceComuneallepoca Codicecomune2011 /// 
popolazione_residente densita_demografica indice_vecchiaia ///
ampiezza_media_famiglie incidenza_abitazioni_proprieta diff_genere_istr_sup incidenza_analfabeti ///
partecipazione_mercato_lavoro partecipazione_mercato_lavoro_f tasso_occupazione tasso_occ_agric tasso_occ_industr ///
tasso_occ_terz tasso_occ_comm {
	destring `var', replace
}
replace incidenza_abitazioni_proprieta=subinstr(incidenza_abitazioni_proprieta,"-",".",.)
replace diff_genere_istr_sup = subinstr(diff_genere_istr_sup,"-",".",.)
replace indice_vecchiaia = subinstr(indice_vecchiaia,"-",".",.)
destring incidenza_abitazioni_proprieta, replace
destring diff_genere_istr_sup, replace
destring indice_vecchiaia, replace


** rename **
rename Denominazionedelterritorio Comune
rename incidenza_abitazioni_proprieta inc_abitazioni_proprieta
rename partecipazione_mercato_lavoro part_mercato_lavoro
rename partecipazione_mercato_lavoro_f part_mercato_lavoro_f
rename Codicecomune2011 codcom


** reshape **
rename CodiceComuneallepoca codcom_

* keep mostly balanced panel of municipalities *
bys codcom (AnnoCP): egen n_anni = seq()
bys codcom (AnnoCP): egen ma_n_anni = max(n_anni)
keep if ma_n_anni >= 6
drop ma_n_anni n_anni
xtset codcom AnnoCP, del(10)
tsfill, full
tostring codcom, replace
replace codcom = subinstr(codcom,"9990","",.) if substr(codcom,1,4) == "9990"
destring codcom, replace
foreach x of varlist Comune codcom_ Livelloterritoriale CodiceRegione2011 CodiceProvincia2011 regione {
	bys codcom (AnnoCP): carryforward `x', replace
	gsort codcom -AnnoCP
	bys codcom: carryforward `x', replace
	sort codcom AnnoCP	
}
foreach x of varlist popolazione_residente densita_demografica indice_vecchiaia ampiezza_media_famiglie inc_abitazioni_proprieta diff_genere_istr_sup incidenza_analfabeti part_mercato_lavoro_f part_mercato_lavoro tasso_occupazione tasso_occ_agric tasso_occ_industr tasso_occ_terz tasso_occ_comm {
	bys codcom (AnnoCP): mipolate `x' AnnoCP, e idw(2) gen(temp)
	replace `x' = temp if `x' == .
	drop temp
}
drop Flagcomuniconvariazionianno
reshape wide popolazione_residente densita_demografica indice_vecchiaia ///
ampiezza_media_famiglie inc_abitazioni_proprieta diff_genere_istr_sup incidenza_analfabeti ///
part_mercato_lavoro part_mercato_lavoro_f tasso_occupazione tasso_occ_agric tasso_occ_industr ///
tasso_occ_terz tasso_occ_comm Comune codcom_, i(codcom) j(AnnoCP)

//
//
// *** data mgmt to merge with data on population in 1936 ***
// sort Comune1951
// gen COMUNEtot= Comune1951
// replace COMUNEtot= Comune1961 if Comune1951==""
// sort COMUNEtot
//
* Manage comune name variable *
foreach x of varlist Comune1951 Comune1961 Comune1971 Comune1981 Comune1991 Comune2001 Comune2011 {
	replace `x' = strtrim(lower(`x'))
}

* rename control variables to be consistent with future reshape in long form *
forvalues x=5/9 {
	foreach y in "Comune" "codcom_" "popolazione_residente" "densita_demografica" "indice_vecchiaia" "ampiezza_media_famiglie" "inc_abitazioni_proprieta" "diff_genere_istr_sup" "incidenza_analfabeti" "part_mercato_lavoro_f" "part_mercato_lavoro" "tasso_occupazione" "tasso_occ_agric" "tasso_occ_industr" "tasso_occ_terz" "tasso_occ_comm" {
		rename `y'19`x'1 `y'19`x'0
	}
}
forvalues x=0/1 {
	foreach y in "Comune" "codcom_" "popolazione_residente" "densita_demografica" "indice_vecchiaia" "ampiezza_media_famiglie" "inc_abitazioni_proprieta" "diff_genere_istr_sup" "incidenza_analfabeti" "part_mercato_lavoro_f" "part_mercato_lavoro" "tasso_occupazione" "tasso_occ_agric" "tasso_occ_industr" "tasso_occ_terz" "tasso_occ_comm" {
		rename `y'20`x'1 `y'20`x'0 
	}
}



*** save dataset ***
sort Comune1950


save "$derived/controls_5111.dta", replace   // PACKAGE: was "C:\path\to\mafia_social_capital\Economics_Letters\data\controls_5111.dta"
cd "$root"   // PACKAGE: return to the package root












