********************************************************************************
*** table_2.do                                                               ***
*** Table 2: Social capital measures and TV tax compliance,                  ***
***          provincial-level.                                               ***
*** Output:  output/tables/table_2.tex                                       ***
*** Source:  original economics_letters_2.do, lines 332-335, 363-366,        ***
***          394-397, 425-428, 477-492 (estimation order as in the original) ***
********************************************************************************
version 18
do "$code/06_analysis_setup.do"
eststo clear


**# (2) N. CONI associations and TV tax **
preserve
collapse (mean) d100f_tv_ popolazione_residente (firstnm) coni_registered, by(prov)
eststo coni: reghdfe coni_registered d100f_tv_ popolazione_residente, noa vce(cl prov)
restore


**# (1) N. blood donations and TV tax **
preserve
collapse (mean) d100f_tv_ popolazione_residente (firstnm) donation, by(prov)
eststo dona: reghdfe donation d100f_tv_ popolazione_residente, noa vce(cl prov)
restore


**# (3) N. sold newspapers and TV tax **
preserve
collapse (mean) d100f_tv_ popolazione_residente (firstnm) daily_newsp, by(prov)
eststo news: reghdfe daily_newsp d100f_tv_ popolazione_residente, noa vce(cl prov)
restore


**# (4) Trust and TV tax **
preserve
collapse (mean) d100f_tv_ popolazione_residente (firstnm) trust, by(prov decade)
eststo trus: reghdfe trust d100f_tv_ popolazione_residente, noa vce(cl prov)
restore


**# Table **
local panel_A_prehead "\begin{table}[!h]\centering\begin{threeparttable}" ///
 "\caption{Social capital measures and TV tax compliance compliance, provincial-level.\label{tab:mainres-prov}}" ///
 "\begin{tabular}{lcccc} \hline\hline"  ///
 "&\multicolumn{1}{c}{\textit{Blood donations}}&\multicolumn{1}{c}{\textit{CONI associations}}&\multicolumn{1}{c}{\textit{Sold newspapers}}&\multicolumn{1}{c}{\textit{Trust}}\\ \cmidrule(lr){2-2} \cmidrule(lr){3-3} \cmidrule(lr){4-4} \cmidrule(lr){5-5} "
local panel_A_posthead "\hline"
local panel_A_prefoot "%"
local notes ="\textit{\underline{Notes}.} * p$<$0.10, ** p$<$0.05, *** p$<$0.01. "
local panel_A_postfoot "\hline\hline " ///
"\end{tabular} \begin{tablenotes} \item \scriptsize{`notes'} \end{tablenotes} \end{threeparttable} \end{table}"
esttab dona coni news trus using "$tables/table_2.tex", ///
tex nomtitles replace width(\hsize) b (4) se starlevels(* 0.10 ** 0.05 *** 0.01) drop(_cons) label ///
prehead("`panel_A_prehead'") posthead("`panel_A_posthead'") prefoot("`panel_A_prefoot'") postfoot("`panel_A_postfoot'") gaps
* (original L490-492 wrote a second copy to the authors' Overleaf folder; removed)
