********************************************************************************
*** 03_european_turnout.do                                                   ***
*** Municipal turnout in European Parliament elections, 1979-2014            ***
*** (Eligendo, Ministry of the Interior).                                    ***
*** Input:  data/raw/eligendo_european/SCRUTINI_europee.xlsx                 ***
*** Output: data/derived/turnout_europee_wide_updt.dta                       ***
*** Source: original dati/social capital/data_mgmt_europee.do.               ***
***         Changes (lines marked PACKAGE): file paths, the author-specific  ***
***         path block is commented out, and the line that dropped the       ***
***         Southern regions is disabled. The original dropped the South for ***
***         an earlier Centre-North project; the file used by the paper      ***
***         covers all of Italy, and with this one line disabled the output  ***
***         is identical to it (Stata -cf-, all 29 variables).               ***
********************************************************************************
version 18
clear all
set more off

/* PACKAGE: author-specific paths, not used (paths are set in master.do)
*********** HERE YOU TYPE 1 ON YOUR NAME AND 0 OTHERWISE *****************
global federico 1
global francesca 0
**************************************************************************

if("$federico" == "1") {
global dropbox "C:\path\to\mafia_social_capital"
global data "C:\path\to\mafia_social_capital\dati"
global mafia "C:\path\to\mafia_social_capital\dati\mafia"
global social_capital "C:\path\to\mafia_social_capital\dati\social capital"
global output "C:\path\to\mafia_social_capital\output"
global tables_pres "C:\path\to\mafia_social_capital\presentations\Al Capone\update_tables"
global draft "C:\path\to\mafia_social_capital\draft\tables"
}

if("$francesca" == "1") {
global data "C:\path\to\mafia_social_capital\dati"
global mafia "C:\path\to\mafia_social_capital\dati\mafia"
global social_capital "C:\path\to\mafia_social_capital\dati\social capital"
global output "C:\path\to\mafia_social_capital\output"
 
}
*
*/

** importing excel file **
import excel "$raw/eligendo_european/SCRUTINI_europee.xlsx", sheet("SCRUTINI") firstrow clear


** data management **

* sort *
sort DATAELEZIONE DESCRCIRC DESCRREG DESCRPROV DESCRCOMUNE

* gen year variable *
gen anno_elezione=year(DATAELEZIONE) 

* rename comune and replace in lowercase *
rename DESCRCOMUNE Comune
replace Comune=trim(lower(Comune))
drop if Comune==""
replace DESCRPROV=trim(upper(DESCRPROV))
replace DESCRREG=trim(upper(DESCRREG))

* keep centre-north *
* PACKAGE: line disabled, see header -- drop if DESCRREG == "ABRUZZI" | DESCRREG == "ABRUZZO" | DESCRREG == "BASILICATA" | DESCRREG == "CALABRIA" | DESCRREG == "CAMPANIA" | DESCRREG == "MOLISE" | DESCRREG == "PUGLIA" | DESCRREG == "SICILIA" | DESCRREG == "SARDEGNA"   

* manage regions and provinces *
replace DESCRPROV = "FORLI'-CESENA" if DESCRPROV == "FORLì-CESENA"
replace DESCRPROV = "REGGIO NELL'EMILIA" if DESCRPROV == "REGGIO EMILIA"
replace DESCRREG = "EMILIA ROMAGNA" if DESCRREG == "EMILIA-ROMAGNA"
replace DESCRREG = "FRIULI VENEZIA GIULIA" if DESCRREG == "FRIULI-VENEZIA GIULIA"
replace DESCRREG = "TRENTINO ALTO ADIGE" if DESCRREG == "TRENTINO-ALTO ADIGE"

