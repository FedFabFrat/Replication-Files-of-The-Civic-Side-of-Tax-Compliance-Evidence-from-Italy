********************************************************************************
*** 06_analysis_setup.do                                                     ***
*** Loads the analysis dataset and applies the settings shared by all        ***
*** exhibits: control list, variable labels, turnout rescaled to 0-100.      ***
*** Called at the top of every table_*.do / figure_*.do file.                ***
*** Source: original economics_letters_2.do, lines 220-229, 247, 276, 497-503 ***
********************************************************************************
version 18

use "$derived/tv_tax_social_capital.dta", clear

* control variables used in Table 1 and Figure 1 (original L223)
global controls "popolazione_residente indice_vecchiaia diff_genere_istr_sup incidenza_analfabeti part_mercato_lavoro"

* labels of regressors (original L224-229)
label var popolazione_residente "Population"
label var indice_vecchiaia "Elderly index"
label var diff_genere_istr_sup "Education gender gap index"
label var incidenza_analfabeti "Illiterate index"
label var part_mercato_lavoro "Workforce participation"
label var d100f_tv_ "TV tax compliance"

* turnout from shares to percentage points (original L247 and L276).
* In the original single script these two lines ran just before the Table 1
* regressions and remained in memory for Table A.2.
replace turnout_ref = turnout_ref*100
replace turnout_europee = turnout_europee*100

* labels of outcomes, used by Table A.2 (original L497-503)
label var turnout_ref "Referendum turnout"
label var turnout_europee "European ele. turnout"
label var civic "N. civic association * 1000"
label var donation "N. blood donations"
label var coni_assoc "N. CONI associations / 1000 people"
label var daily_newsp "N. of non-sport newspapers sold / 1000"
label var trust "Trust (WVS)"
