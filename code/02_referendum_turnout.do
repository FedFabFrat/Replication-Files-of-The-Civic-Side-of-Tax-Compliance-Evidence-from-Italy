********************************************************************************
*** 02_referendum_turnout.do                                                 ***
*** Municipal turnout in national referendums, 1946-2020 (Eligendo,          ***
*** Ministry of the Interior). Turnout = voters / eligible voters; values    ***
*** above 1 set to missing; referendums held in the same year averaged.      ***
*** Input:  data/raw/eligendo_referendum/referendum-YYYYMMDD.zip (23 files)  ***
*** Output: data/derived/turnout_referendum_wide_yearly_updt.dta             ***
***         (intermediate files in data/derived/referendum_tmp/)             ***
*** Source: original dati/referendum_update/data_mgmt_referendum_update.do.  ***
***         Changes (lines marked PACKAGE): file paths, and the loop that    ***
***         dropped the Southern regions is disabled. The original dropped   ***
***         the South for an earlier Centre-North project; the file used by  ***
***         the paper covers all of Italy, and with this one line disabled   ***
***         the output is identical to it (Stata -cf-, all 25 variables).    ***
********************************************************************************
version 18
* PACKAGE: root global set in master.do (was: global referendum "C:\path\to\mafia_social_capital\dati\referendum_update")

cap mkdir "$derived/referendum_tmp"
cd "$derived/referendum_tmp"   // PACKAGE: was cd "$referendum/raw"

local myfilelist : dir "$raw/eligendo_referendum" files"*.zip"
foreach file of local myfilelist {
	unzipfile "$raw/eligendo_referendum/`file'", replace
}

local myfilelist : dir . files"*.txt"
foreach file of local myfilelist {
	di "`file'"
	import delimited "`file'", clear
	gen data_ref_s = substr("`file'",length("`file'")-11,8)
	gen year_ref_s = substr(data_ref_s,1,4)
	gen month_ref_s = substr(data_ref_s,5,2)
	replace month_ref_s = subinstr(month_ref_s,"0","",1) if substr(month_ref_s,1,1) == "0"
	gen day_ref_s = substr(data_ref_s,length(data_ref_s)-1,2)
	replace day_ref_s = subinstr(day_ref_s,"0","",1) if substr(day_ref_s,1,1) == "0"
	foreach x of varlist year_ref_s month_ref_s day_ref_s {
		destring `x', replace
	}
	gen data_ref = mdy(month_ref_s,day_ref_s,year_ref_s)
	format data_ref %td
	drop day_ref_s month_ref_s year_ref_s data_ref_s 
	local outfile=subinstr("`file'",".txt","",.)
	tostring num_referendum, replace
	cap rename skbianche schede_bianche
	cap rename elettor_imaschi elettori_maschi
	save `outfile'.dta, replace
}

use "referendum-19810517.dta", clear
foreach x of varlist elettori votanti numvotisi numvotino schede_bianche {
	replace `x' = substr(`x',1,length(`x')-3)
	destring `x', replace
}
save "referendum-19810517.dta", replace


**# append all referendums **
use "referendum-19460602.dta", clear
gen orig = 1
local myfilelist : dir . files"*.dta"
foreach file of local myfilelist {
	di "`file'"
	append using `file'
}

* drop duplicated one *
drop if orig == 1
drop orig

* drop if comune is missing *
drop if comune == ""
sort comune data_ref

* string management *
foreach x of varlist circoscrizione provincia comune regione {
	replace `x' = strtrim(lower(`x'))
}

**# province mgmt **
ta provincia
replace provincia = "barletta-andria-trani" if provincia == "barletta- andria-trani"
replace provincia = "forli'-cesena" if provincia == "forlì -cesena"
replace provincia = "forli'-cesena" if provincia == "forli'"
replace provincia = "pesaro e urbino" if provincia == "pesaro"
replace provincia = "massa-carrara" if provincia == "massa carrara"
replace provincia = "reggio di calabria" if provincia == "reggio calabria"
replace provincia = "reggio nell'emilia" if provincia == "reggio nell' emilia"
replace provincia = "reggio nell'emilia" if provincia == "reggio emilia"

**# region mgmt **
ta regione
replace regione = "friuli-venezia giulia" if regione == "friuli venezia g."
replace regione = "trentino-alto adige" if regione == "trentino a.a."
bys provincia: egen temp = mode(regione)
bys provincia: replace regione = temp if regione == ""
drop temp