* manage accents *
replace Comune=subinstr(Comune,"è","e'",.)
replace Comune=subinstr(Comune,"é","e'",.)
replace Comune=subinstr(Comune,"ò","o'",.)
replace Comune=subinstr(Comune,"ì","i'",.)
replace Comune=subinstr(Comune,"à","a'",.)
replace Comune=subinstr(Comune,"ù","u'",.)
replace Comune=subinstr(Comune,"Ã¹","u'",.)
replace Comune=subinstr(Comune,"Ã¨","e'",.)
replace Comune=subinstr(Comune,"Ã¬","i'",.)
replace Comune=subinstr(Comune,"Ã²","o'",.)
replace Comune=subinstr(Comune,"Ã ","a'",.)	

* manage duplicates *
replace Comune="brione (bs)" if Comune=="brione" & DESCRPROV=="BRESCIA"
replace Comune="brione (tn)" if Comune=="brione" & DESCRPROV=="TRENTO"
replace Comune="calliano (tn)" if Comune=="calliano" & DESCRPROV=="TRENTO"
replace Comune="calliano (at)" if Comune=="calliano" & DESCRPROV=="ASTI"
replace Comune="castro (bg)" if Comune=="castro" & DESCRPROV=="BERGAMO"
replace Comune="castro (le)" if Comune=="castro" & DESCRPROV=="LECCE"
replace Comune="samone (to)" if Comune=="samone" & DESCRPROV=="TORINO"
replace Comune="samone (tn)" if Comune=="samone" & DESCRPROV=="TRENTO"
replace Comune="san teodoro (ss)" if Comune=="san teodoro" & DESCRPROV=="NUORO"
replace Comune="san teodoro (me)" if Comune=="san teodoro" & DESCRPROV=="MESSINA"
replace Comune="livo (co)" if Comune=="livo" & DESCRPROV=="COMO"
replace Comune="livo (tn)" if Comune=="livo" & DESCRPROV=="TRENTO"
replace Comune="peglio (co)" if Comune=="peglio" & DESCRPROV=="COMO"
replace Comune="peglio (pu)" if Comune=="peglio" & DESCRPROV=="PESARO E URBINO"	
replace Comune="valverde (ct)" if Comune=="valverde" & DESCRPROV=="CATANIA"
replace Comune="valverde (pv)" if Comune=="valverde" & DESCRPROV=="PAVIA" 	

