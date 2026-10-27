********************************************************************************
*** table_1.do                                                               ***
*** Table 1: Social capital measures and TV tax compliance,                  ***
***          municipality-level.                                             ***
*** Output:  output/tables/table_1.tex                                       ***
*** Source:  original economics_letters_2.do, lines 248, 277, 305, 456-473   ***
********************************************************************************
version 18
do "$code/06_analysis_setup.do"
eststo clear


**# Regressions: municipality and decade FE, SE clustered by municipality **
* (1) Referendum turnout
eststo tref: reghdfe turnout_ref d100f_tv_ $controls, a(codcom decade) vce(cl codcom)
* (2) European elections turnout
eststo teur: reghdfe turnout_europee d100f_tv_ $controls, a(codcom decade) vce(cl codcom)
* (3) N. civic associations
eststo civi: reghdfe civic d100f_tv_ $controls, a(codcom decade) vce(cl codcom)


**# Table **
local panel_A_prehead "\begin{table}[!h]\centering\begin{threeparttable}" ///
 "\caption{Social capital measures and TV tax compliance compliance, municipality-level.\label{tab:mainres}}" ///
 "\begin{tabular}{lccc} \hline\hline"  ///
 "&\multicolumn{1}{c}{\textit{Referendum turnout}}&\multicolumn{1}{c}{\textit{European elec. turnout}}&\multicolumn{1}{c}{\textit{N. of civic associations}}\\ \cmidrule(lr){2-2} \cmidrule(lr){3-3} \cmidrule(lr){4-4} "
local panel_A_posthead "\hline"
local panel_A_prefoot "\hline"
local notes ="\textit{\underline{Notes}.} * p$<$0.10, ** p$<$0.05, *** p$<$0.01. "
local panel_A_postfoot "Controls &\checkmark&\checkmark&\checkmark\\ " ///
"Municipality FE &\checkmark&\checkmark&\checkmark\\ " ///
"Decade FE &\checkmark&\checkmark&\checkmark\\ \hline\hline " ///
"\end{tabular} \begin{tablenotes} \item \scriptsize{`notes'} \end{tablenotes} \end{threeparttable} \end{table}"
esttab tref teur civi using "$tables/table_1.tex", ///
tex nomtitles replace width(\hsize) b (4) se starlevels(* 0.10 ** 0.05 *** 0.01) drop(_cons) label ///
prehead("`panel_A_prehead'") posthead("`panel_A_posthead'") prefoot("`panel_A_prefoot'") postfoot("`panel_A_postfoot'") gaps
* (original L471-473 wrote a second copy to the authors' Overleaf folder; removed)
