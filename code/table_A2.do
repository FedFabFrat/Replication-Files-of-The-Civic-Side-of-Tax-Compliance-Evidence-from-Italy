********************************************************************************
*** table_A2.do                                                              ***
*** Table A.2: Descriptive statistics.                                       ***
*** Output:    output/tables/table_A2.tex                                    ***
*** Source:    original economics_letters_2.do, lines 496-525                ***
*** Note: statistics are computed on all observations of the analysis       ***
*** dataset (municipality x decade), with turnout in percentage points.     ***
********************************************************************************
version 18
do "$code/06_analysis_setup.do"


**# Table summary stat **
local prehead1 	"\begin{table}\centering\begin{threeparttable}" ///
				"\caption{Descriptive statistics.}\label{tab:ds}" ///
				"\begin{tabular}{lccccc} \hline \hline" ///
				"& Mean & SD  & Min  & Max  \\  \hline "
local prehead2 	"%"
local posthead1	"\textit{\underline{Municipal level}} & & & & \\"
local posthead2	"\textit{\underline{Provincial level}} & & & & \\"
local prefoot1 	"& & & & & \\"
local prefoot2 	"\hline"
local notes =	"\textit{\underline{Notes}.} This table shows the descriptive statistics of the main variables at our disposal in the analysis. "
local postfoot1 "%"
local postfoot2 "\end{tabular} \begin{tablenotes} \item \scriptsize{`notes'} \end{tablenotes} \end{threeparttable} \end{table}"
eststo clear
estpost summarize d100f_tv_ turnout_ref turnout_europee civic $controls
esttab using "$tables/table_A2.tex", ///
tex label compress nomtitles nodepvars nonumbers mlabels(,none) collabels(,none) replace cells("mean(fmt(a2)) sd min max") noobs ///
prehead("`prehead1'") posthead("`posthead1'") prefoot("`prefoot1'") postfoot("`postfoot1'")
eststo clear
estpost summarize donation coni_assoc daily_newsp trust
esttab using "$tables/table_A2.tex", ///
tex label compress nomtitles nodepvars nonumbers mlabels(,none) collabels(,none) append cells("mean(fmt(a2)) sd min max") noobs ///
prehead("`prehead2'") posthead("`posthead2'") prefoot("`prefoot2'") postfoot("`postfoot2'")
* (original L526-535 wrote a second copy to the authors' Overleaf folder; removed)