* manage comuni *
split Comune, p("/")
replace Comune = Comune1
drop Comune1 Comune2
bys Comune (anno_elezione): egen time = seq()
bys Comune (anno_elezione): egen ma_time = max(time)
rename Comune comune
sort comune anno_elezione
replace comune = comune[_n+1] if ma_time == 1 & ma_time[_n+1] == 7 & DESCRPROV == DESCRPROV[_n+1]
drop time ma_time
bys comune (anno_elezione): egen time = seq()
bys comune (anno_elezione): egen ma_time = max(time)
br comune anno_elezione ma_time if ma_time <= 7
replace comune = "agliano terme" if comune == "agliano"
replace comune = "appiano gentile" if comune == "aiano gentile"
replace comune = "appiano sulla strada del vino" if comune == "aiano sulla strada del vino"
replace comune = "albissola marina" if comune == "albisola marina"
replace comune = "albisola superiore" if comune == "albisola sueriore"
replace comune = "aquila d'arroscia" if comune == "aquila di arroscia"
replace comune = "ariano nel polesine" if comune == "ariano nel olesine"
replace comune = "arqua' petrarca" if comune == "arqua petrarca"
replace comune = "arqua' polesine" if comune == "arqua polesine"
replace comune = "paullo" if comune == "aullo"
replace comune = "badia polesine" if comune == "badia olesine"
replace comune = "bajardo" if comune == "baiardo"
replace comune = "bastia umbra" if comune == "bastia"
replace comune = "bastia mondovi'" if comune == "bastia mondovi"
replace comune = "bastida de' dossi" if comune == "bastida de dossi"
replace comune = "borghetto santo spirito" if comune == "borghetto santo s."
replace comune = "borghetto santo spirito" if comune == "borghetto santo sirito"
replace comune = "borgomanero" if comune == "borgomanero                                      1"
replace comune = "brenzone" if comune == "brenzone sul garda"
replace comune = "brignano-frascata" if comune == "brignano frascata"
replace comune = "buja" if comune == "buia"
replace comune = "cadelbosco di sopra" if comune == "cadelbosco di sora"
replace comune = "caderzone terme" if comune == "caderzone"
replace comune = "campiglione fenile" if comune == "campiglione-fenile"
replace comune = "campo nell'elba" if comune == "campo nell elba"
replace comune = "campo ligure" if comune == "campoligure"
replace comune = "canneto sull'oglio" if comune == "canneto sull oglio"
replace comune = "carcare" if comune == "car care"
replace comune = "capriate san gervasio" if comune == "cariate san gervasio"
replace comune = "carineto romano" if comune == "carpineto romano"
replace comune = "carpaneto piacentino" if comune == "caraneto iacentino"
replace comune = "carpenedolo" if comune == "carenedolo"
replace comune = "casciana terme" if comune == "casciana terme lari"
replace comune = "casorate primo" if comune == "casorate rimo"
replace comune = "cassina de' pecchi" if comune == "cassina de pecchi"
replace comune = "cassina de' pecchi" if comune == "cassina de' ecchi"
replace comune = "castano primo" if comune == "castano rimo"
replace comune = "castel d'aiano" if comune == "castel d aiano"
replace comune = "castel d'azzano" if comune == "castel d azzano"
replace comune = "castel san giovanni" if comune == "castel san giovanni."
replace comune = "castel sant'angelo" if comune == "castel sant angelo"
replace comune = "castel sant'elia" if comune == "castel sant elia"
replace comune = "castelbello-ciardes" if comune == "castelbello ciardes"
replace comune = "castell'arquato" if comune == "castell arquato"
replace comune = "castellarano" if comune == "castellarano."
replace comune = "castelletto sopra ticino" if comune == "castelletto sora ticino"
replace comune = "castello d'agogna" if comune == "castello d agogna"
replace comune = "castello d'argile" if comune == "castello d argile"
replace comune = "castello-molina di fiemme" if comune == "castello molina di fiemme"
replace comune = "castiglione d'adda" if comune == "castiglione d adda"
replace comune = "castiglione d'intelvi" if comune == "castiglione d intelvi"
replace comune = "cerreto d'esi" if comune == "cerreto d esi"
replace comune = "cerreto delle langhe" if comune == "cerreto  langhe"
replace comune = "cerreto delle langhe" if comune == "cerretto delle langhe"
replace comune = "cerreto delle langhe" if comune == "cerretto langhe"
replace comune = "cerrina monferrato" if comune == "cerrina"
replace comune = "challand-saint-victor" if comune == "challand saint anselme"
replace comune = "ciano d'enza" if comune == "ciano d enza"
replace comune = "citta' della pieve" if comune == "citta della pieve"
replace comune = "citta' della pieve" if comune == "citta' della ieve"
replace comune = "citta' di castello" if comune == "citta di castello"
replace comune = "civita castellana" if comune == "civitacastellana"
replace comune = "cornale" if comune == "cornale e bastida"
replace comune = "corte de' frati" if comune == "corte de frati"
replace comune = "cortina d'ampezzo" if comune == "cortina d ampezzo"
replace comune = "cortina d'ampezzo" if comune == "cortina d'amezzo"
replace comune = "costa di serina" if comune == "costa  serina"
replace comune = "costa di serina" if comune == "costa serina"
replace comune = "crespellano" if comune == "cresellano"
replace comune = "crespina" if comune == "crespina lorenzana"
replace comune = "crevola d'ossola" if comune == "crevola d ossola"
replace comune = "crevola d'ossola" if comune == "crevoladossola"
replace comune = "due carrare" if comune == "duedue carrare"
replace comune = "fabbriche di vergemoli" if comune == "fabbriche di vallico"
replace comune = "farra d'alpago" if comune == "farra d alpago"
replace comune = "farra d'isonzo" if comune == "farra d isonzo"
replace comune = "fornovo di taro" if comune == "fornovodi taro"
replace comune = "fossalta di portogruaro" if comune == "fossalta di ortogruaro"
replace comune = "gabbioneta-binanuova" if comune == "gabbioneta binanuova"
replace comune = "garniga terme" if comune == "garniga"
replace comune = "godiasco" if comune == "godiasco salice terme"
replace comune = "gravedona" if comune == "gravedona ed uniti"
replace comune = "gressoney-la trinite'" if comune == "gressoney la trinite"
replace comune = "gressoney-saint-jean" if comune == "gressoney saint jean"
replace comune = "pianoro" if comune == "ianoro"
replace comune = "piazzola sul brenta" if comune == "iazzola sul brenta"
replace comune = "pieve a nievole" if comune == "ieve a nievole"
replace comune = "pieve di bono" if comune == "ieve di bono"
replace comune = "pieve di cento" if comune == "ieve di cento"
replace comune = "pieve di soligo" if comune == "ieve di soligo"
replace comune = "incisa in val d'arno" if comune == "incisa in val d arno"
replace comune = "piombino dese" if comune == "iombino dese"
replace comune = "piovene rocchette" if comune == "iovene rocchette"
replace comune = "pisogne" if comune == "isogne"
replace comune = "pisolato" if comune == "isolato"
replace comune = "pizzighettone" if comune == "izzighettone"
replace comune = "leini'" if comune == "leini"
replace comune = "plaus" if comune == "laus"
replace comune = "lonato" if comune == "lonato del garda"
replace comune = "lugagnano val d'arda" if comune == "lugagnano val darda"
replace comune = "maccagno" if comune == "maccagno con pino e veddasca"
replace comune = "malborghetto valbruna" if comune == "malborghetto-valbruna"
replace comune = "masera' di padova" if comune == "masera di padova"
replace comune = "masera' di padova" if comune == "masera' di adova"
replace comune = "monguelfo-tesido" if comune == "monguelfo"
replace comune = "monte porzio catone" if comune == "monte orzio catone"
replace comune = "monte san pietro" if comune == "monte san ietro"
replace comune = "monte grimano" if comune == "monte grimano terme"
replace comune = "montecastello" if comune == "monte castello"
replace comune = "montecatini-terme" if comune == "monte catini terme"
replace comune = "montecompatri" if comune == "montecomatri"
replace comune = "monteforte d'alpone" if comune == "monteforte d alpone"
replace comune = "monteforte d'alpone" if comune == "monteforte d'alone"
replace comune = "montegrino valtravaglia" if comune == "montegrino-valtravaglia"
replace comune = "montelupo fiorentino" if comune == "monteluo fiorentino"
replace comune = "monteprandone" if comune == "monterandone"
replace comune = "montepulciano" if comune == "monteulciano"
replace comune = "monticello" if comune == "monticello brianza"
replace comune = "montiglio" if comune == "montiglio monferrato"
replace comune = "montopoli in val d'arno" if comune == "montopoli in val d arno"
replace comune = "mosso santa maria" if comune == "mosso"
replace comune = "naz sciaves" if comune == "naz-sciaves"
replace comune = "nepi" if comune == "nei"
replace comune = "podenzano" if comune == "odenzano"
replace comune = "poggio renatico" if comune == "oggio renatico"
replace comune = "pogliano milanese" if comune == "ogliano milanese"
replace comune = "pollenza" if comune == "ollenza"
replace comune = "pomarance" if comune == "omarance"
replace comune = "pomarolo" if comune == "omarolo"
replace comune = "opera" if comune == "oera"
replace comune = "ponsacco" if comune == "onsacco"
replace comune = "ponte buggianese" if comune == "onte buggianese"
replace comune = "ponte di piave" if comune == "onte di iave"
replace comune = "ponte gardena" if comune == "onte gardena"
replace comune = "ponte nelle ali" if comune == "onte nelle ali"
replace comune = "ponte san nicolo'" if comune == "onte san nicolo'"
replace comune = "pontecorvo" if comune == "ontecorvo"
replace comune = "pontenure" if comune == "ontenure"
replace comune = "ponteranica" if comune == "onteranica"
replace comune = "pontevico" if comune == "ontevico"
replace comune = "pontinia" if comune == "ontinia"
replace comune = "pontoglio" if comune == "ontoglio"
replace comune = "pontremoli" if comune == "ontremoli"
replace comune = "ponzano veneto" if comune == "onzano veneto"
replace comune = "porto mantovano" if comune == "orto mantovano"
replace comune = "porto recanati" if comune == "orto recanati"
replace comune = "porto tolle" if comune == "orto tolle"
replace comune = "portoferraio" if comune == "ortoferraio"
replace comune = "ospedaletto euganeo" if comune == "osedaletto euganeo"
replace comune = "ospitaletto" if comune == "ositaletto"
replace comune = "postal" if comune == "ostal"
replace comune = "potenza picena" if comune == "otenza icena"
replace comune = "pozza di fassa" if comune == "ozza di fassa"
replace comune = "pozzuolo martesana" if comune == "ozzuolo martesana"
replace comune = "paganico sabino" if comune == "paganico"
replace comune = "palu'" if comune == "palu"
replace comune = "palu' del fersina" if comune == "palu del fersina"
replace comune = "pare'" if comune == "pare"
replace comune = "peccioli" if comune == "eccioli"
replace comune = "panicale" if comune == "anicale"
replace comune = "pandino" if comune == "andino"
replace comune = "paliano" if comune == "aliano"
replace comune = "pederobba" if comune == "ederobba"
replace comune = "pegognaga" if comune == "egognaga"
replace comune = "peio" if comune == "eio"
replace comune = "pelago" if comune == "elago"
replace comune = "perca" if comune == "erca"
replace comune = "pergola" if comune == "ergola"
replace comune = "persico d'osimo" if comune == "persico dosimo"
replace comune = "persico d'osimo" if comune == "ersico d'osimo"
replace comune = "pescantina" if comune == "escantina"
replace comune = "pianoro" if comune == "ianoro"
replace comune = "piazzola sul brenta" if comune == "iazzola sul brenta"
replace comune = "pieve a nievole" if comune == "ieve a nievole"
replace comune = "pieve d'olmi" if comune == "pieve d olmi"
replace comune = "pieve di bono" if comune == "ieve di bono"
replace comune = "pieve di cento" if comune == "ieve di cento"
replace comune = "pieve di soligo" if comune == "ieve di soligo"
replace comune = "piombino dese" if comune == "iombino dese"
replace comune = "piovene rocchette" if comune == "iovene rocchette"
replace comune = "pisogne" if comune == "isogne"
replace comune = "pizzighettone" if comune == "izzighettone"
replace comune = "plaus" if comune == "laus"
replace comune = "podenzano" if comune == "odenzano"
replace comune = "poggio renatico" if comune == "oggio renatico"
replace comune = "pogliano milanese" if comune == "ogliano milanese"
replace comune = "pojana maggiore" if comune == "poiana maggiore"
replace comune = "pollenza" if comune == "ollenza"
replace comune = "pomarance" if comune == "omarance"
replace comune = "pomarolo" if comune == "omarolo"
replace comune = "ponsacco" if comune == "onsacco"
replace comune = "pont-canavese" if comune == "pont canavese"
replace comune = "pont-saint-martin" if comune == "pont saint martin"
replace comune = "ponte buggianese" if comune == "onte buggianese"
replace comune = "ponte di piave" if comune == "onte di iave"
replace comune = "ponte gardena" if comune == "onte gardena"
replace comune = "ponte nelle alpi" if comune == "onte nelle ali"
replace comune = "ponte san nicolo'" if comune == "onte san nicolo'"
replace comune = "pontecorvo" if comune == "ontecorvo"
replace comune = "pontenure" if comune == "ontenure"
replace comune = "ponteranica" if comune == "onteranica"
replace comune = "pontevico" if comune == "ontevico"
replace comune = "pontinia" if comune == "ontinia"
replace comune = "pontoglio" if comune == "ontoglio"
replace comune = "pontremoli" if comune == "ontremoli"
replace comune = "ponzano veneto" if comune == "onzano veneto"
replace comune = "poppi" if comune == "oi"
replace comune = "porto mantovano" if comune == "orto mantovano"
replace comune = "porto recanati" if comune == "orto recanati"
replace comune = "porto tolle" if comune == "orto tolle"
replace comune = "porto viro" if comune == "porto viro                              *"
replace comune = "portoferraio" if comune == "ortoferraio"
replace comune = "portomaggiore" if comune == "porto maggiore"
replace comune = "portomaggiore" if comune == "ortomaggiore"
replace comune = "postal" if comune == "ostal"
replace comune = "potenza picena" if comune == "otenza icena"
replace comune = "poviglio" if comune == "oviglio"
replace comune = "povoletto" if comune == "ovoletto"
replace comune = "povoletto" if comune == "povoletto                               m"
replace comune = "pozza di fassa" if comune == "ozza di fassa"
replace comune = "pozzaglia sabina" if comune == "pozzaglia sabino"
replace comune = "pozzuolo martesana" if comune == "ozzuolo martesana"
replace comune = "prato allo stelvio" if comune == "rato allo stelvio"
replace comune = "pratovecchio" if comune == "pratovecchio stia"
replace comune = "predappio" if comune == "redaio"
replace comune = "predoi" if comune == "redoi"
replace comune = "preganziol" if comune == "reganziol"
replace comune = "pregnana milanese" if comune == "regnana milanese"
replace comune = "priverno" if comune == "riverno"
replace comune = "proves" if comune == "roves"
replace comune = "puegnago del garda" if comune == "puegnago sul garda"
replace comune = "quero" if comune == "quero vas"
replace comune = "rapolano terme" if comune == "raolano terme"
replace comune = "reana del rojale" if comune == "reana del roiale"
replace comune = "remanzacco" if comune == "remanzacco                              m"
replace comune = "rhemes-saint-georges" if comune == "rhemes notre dame"
replace comune = "rio di pusteria" if comune == "rio di usteria"
replace comune = "ripe" if comune == "rii"
replace comune = "rivanazzano" if comune == "rivanazzano terme"
replace comune = "rivignano" if comune == "rivignano teor"
replace comune = "ro" if comune == "ro ferrarese"
replace comune = "rocca d'arce" if comune == "rocca d arce"
replace comune = "rocca de' baldi" if comune == "rocca de baldi"
replace comune = "rocca de' giorgi" if comune == "rocca de giorgi"
replace comune = "roncegno" if comune == "roncegno terme"
replace comune = "rovere' della luna" if comune == "rovere della luna"
replace comune = "rovere' veronese" if comune == "rovere veronese"
replace comune = "ruffre'" if comune == "ruffre"
replace comune = "ruffre'" if comune == "ruffre'-mendola"
replace comune = "saint-denis" if comune == "saint denis"
replace comune = "saint-marcel" if comune == "saint marcel"
replace comune = "saint-nicolas" if comune == "saint nicolas"
replace comune = "saint-oyen" if comune == "saint oyen"
replace comune = "saint-pierre" if comune == "saint pierre"
replace comune = "saint-rhemy-en-bosses" if comune == "saint-rhemy"
replace comune = "san pancrazio" if comune == "san ancrazio"
replace comune = "san colombano al lambro" if comune == "san colombano al lambro                          5"
replace comune = "san pellegrino terme" if comune == "san ellegrino terme"
replace comune = "san giorgio di piano" if comune == "san giorgio di iano"
replace comune = "san pietro in cariano" if comune == "san ietro in cariano"
replace comune = "san pietro in casale" if comune == "san ietro in casale"
replace comune = "san martino in passiria" if comune == "san martino in assiria"
replace comune = "san mauro pascoli" if comune == "san mauro ascoli"
replace comune = "sanremo" if comune == "san remo"
replace comune = "sant'abbondio" if comune == "sant abbondio"
replace comune = "sant'agata bolognese" if comune == "sant agata bolognese"
replace comune = "sant'agata feltria" if comune == "sant agata feltria"
replace comune = "sant'agata feltria" if comune == "sant agata feltria"
replace comune = "sant'agata sul santerno" if comune == "sant agata sul santerno"
replace comune = "sant'agostino" if comune == "sant agostino"
replace comune = "sant'albano stura" if comune == "sant albano stura"
replace comune = "sant'ambrogio di torino" if comune == "sant ambrogio di torino"
replace comune = "sant'ambrogio di valpolicella" if comune == "sant ambrogio di valpolicella"
replace comune = "sant'ambrogio sul garigliano" if comune == "sant ambrogio sul garigliano"
replace comune = "sant'anatolia di narco" if comune == "sant anatolia di narco"
replace comune = "sant'andrea del garigliano" if comune == "sant andrea del garigliano"
replace comune = "sant'angelo di piove di sacco" if comune == "sant angelo di piove di sacco"
replace comune = "sant'angelo in lizzola" if comune == "sant angelo in lizzola"
replace comune = "sant'angelo in vado" if comune == "sant angelo in vado"
replace comune = "sant'angelo lodigiano" if comune == "sant angelo lodigiano"
replace comune = "sant'angelo romano" if comune == "sant angelo romano"
replace comune = "sant'anna d'alfaedo" if comune == "sant anna d alfaedo"
replace comune = "sant'antonino di susa" if comune == "sant antonino di susa"
replace comune = "sant'apollinare" if comune == "sant apollinare"
replace comune = "sant'elena" if comune == "sant elena"
replace comune = "sant'elia fiumerapido" if comune == "sant elia fiumerapido"
replace comune = "sant'elpidio a mare" if comune == "sant elpidio a mare"
replace comune = "sant'ilario d'enza" if comune == "sant ilario d enza"
replace comune = "sant'ippolito" if comune == "sant ippolito"
replace comune = "sant'olcese" if comune == "sant olcese"
replace comune = "sant'omobono imagna" if comune == "sant omobono imagna"
replace comune = "sant'oreste" if comune == "sant oreste"
replace comune = "sant'urbano" if comune == "sant urbano"
replace comune = "scarperia" if comune == "scareria"
replace comune = "scarperia" if comune == "scarperia e san piero"
replace comune = "serra de'conti" if comune == "serra de conti"
replace comune = "serra de'conti" if comune == "serra de' conti"
replace comune = "serralunga d'alba" if comune == "serralunga d alba"
replace comune = "spilamberto" if comune == "silamberto"
replace comune = "spello" if comune == "sello"
replace comune = "spormaggiore" if comune == "sormaggiore"
replace comune = "spresiano" if comune == "sresiano"
replace comune = "torre de negri" if comune == "torre de negri"
replace comune = "torre de' picenardi" if comune == "torre de picenardi"
replace comune = "trecasali" if comune == "trecastelli"
replace comune = "trodena nel parco naturale" if comune == "trodena"
replace comune = "valverde" if comune == "valverde (lomb)"
replace comune = "vaprio d'adda" if comune == "vaprio d adda"
replace comune = "vaprio d'agogna" if comune == "vaprio d agogna"
replace comune = "vaprio d'adda" if comune == "vario d'adda"
replace comune = "vezza d'alba" if comune == "vezza d alba"
replace comune = "vezza d'oglio" if comune == "vezza d oglio"
replace comune = "viale d'asti" if comune == "viale"
replace comune = "vicopisano" if comune == "vicoisano"
replace comune = "vigano'" if comune == "vigano"
replace comune = "villa d'alme'" if comune == "villa d alme"
replace comune = "villafranca padovana" if comune == "villafranca adovana"
replace comune = "villanova d'albenga" if comune == "villanova d albenga"
replace comune = "villanova d'ardenghi" if comune == "villanova d ardenghi"
replace comune = "villanova d'asti" if comune == "villanova d asti"
replace comune = "vo'" if comune == "vo"
replace comune = "castro (bg)" if comune == "castro"
replace comune = "cerretto langhe" if comune == "cerreto delle langhe"
replace comune = "châtillon" if comune == "chatillon"
replace comune = "cosio d'arroscia" if comune == "cosio di arroscia"
replace comune = "costa serina" if comune == "costa di serina"
replace comune = "crevoladossola" if comune == "crevola d'ossola"
replace comune = "dro" if comune == "dro'"
replace comune = "duino-aurisina" if comune == "duino aurisina"
replace comune = "emare'se" if comune == "emarese"
replace comune = "fe'nis" if comune == "fenis"
replace comune = "gadesco-pieve delmona" if comune == "gadesco pieve delmona"
replace comune = "godiasco salice terme" if comune == "godiasco"
replace comune = "gornate-olona" if comune == "gornate olona"
replace comune = "hône" if comune == "hone"
replace comune = "jolanda di savoia" if comune == "iolanda di savoia"
replace comune = "jovençan" if comune == "jovencan"
replace comune = "lavena ponte tresa" if comune == "lavena-ponte tresa"
replace comune = "leini" if comune == "leini'"
replace comune = "massa fiscaglia" if comune == "massafiscaglia"
replace comune = "monte grimano terme" if comune == "monte grimano"
replace comune = "monticello brianza" if comune == "monticello"
replace comune = "naz-sciaves" if comune == "naz sciaves"
replace comune = "persico dosimo" if comune == "persico d'osimo"
replace comune = "puegnago sul garda" if comune == "puegnago del garda"
replace comune = "rasun-anterselva" if comune == "rasun anterselva"
replace comune = "rhêmes-notre-dame" if comune == "rhemes-notre-dame"
replace comune = "rhêmes-saint-georges" if comune == "rhemes-saint-georges"
replace comune = "rivanazzano terme" if comune == "rivanazzano"
replace comune = "rodengo saiano" if comune == "rodengo-saiano"
replace comune = "roncegno terme" if comune == "roncegno"
replace comune = "ruffre'-mendola" if comune == "ruffre'"
replace comune = "saint-rhe'my-en-bosses" if comune == "saint-rhemy-en-bosses"
replace comune = "san dorligo della valle-dolina" if comune == "san dorligo della valle"
replace comune = "serra de' conti" if comune == "serra de'conti"
replace comune = "toscolano-maderno" if comune == "toscolano maderno"
replace comune = "valverde (pv)" if comune == "valverde"
replace comune = "verre's" if comune == "verres"
replace comune = "viale" if comune == "viale d'asti"
drop time ma_time
bys comune (anno_elezione): egen time = seq()
bys comune (anno_elezione): egen ma_time = max(time)
br comune anno_elezione ma_time if ma_time >= 9
drop if ma_time >= 9 | ma_time <= 6
drop time ma_time

* rename DATAELEZIONE *
rename DATAELEZIONE data_elezione

* compute turnout *
rename ELETTORITOTALI elettori_euro
rename NUMVOTANTITOTALI votanti_euro
gen turnout_europee=votanti_euro/elettori_euro

* collapse and reshape from long to wide *
collapse (mean) turnout_europee elettori_euro votanti_euro, by(comune anno_elezione)
reshape wide turnout_europee elettori_euro votanti_euro, i(comune) j(anno_elezione)

* generate overall mean *
egen avg_turnout_europee=rowmean(turnout_europee1979 turnout_europee1984 turnout_europee1989 ///
turnout_europee1994 turnout_europee1999 turnout_europee2004 turnout_europee2009 turnout_europee2014)

* generate 00's mean *
egen avg_turnout_europee_00=rowmean(turnout_europee2004 turnout_europee2009 turnout_europee2014)

* generate 90's mean *
egen avg_turnout_europee_90=rowmean(turnout_europee1994 turnout_europee1999)

* generate 80/70's mean *
egen avg_turnout_europee_70=rowmean(turnout_europee1979 turnout_europee1984 turnout_europee1989)

* save it *
save "$derived/turnout_europee_wide_updt.dta", replace