**# quesito selection, to avoid political/criminal interesting ones **
/*
data_ref	quesito
YES     02jun1946	REFERENDUM SULLA FORMA ISTITUZIONALE DELLO STATO
YES     12may1974	DIVORZIO
NO      11jun1978	Finanziamento pubblico dei partiti
YES/NO  11jun1978	Ordine pubblico
YES/NO  17may1981	Ergastolo
YES     17may1981	Interruzione gravidanza (Proposta radicale)
YES/NO  17may1981	Porto d'armi
YES     17may1981	Interruzione gravidanza (Proposta Movimento per la vita)
NO      21jun2009	Elezione della Camera dei Deputati. Abrogazione della possibilita' di collegamento tra liste e di attribuzione del premio di maggioranza ad una coalizione di liste
NO      21jun2009	Elezione della Camera dei Deputati. Abrogazione della possibilita' per uno stesso candidato di presentare la propria candidatura in piu' di una circoscrizione
NO      21jun2009	Elezione del Senato della Repubblica. Abrogazione della possibilita' di collegamento tra liste e di attribuzione del premio di maggioranza ad una coalizione di liste
YES     12jun2011	Abrogazione delle nuove norme che consentono la produzione nel territorio di energia elettrica nucleare
NO      12jun2011	Abrogazione di norme della legge 7 aprile 2010, n.51, in materia di legittimo impedimento del Presidente del Consiglio dei Ministri e dei Ministri a comparire in udienza 
					penale, quale risultante a seguito della sentenza n.23 del 2011 della Corte Costituzi
NO      12jun2011	Modalita' di affidamento e gestione dei servizi pubblici locali di rilevanza economica - Abrogazione
YES     12jun2011	Determinazione della tariffa del servizio idrico integrato in base all'adeguata remunerazione del capitale investito - Abrogazione parziale di norma
YES     17apr2016	DURATA TRIVELLAZIONI IN MARE
NO      04dec2016	PER L'APPROVAZIONE DELLA LEGGE DI RIFORMA COSTITUZIONALE
NO      20sep2020	Referendum Costituzionale - riduzione del numero dei parlamentari
*/
// note: may want to exclude referendums that are ok, but that are on the same day of a NO one, since attendance is affected.
// liberally, keep everything
// moderately, keep 02jun1946, 12may1974, 17may1981 (YES only), 12jun2011 (YES only), 17apr2016
// conservatively, keep 02jun1946, 12may1974, 17apr2016. 
// Go for moderately.
// drop if quesito == "Finanziamento pubblico dei partiti" | quesito == "Ordine pubblico" | quesito == "Ergastolo" | quesito == "Porto d'armi" | quesito == "Elezione della Camera dei Deputati. Abrogazione della possibilita' di collegamento tra liste e di attribuzione del premio di maggioranza ad una coalizione di liste" | quesito == "Elezione della Camera dei Deputati. Abrogazione della possibilita' per uno stesso candidato di presentare la propria candidatura in piu' di una circoscrizione" | quesito == "Elezione del Senato della Repubblica. Abrogazione della possibilita' di collegamento tra liste e di attribuzione del premio di maggioranza ad una coalizione di liste" | quesito == "Abrogazione di norme della legge 7 aprile 2010, n.51, in materia di legittimo impedimento del Presidente del Consiglio dei Ministri e dei Ministri a comparire in udienza penale, quale risultante a seguito della sentenza n.23 del 2011 della Corte Costituzi" | quesito == "Modalita' di affidamento e gestione dei servizi pubblici locali di rilevanza economica - Abrogazione" | quesito == "PER L'APPROVAZIONE DELLA LEGGE DI RIFORMA COSTITUZIONALE" | quesito == "Referendum Costituzionale - riduzione del numero dei parlamentari"

**# city mgmt **
replace comune = strtrim(lower(comune))
replace comune=subinstr(comune,"è","e'",.)
replace comune=subinstr(comune,"é","e'",.)
replace comune=subinstr(comune,"ò","o'",.)
replace comune=subinstr(comune,"ì","i'",.)
replace comune=subinstr(comune,"à","a'",.)
replace comune=subinstr(comune,"ù","u'",.)
replace comune="brione (bs)" if comune=="brione" & regione=="lombardia"
replace comune="brione (tn)" if comune=="brione" & regione=="trentino-alto adige"
replace comune="calliano (tn)" if comune=="calliano" & regione=="trentino-alto adige"
replace comune="calliano (at)" if comune=="calliano" & regione=="piemonte"
replace comune="samone (to)" if comune=="samone" & regione=="piemonte"
replace comune="samone (tn)" if comune=="samone" & regione=="trentino-alto adige"
replace comune="livo (co)" if comune=="livo" & regione=="lombardia"
replace comune="livo (tn)" if comune=="livo" & regione=="trentino-alto adige"
replace comune="peglio (co)" if comune=="peglio" & regione=="lombardia"
replace comune="peglio (pu)" if comune=="peglio" & regione=="marche" 	
replace comune="castro (bg)" if comune=="castro" & regione=="lombardia"
replace comune="valverde (pv)" if comune=="valverde" & regione=="lombardia"
replace comune="albissola marina" if comune=="albisola marina" 
replace comune="aldino" if comune=="aldino/aldein"
replace comune="allein" if comune=="allain"
replace comune="villa d'alme'" if comune=="alme con villa"
replace comune="amblar" if comune=="amblar-don"
replace comune="andriano" if comune=="andriano/andrian"
replace comune="anterivo" if comune=="anterivo/altrei"
replace comune="angolo terme" if comune=="angolo"
replace comune="appiano sulla strada del vino" if comune=="appiano s.s. d. v./eppan a. d. w."
replace comune="appiano sulla strada del vino" if comune=="appiano sulla strada del vino/eppan an der weinstrasse"
replace comune="antey-saint-andre'" if comune=="antey saint andre"
replace comune="arnad" if comune=="arnaz"
replace comune="casperia" if comune=="aspra sabina"
replace comune="avelengo" if comune=="avelengo/hafling"
replace comune= "aymavilles" if comune=="aymaville"
replace comune= "badia" if comune=="badia/abtei"
replace comune= "casciana terme" if comune=="bagni di casciana"
replace comune= "casciana terme" if comune=="casciana terme lari"
replace comune= "bajardo" if comune=="baiardo"
replace comune= "barbiano" if comune=="barbiano/barbian"
replace comune= "barzano'" if comune=="barzano"
replace comune= "vasanello" if comune=="bassanello"
replace comune= "bassano romano" if comune=="bassano di sutri" 
replace comune= "besenello" if comune=="beseno"
replace comune= "beura-cardezza" if comune=="beura cardezza"
replace comune= "bevilacqua" if comune=="bevilacqua boschi"
replace comune= "ledro" if comune=="bezzecca"
replace comune= "blera" if comune=="bieda"
**verificare bleggio e bleggio inferiore
replace comune= "boffalora d'adda " if comune=="boffalora d adda "
replace comune= "bolzano" if comune=="bolzano/bozen"
*Nel 1947 Bondo-breguzzo cessa di esistere e vengono ricostituiti i comuni di Bondo e Breguzzo
replace comune= "borgo valsugana" if comune=="borgo"
replace comune= "borgorose" if comune=="borgocollefegato"
*verificare borgounito
replace comune= "borgo velino" if comune=="borgovelino"
replace comune= "bracca" if comune=="bracca di costa serina"
replace comune= "braies" if comune=="braies/prags"
replace comune= "brennero" if comune=="brennero/brenner"
replace comune= "brenzone" if comune=="brenzone sul garda"
replace comune= "bressanone" if comune=="bressanone/brixen"
*verificare briga marittima
replace comune= "brignano-frascata" if comune=="brignano frascata"
replace comune= "broccostella" if comune=="brocco"
replace comune= "bronzolo" if comune=="bronzolo/branzoll"
replace comune= "brovello-carpugnino" if comune=="brovello carpugnino"
replace comune= "brunico" if comune=="brunico/bruneck"
replace comune= "buja" if comune=="buia"
replace comune= "caderzone terme" if comune=="caderzone"
*verificare cadrezzate con osmate
replace comune= "caines" if comune=="caines/kuens"
replace comune= "calasca-castiglione" if comune=="calasca castiglione"
replace comune= "caldaro sulla strada del vino" if comune=="caldaro sulla strada del vino/kaltern an der weinstrasse"
replace comune= "campiglione fenile" if comune=="campiglione-fenile"
replace comune= "campo di trens" if comune=="campo di trens/freienfeld "
replace comune= "campo tures" if comune=="campo tures/sand in taufers"
*verificare campolongo al torre
*carrara san giorgo e can carrara santo stefano fusi in due carrare nel 1995
replace comune= "capriano del colle" if comune=="capriano azzano"
replace comune= "carugo" if comune=="carugo arosio"
replace comune= "casale cremasco-vidolasco" if comune=="casale cremasco vidolasco"
replace comune= "casaleggio novara" if comune=="casaleggio castellazzo"
replace comune= "casciana terme" if comune=="casciana terme lari"
replace comune= "san giacomo vercellese" if comune=="cascine san giacomo"
* verificare castel ivan 
replace comune= "castelbello-ciardes" if comune=="castelbello ciardes"
replace comune= "castelbello-ciardes" if comune=="castelbello-ciardes/kastelbell-tschars"
* verificare castelfranco piandiscò 
*castelgerundo= fusione 2018
replace comune= "castellania" if comune=="castellania coppi"
replace comune= "castellinaldo" if comune=="castellinaldo d'alba "
replace comune= "castello-molina di fiemme" if comune=="castello di fiemme"
replace comune= "castellavazzo" if comune=="castello lavazzo"
replace comune= "castelnuovo bocca d'adda" if comune=="castelnuovo bocca d adda"
replace comune= "castelrotto" if comune=="castelrotto/kastelruth"
replace comune= "castiglione d'adda" if comune=="castiglione d adda"
replace comune= "cavaglia'" if comune=="cavaglia"
replace comune= "cavaglio-spoccia" if comune=="cavaglio spoccia"
replace comune= "cavenago d'adda" if comune=="cavenago d adda"
*cellio con breia= fusione 2018
*cembra lisignago= istituzione 2016
*verificare cenate d'argon
*verificare centrisola
* centro valle intelvi = istituito nel 2018
replace comune= "cermes" if comune=="cermes/tscherms"
replace comune= "cernusco lombardone" if comune=="cernusco montevecchia"
replace comune= "ceretto lomellina" if comune=="cerreto lomellino"
replace comune= "cerrina monferrato" if comune=="cerrina"
replace comune= "cervignano d'adda" if comune=="cervignano d adda"
replace comune= "cesana brianza" if comune=="cesello brianza"
replace comune= "challand-saint-anselme" if comune=="challand saint anselme"
replace comune= "challand-saint-victor" if comune=="challand saint victor"
replace comune= "châtillon" if comune=="chatillon"
replace comune= "chienes" if comune=="chienes/kiens"
replace comune= "chiopris-viscone" if comune=="chiopris viscone"
replace comune= "chiusa" if comune=="chiusa"
replace comune= "canossa" if comune=="ciano d'enza"
replace comune= "canossa" if comune=="ciano d enza"
* verificare cimbergo paspardo 
*verificare colcavagno
*colceresa= nato 2019
*colli al metauro= 2017
*colli verdi= 2019
*colverde= fusione 2014
*verificare concei
*verificare consiglio di rumo
*conta'= 2016
*verificare contarina
*verificare cornale e bastida
*verificare CORTEOLONA e genzone
replace comune= "cornedo all'isarco" if comune=="cornedo all'isarco/karneid"
replace comune= "cortaccia sulla strada del vino" if comune=="cortaccia sulla strada del vino/kurtatsch an der weinstrasse"
replace comune= "cortina sulla strada del vino" if comune=="cortina sulla strada del vino/kurtinig an der weinstrasse"
replace comune= "corvara in badia" if comune=="corvara in badia/corvara"
replace comune= "cosio d'arroscia" if comune=="cosio di arroscia"
replace comune= "costa di mezzate" if comune=="costa monticelli "
replace comune= "costermano" if comune=="costermano sul garda"
replace comune= "crespina" if comune=="crespina lorenzana"
replace comune= "crevoladossola" if comune=="crevola d'ossola"
*verificare curdomo
replace comune= "curon venosta" if comune=="curon venosta/graun im vinschgau"
replace comune= "cursolo-orasso" if comune=="cursolo orasso"
replace comune= "danta di cadore" if comune=="danta"
replace comune= "darfo boario terme" if comune=="darfo"
*verificare dezzo di scalve
replace comune= "dimaro" if comune=="dimaro folgarida"
replace comune= "dobbiaco" if comune=="dobbiaco/toblach"
*verificare donada
replace comune= "donnas" if comune=="donnaz"
replace comune= "dro" if comune=="dro'"
replace comune= "duino-aurisina" if comune=="duino aurisina"
replace comune= "egna" if comune=="egna/neumarkt"
replace comune= "emare'se" if comune=="emar+se"
replace comune= "emare'se" if comune=="emarese"
replace comune= "emare'se" if comune=="emarÈse"
replace comune= "fe'nis" if comune=="f+nis"
replace comune= "fe'nis" if comune=="fenis"
replace comune= "fe'nis" if comune=="fÉnis"
replace comune= "falzes" if comune=="falzes/pfalzen"
*verificare fabbriche di vergemoli 
replace comune= "farini" if comune=="farini d'olmo"
replace comune= "favria" if comune=="favria oglianico"
replace comune= "fie' allo sciliar" if comune=="fie' allo sciliar/vols am schlern"
replace comune= "fie' allo sciliar" if comune=="fie' allo sciliar/vÍls am schlern"
replace comune= "fie' allo sciliar" if comune=="fie' allo sciliar/vÖls am schlern"
replace comune= "figline valdarno" if comune=="figline e incisa valdarno"
*verificare fiscaglia
replace comune= "fiumicello" if comune=="fiumicello villa vicentina"
replace comune= "canale d'agordo" if comune=="forno di canale"
replace comune= "fortezza" if comune=="fortezza/franzensfeste"
replace comune= "fubine" if comune=="fubine monferrato"
replace comune= "funes" if comune=="funes/villnoss"
replace comune= "funes" if comune=="funes/villnÍss"
replace comune= "funes" if comune=="funes/villnÖss"
replace comune= "gabbioneta-binanuova" if comune=="gabbioneta binanuova"
replace comune= "gadesco-pieve delmona" if comune=="gadesco pieve delmona"
replace comune= "gais" if comune=="gais/gais"
replace comune= "galzignano terme" if comune=="galzignano"
replace comune= "gambassi terme" if comune=="gambassi"
replace comune= "gargazzone" if comune=="gargazzone/gargazon"
replace comune= "garniga terme" if comune=="garniga"
*verificare gattico-veruno
*verificare germasino
replace comune= "glorenza" if comune=="glorenza/glurns"
replace comune= "godiasco salice terme" if comune=="godiasco"
replace comune= "gravedona ed uniti" if comune=="gravedona"
replace comune= "gressoney-la-trinite'" if comune=="gressoney la trinite'"
replace comune= "gressoney-saint-jean" if comune=="gressoney saint jean"
replace comune= "greve in chianti" if comune=="greve"
replace comune= "eraclea" if comune=="grisolera"
replace comune= "grizzana morandi" if comune=="grizzana"
replace comune= "hône" if comune=="hone"
replace comune= "hône" if comune=="hone bard"
replace comune= "jolanda di savoia" if comune=="iolanda di savoia"
*verificare isola comacina
replace comune= "madesimo" if comune=="isolato"
replace comune= "jovençan" if comune=="jovencan"
replace comune= "la valle" if comune=="la valle/wengen"
*verificare la valletta brianza
replace comune= "laces" if comune=="laces/latsch"
replace comune= "laglio" if comune=="laglio brienno"
replace comune= "lagundo" if comune=="lagundo/algund"
replace comune= "laion" if comune=="laion/lajen"
replace comune= "laives" if comune=="laives/leifers"
replace comune= "lana" if comune=="lana/lana"
replace comune= "lasa" if comune=="lasa/laas"
*verificare laterina e laterina pergine valdarno
replace comune= "lauregno" if comune=="lauregno/laurein"
replace comune= "lavena ponte tresa" if comune=="lavena-ponte tresa"
replace comune= "leini" if comune=="leini'"
*verificare lesa belgirate
replace comune= "levico terme" if comune=="levico"
*verificare lieto colle
*verificare lomaso
replace comune= "lonato del garda" if comune=="lonato"
*lu e cuccare monferrato= 2019
replace comune= "ortonovo" if comune=="luni"
replace comune= "lusiana" if comune=="lusiana conco"
replace comune= "luson" if comune=="luson/l_sen"
replace comune= "luson" if comune=="luson/lusen"
replace comune= "luson" if comune=="luson/lÜsen"
*maccagno con pino e veddasca
*madruzzo
replace comune="magre' sulla strada del vino" if comune=="magre' sulla strada del vino/margreid an der weinstrasse"
replace comune= "meltina" if comune=="meltina/molten"
replace comune= "meltina" if comune=="meltina/mÍlten"
replace comune= "meltina" if comune=="meltina/mÖlten"
replace comune= "merano" if comune=="merano/meran"
replace comune= "monguelfo-tesido" if comune=="monguelfo-tesido/welsberg-taisten"
replace comune= "monguelfo" if comune=="monguelfo/welsberg"
replace comune= "montagna" if comune=="montagna/montan"
replace comune= "marebbe" if comune=="marebbe/enneberg"
replace comune= "marlengo" if comune=="marlengo/marling"
replace comune= "martello" if comune=="martello/martell"
replace comune= "malles venosta" if comune=="malles venosta/mals"
*mappano
replace comune= "filago" if comune=="marne"
replace comune= "massa fiscaglia" if comune=="massafiscaglia"
*mezzano-imer
*mirabello
*molina di ledro
replace comune= "monguelfo-tesido" if comune=="monguelfo"
replace comune= "monguelfo-tesido" if comune=="monguelfo-tesido/welsberg-taisten"
replace comune= "monguelfo-tesido" if comune=="monguelfo/welsberg"
replace comune= "montagna" if comune=="montagna/montan"
*montalto carpasio= 2018
replace comune= "monte grimano terme" if comune=="monte grimano"
replace comune= "monte compatri" if comune=="montecompatri"
replace comune= "montegrino valtravaglia" if comune=="montegrino-valtravaglia"
*montescudo-monte colombo
replace comune= "monticelli brusati" if comune=="monticello brusati"
replace comune= "monticello brianza" if comune=="monticello"
replace comune= "montiglio monferrato" if comune=="montiglio"
replace comune= "moso in passiria" if comune=="moso in passiria/moos in passeier"
*mosso santa maria
replace comune= "nalles" if comune=="nalles/nals"
replace comune= "naturno" if comune=="naturno/naturns"
replace comune="naz-sciaves" if comune=="naz sciaves"
replace comune= "naz-sciaves" if comune=="naz-sciaves/natz-schabs"
replace comune= "nova levante" if comune=="nova levante/welschnofen"
replace comune= "nova ponente" if comune=="nova ponente/deutschnofen"
replace comune= "parcines" if comune=="parcines/partschins"
replace comune= "negrar" if comune=="negrar di valpolicella"
replace comune= "ponte nossa" if comune=="nossa"
*novella= 2020
*verificare olgiate calco in olgiate molgora
replace comune= "ora" if comune=="ora/auer"
*orino-azzio
replace comune="ortisei" if comune=="ortisei/st. ulrich"
replace comune= "paderno ponchielli" if comune=="paderno ossolaro"
*paderno-robbiate
replace comune= "paganico sabino" if comune=="paganico"
replace comune= "piverone" if comune=="palazzo piverone"
*palvareto
replace comune= "ronzo-chienis" if comune=="pannone"
replace comune= "parella" if comune=="pedanea"
replace comune= "san paolo" if comune=="pedergnaga oriano"
replace comune= "perca" if comune=="perca/percha"
replace comune= "turania" if comune=="petescia"
*piadena-rizzona=2019
replace comune= "pian di sco" if comune=="pian di sco'"
*pieve del grappa= 2019
*pieve di bono-prezzo
*pieve di ledro
*pistolesa
replace comune= "plaus" if comune=="plaus/plaus"
*poggio torriana
replace comune= "pojana maggiore" if comune=="poiana maggiore"
*polesine zibello
replace comune= "polpenazze del garda" if comune=="polpenazze"
*pometo
*poncarale flero 
replace comune= "pontboset" if comune=="pont boset"
replace comune= "pontboset" if comune=="pont bozet"
replace comune= "pont-saint-martin" if comune=="pont saint martin"
replace comune= "ponte gardena" if comune=="ponte gardena/waidbruck"
*ponte di rendena
replace comune= "civitanova marche" if comune=="porto civitanova"
replace comune= "postal" if comune=="postal/burgstall"
replace comune= "pozzaglia sabina" if comune=="pozzaglia sabino"
replace comune= "prato allo stelvio" if comune=="prato allo stelvio/prad am stilfser joch"
*pratovecchio stia
replace comune= "pre'-saint-didier" if comune=="pre' saint didier"
*predaia
replace comune= "predoi" if comune=="predoi/prettau"
replace comune= "proves" if comune=="proves/proveis"
replace comune= "brallo di pregola" if comune=="pregola"
replace comune= "premosello-chiovenda" if comune=="premosello chiovenda"
*primiero e primiero san martino di castrozza
replace comune= "puegnago sul garda" if comune=="puegnago"
replace comune= "puegnago sul garda" if comune=="puegnago del garda"
*quaregna cerreto=2019
*quarna: sopra o sotto?
*quero vas
replace comune= "racines" if comune=="racines/ratschings"
replace comune= "rasun-anterselva" if comune=="rasun anterselva"
replace comune= "rasun-anterselva" if comune=="rasun anterselva/rasen-antholz"
replace comune= "reana del rojale" if comune=="reana del roiale"
*renate-veduggio
replace comune= "renon" if comune=="renon/ritten"
replace comune= "rhêmes-notre-dame" if comune=="rhemes notre dame"
replace comune= "rhêmes-notre-dame" if comune=="rhemes-notre-dame"
replace comune= "rhêmes-saint-georges" if comune=="rhemes saint georges"
replace comune= "rhêmes-saint-georges" if comune=="rhemes-saint-georges"
replace comune= "rifiano" if comune=="rifiano/riffian"
replace comune= "rio di pusteria" if comune=="rio di pusteria/m_hlbach"
replace comune= "rio di pusteria" if comune=="rio di pusteria/muhlbach"
replace comune= "rio di pusteria" if comune=="rio di pusteria/mÜhlbach"
*comune rio?
*riva del po= 2019
replace comune= "riva del garda" if comune=="riva"
*riva santo stefano
replace comune= "rivanazzano terme" if comune=="rivanazzano"
replace comune= "rive d'arcano" if comune=="rive d arcano"
*riviera d adda
*rivignano teor e rivignano?
*rocca di colle
replace comune= "rodengo saiano" if comune=="rodengo-saiano"
replace comune= "rodengo" if comune=="rodengo/rodeneck"
replace comune= "roncegno terme" if comune=="roncegno"
*roreto chisone
*rovetta e rovetta con fino?
replace comune= "ruffre'-mendola" if comune=="ruffre'"
replace comune= "saint-christophe" if comune=="saint christophe"
replace comune= "saint-denis" if comune=="saint denis"
replace comune= "saint-marcel" if comune=="saint marcel"
replace comune= "saint-nicolas" if comune=="saint nicolas"
replace comune= "saint-oyen" if comune=="saint oyen"
replace comune= "saint-pierre" if comune=="saint pierre"
replace comune= "saint-rhe'my-en-bosses" if comune=="saint rhemy"
replace comune= "saint-rhe'my-en-bosses" if comune=="saint-rhemy-en-bosses"
replace comune= "saint-rhe'my-en-bosses" if comune=="saint-rhemy"
replace comune= "saint-vincent" if comune=="saint vincent"
replace comune= "salorno sulla strada del vino" if comune=="salorno sulla strada del vino/salurn an der weinstrasse"
replace comune= "salorno" if comune=="salorno/salurn"
replace comune= "san candido" if comune=="san candido/innichen"
replace comune= "san dorligo della valle-dolina" if comune=="san dorligo della valle"
*san felice in trentino?
replace comune= "san genesio atesino/jenesien" if comune=="san genesio atesino"
replace comune= "san giorgio di mantova" if comune=="san giorgio bigarello"
replace comune= "villa san giovanni in tuscia" if comune=="san giovanni di bieda"
*san giovanni di fassa=2018
replace comune= "san leonardo in passiria" if comune=="san leonardo in passiria/st. leonhard in passeier"
replace comune= "san lorenzo di sebato" if comune=="san lorenzo di sebato/st. lorenzen"
*san lorenzo dorsino
replace comune= "san marcello" if comune=="san marcello piteglio"
*san martino de calvi
replace comune= "san martino in badia" if comune=="san martino in badia/st. martin in thurn"
replace comune= "san martino in passiria" if comune=="san martino in passiria/st. martin in passeier"
*san marzano moasca
replace comune= "san pancrazio" if comune=="san pancrazio/st. pankraz"
replace comune= "sanremo" if comune=="san remo"
replace comune= "sant'angelo lodigiano" if comune=="sant angelo lodigiano"
replace comune= "santarcangelo di romagna" if comune=="sant arcangelo di romagna"
replace comune= "serra sant'abbondio" if comune=="sant'abbondio"
replace comune= "sant'ambrogio di torino" if comune=="sant'ambrogio di susa"
replace comune= "sant'andrea del garigliano" if comune=="sant'andrea"
replace comune= "sant'omobono terme" if comune=="sant'omobono imagna"
replace comune= "sant'orsola terme" if comune=="sant'orsola"
replace comune= "santa cristina valgardena" if comune=="santa cristina valgardena/st. christina in groden"
replace comune= "santa cristina valgardena" if comune=="santa cristina valgardena/st. christina in grÍden"
replace comune= "santa cristina valgardena" if comune=="santa cristina valgardena/st. christina in grÖden"
replace comune= "santa maria hoe'" if comune=="santa maria di rovagnate"
*santa maria rezzonico 
*santa valeria
replace comune= "san stino di livenza" if comune=="santo stino di livenza"
replace comune= "sarentino" if comune=="sarentino/sarntal"
replace comune= "sassocorvaro" if comune=="sassocorvaro auditore"
*scandeluzza
*scarperia e san piero 
replace comune= "scena" if comune=="scena/schenna"
*sella giudicarie
replace comune= "selva dei molini" if comune=="selva dei molini/m_hlwald"
replace comune= "selva dei molini" if comune=="selva dei molini/muhlwald"
replace comune= "selva dei molini" if comune=="selva dei molini/mÜhlwald"
replace comune= "selva di val gardena" if comune=="selva di v. g./wolkenstein in g."
replace comune= "selva di val gardena" if comune=="selva di val gardena/wolkenstein in groden"
replace comune= "selva di val gardena" if comune=="selva di val gardena/wolkenstein in grÍden"
replace comune= "selva di val gardena" if comune=="selva di val gardena/wolkenstein in grÖden"
replace comune= "senale-san felice" if comune=="senale-s. f./unsere l. f. im w.-st. f."
replace comune= "senale-san felice" if comune=="senale-san felice/unsere liebe frau im walde-st. felix"
replace comune= "senale-san felice" if comune=="senale"
replace comune= "senales" if comune=="senales/schnals"
*seprio
*sermide e felonica= fusione 2017
replace comune= "serra de' conti" if comune=="serra de'conti"
replace comune= "sesto" if comune=="sesto/sexten"
replace comune= "tavagnasco" if comune=="settimo tavagnasco"
replace comune= "silandro" if comune=="silandro/schlanders"
replace comune= "sillano" if comune=="sillano giuncugnano"
replace comune= "sissa" if comune=="sissa trecasali"
replace comune= "sluderno" if comune=="sluderno/schluderns"
*solbiate con cagno=2019
replace comune= "soraga" if comune=="soraga di fassa"
*sorbano
replace comune= "sorbolo" if comune=="sorbolo mezzani"
replace comune= "sotto il monte giovanni xxiii" if comune=="sotto il monte"
replace comune= "spinone al lago" if comune=="spinone"
*spor: minore o maggiore?
replace comune= "stelvio" if comune=="stelvio/stilfs"
replace comune= "strambino" if comune=="strambino romano"
*replace comune= "campolongo tapogliano" if comune=="tapogliano"
*tenda
replace comune= "terento" if comune=="terento/terenten"
replace comune= "terlano" if comune=="terlano/terlan"
replace comune= "termeno sulla strada del vino" if comune=="termeno sulla strada del vino/tramin an der weinstrasse"
replace comune= "termeno sulla strada del vino" if comune=="termeno sulla s. d. v./tramin a. d. w."
replace comune= "terranova dei passerini" if comune=="terranuova dei passerini"
*terre d'adige =2019
*terre del reno
*terre roveresche
replace comune= "terelle" if comune=="terrelle"
replace comune= "tesimo" if comune=="tesimo/tisens"
*tiarno, tiarno di sopra e tiarno di sotto?
replace comune= "tires" if comune=="tires/tiers"
replace comune= "tirolo" if comune=="tirolo/tirol"
*tizzana
replace comune= "tollegno" if comune=="tollengo"
replace comune= "torre de' busi" if comune=="torre de busi"
replace comune= "toscolano-maderno" if comune=="toscolano maderno"
*replace comune= "borgo tossignano" if comune=="tossignano"
*trassilico
replace comune= "treville" if comune=="tre ville"
*trecastelli
*tremezzo e tremezzina
replace comune= "tremosine" if comune=="tremosine sul garda"
*treppo ligosullo = 2018
*tresignana= 2019
*tretto
replace comune= "trodena nel parco naturale" if comune=="trodena"
replace comune= "trodena nel parco naturale" if comune=="trodena nel parco naturale/truden im naturpark"
replace comune= "trodena nel parco naturale" if comune=="trodena/truden"
replace comune= "tubre" if comune=="tubre/taufers im m_nstertal"
replace comune= "tubre" if comune=="tubre/taufers im munstertal"
replace comune= "tubre" if comune=="tubre/taufers im mÜnstertal"
replace comune= "ultimo" if comune=="ultimo/ulten"
replace comune= "vadena" if comune=="vadena/pfatten"
*val brembilla
*val di chy=2019
replace comune= "val di vizze" if comune=="val di vizze/pfitsch"
*val di zoldo
*val liona
replace comune= "marchirolo" if comune=="val marchirolo"
*valbrenta=2019
*valchiusa=2019
*valdaone
replace comune= "valdaora" if comune=="valdaora/olang"
*valdilana= 2019
*valfornace
replace comune= "valle aurina" if comune=="valle aurina/ahrntal"
replace comune= "valle di casies" if comune=="valle di casies/gsies"
replace comune= "vandoies" if comune=="vandoies/vintl"
replace comune= "varna" if comune=="varna/vahrn"
replace comune= "velturno" if comune=="velturno/feldthurns"
replace comune= "verano" if comune=="verano/voran"
replace comune= "verano" if comune=="verano/vÍran"
replace comune= "verano" if comune=="verano/vÖran"
replace comune= "verre's" if comune=="verr+s"
replace comune= "verre's" if comune=="verres"
replace comune= "verre's" if comune=="verrÈs"
replace comune= "villabassa" if comune=="villabassa/niederdorf"
replace comune= "villandro" if comune=="villandro *"
replace comune= "villandro" if comune=="villandro/villanders"
replace comune= "valgrisenche" if comune=="valgrisanche"
*valle cannobina= 2019
*vallefoglia
*vallelaghi
replace comune= "vallio terme" if comune=="vallio"
replace comune= "valsavarenche" if comune=="valsavaranche"
*valsamoggia
*valsaviore
replace comune= "valtournenche" if comune=="valtournanche"
*valvarrone= 2018
*valvasone arzene
replace comune= "venaus" if comune=="venalzio"
replace comune= "venaria reale" if comune=="venaria"
*ventasso
replace comune= "vipiteno" if comune=="vipiteno/sterzing"
*verderio, verderio superiore e verderio inferiore
replace comune= "verucchio" if comune=="vericchio"
*vermezzo con zelo
replace comune= "viale" if comune=="viale d'asti"
replace comune= "vigliano biellese" if comune=="vigliano' biellese"
*corsione e villa corsione
replace comune= "challand-saint-anselme" if comune=="villa sant anselmo"
*villavesco
*ville d'anaunia
*ville di fiemme= 2020
replace comune= "vito d'asio" if comune=="vito d asio"
replace comune= "vo'" if comune=="vo"
replace comune= "zeme" if comune=="zeme lomellina"
replace comune= "ziano di fiemme" if comune=="ziano"
replace comune="gornate-olona" if comune == "gornate olona"
split comune, p("/")
drop comune2 comune
rename comune1 comune

**# generate turnout **
sort comune data_ref
order comune data_ref regione circoscrizione provincia
gen turnout_ref = votanti/elettori

* inspect turnout *
summ turnout_ref, detail
ta data_ref if turnout_ref > 1
replace turnout_ref = . if turnout_ref > 1

* drop regions of the south *
foreach x in "sicilia" "calabria" "sardegna" "puglia" "molise" "basilicata" "abruzzo" "campania" {
	* PACKAGE: line disabled, see header -- drop if regione == "`x'"
}

**# save long version **
save "$derived/turnout_referendum_long.dta", replace

* collapse *
gen anno = year(data_ref)
collapse (mean) turnout_ref (first) regione provincia, by(comune anno)
rename regione regione_ref
rename provincia provincia_ref

**# save long yearly version *
save "$derived/turnout_referendum_long_yearly.dta", replace

**# reshape and save wide yearly version *
reshape wide turnout_ref regione_ref provincia_ref, i(comune) j(anno)
save "$derived/turnout_referendum_wide_yearly_updt.dta", replace
cd "$root"   // PACKAGE: return to the package root
