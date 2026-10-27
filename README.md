# Replication package for "The civic side of tax compliance: Evidence from Italy"

Francesca Maria Calamunci and Federico Fabio Frattini
*Economics Letters* 252 (2025) 112346. https://doi.org/10.1016/j.econlet.2025.112346

Contact: Federico Fabio Frattini (federico.frattini@feem.it), Francesca Maria Calamunci (francescamaria.calamunci@uniroma1.it)

## Overview

The package rebuilds every dataset from the raw files in `data/raw/` and produces every table and figure of the paper. `master.do` runs everything in order: four data-source do-files, one merge do-file, one do-file per exhibit, and three R scripts for the maps. On the machine described below a full run takes about 20 minutes. The package reproduces all numbers in Tables 1, 2 and A.2 and in the captions of Figures 1 and 2 exactly.

## Data availability statement

All data used are public or were constructed by the authors, and all are included in `data/raw/`. Where a file was obtained from a third party, the original source is given so that it can be re-downloaded.

| Folder in `data/raw/` | Content | Source and access | Licence / terms |
|---|---|---|---|
| `istat_census/` | `confini-epoca_01.xlsx` ... `_20.xlsx`, one per region: ISTAT municipal census indicators 1951-2011 at the boundaries of each census ("Indicatori in serie storica 1951-2011 ai confini dell'epoca"): population, elderly index, education gender gap, illiteracy, labour-force participation, etc. | ISTAT, *8milaCensus*, http://ottomilacensus.istat.it/ (regional downloads, "confini dell'epoca"). Files downloaded October 2021. As of October 2026 the site shows a maintenance notice; the files used are included here. | ISTAT open data, CC BY 4.0 (https://www.istat.it/note-legali/) |
| `eligendo_referendum/` | `referendum-YYYYMMDD.zip` (23 files), municipal results of all national referendums 1946-2020 | Ministry of the Interior, *Eligendo Archivio*, open data section: https://elezionistorico.interno.gov.it/eligendo/opendata.php (Referendum dal 1946). Downloaded October 2021 - June 2022. Municipal-level results are not available for 1985-2006. | Open data of the Ministry of the Interior; the portal states no specific licence |
| `eligendo_european/` | `SCRUTINI_europee.xlsx`, municipal results of the European Parliament elections 1979-2014 | Ministry of the Interior, *Eligendo Archivio*, open data section (Elezioni europee dal 1979), same URL as above. Downloaded October 2021. | As above |
| `durante_pinotti_tesei_2019/` | `municipality-level_data.dta`, from which the number of voluntary associations per inhabitant in 1981, 1991 and 2001 (ISTAT censuses) is taken | Replication package of Durante, R., Pinotti, P. and Tesei, A. (2019), "The political legacy of entertainment TV", *American Economic Review* 109(7). openICPSR project 116167, https://doi.org/10.3886/E116167V1 | CC BY 4.0 (data); see the included `LICENSE.txt` |
| `nannicini_social_capital/` | `SOCIAL_CAPITAL.dta`, provincial social-capital measures assigned to municipalities: blood donations, people registered with CONI and CONI associations per 1,000 inhabitants (1999), non-sport newspapers sold per 1,000 inhabitants (2001), WVS trust | Tommaso Nannicini's website, "Measures of social capital for Italian provinces and municipalities", https://www.tommasonannicini.eu/en/research/measures-of-social-capital-for-italian-provinces-and-municipalities/. Compilation used in Nannicini, Stella, Tabellini and Troiano (2013), *AEJ: Economic Policy*; original sources: Guiso, Sapienza and Zingales (2004), Cartocci (2007), and the World Values Survey as used by Tabellini (cited as Tabellini, 2009, in Table A.1 of the paper; published as Tabellini, 2010). | Redistributed with attribution; please cite the original sources |
| `rai_tv_fee/` | `matched_annuari_rai_canone_allvars_code.dta`, number of TV licences and households by municipality, 1955-2015, from the RAI yearbooks (*Annuari RAI*), matched to ISTAT 2011 municipal codes | Constructed by the authors. The digitisation and matching code and the raw yearbook data are in the replication package of Calamunci, F.M. and Frattini, F.F. (2026), "Eroding civic capital: how persistent organized crime diminishes tax compliance", *Journal of Law, Economics, and Organization*, ewaf022: https://github.com/FedFabFrat/Replication-Files-of-Eroding-Civic-Capital-How-Persistent-Organised-Crime-Diminishes-Tax-Compliance- | Free to use with citation |
| `shapefiles/` | `Com2011_WGS84`, `Prov2011_WGS84`, `Reg2011_WGS84`, ISTAT 2011 boundaries of municipalities, provinces and regions | ISTAT, "Confini delle unità amministrative a fini statistici", https://www.istat.it/notizia/confini-delle-unita-amministrative-a-fini-statistici-al-1-gennaio-2018-2/ (2011 census version, generalised, WGS84) | ISTAT open data, CC BY 4.0 |

`data/derived/` is empty in the shared version; all its files are created by the code.

## Computational requirements

### Software
- **Stata** 18 or later. The package was verified with StataNow/MP 19.5; each do-file declares `version 18`. User-written packages are installed by `master.do` from SSC if missing. The package was verified from an empty ado folder with the versions served by SSC in October 2026, and also with an earlier set of versions; both give identical tables:

  | Package | Verified versions | Used for |
  |---|---|---|
  | reghdfe | 6.13.1 (10jan2026); 6.12.5 (27dec2023) | regressions (Tables 1-2, Figs 1-2) |
  | ftools | 2.50.0 (09jan2026); 2.49.1 (08aug2023) | required by reghdfe |
  | require | 1.3.1 (19sep2023) | required by reghdfe 6.13 and later |
  | estout: esttab, estpost | 3.34: 2.1.4, 1.2.2; 3.31: 2.1.1, 1.2.2 | LaTeX tables |
  | binscatter | 7.02 (24nov2013) | Figs 1-2 |
  | mipolate | 1.2.0 (2sep2015) | census controls (01_controls_istat.do) |
  | carryforward | 4.5 (15jan2016) | census controls (01_controls_istat.do) |

- **R** 4.4 (verified with R 4.4.2) with packages `sf` (1.0.19), `dplyr` (1.1.4), `haven` (2.5.4), `ggpubr` (0.6.1) and **`ggplot2` 3.5.2**. With ggplot2 4.x the maps contain the same data but render differently (thicker region borders, white panel background). To reproduce the published maps exactly, install ggplot2 3.5.2, e.g. `install.packages("https://cran.r-project.org/src/contrib/Archive/ggplot2/ggplot2_3.5.2.tar.gz", repos = NULL, type = "source")`.

### Hardware and runtime
Verified on Windows 11 Pro, Intel Core Ultra 9 185H, 32 GB RAM. A full run of `master.do` takes about 20 minutes, most of it spent in `01_controls_istat.do` (interpolation of the census controls). The raw data take 237 MB; the derived data about 176 MB.

## Instructions

1. Download or clone the repository (or unzip the package) anywhere.
2. Open `master.do` and set `global root` (line 26) to the folder that contains `master.do`, using forward slashes.
3. Set `global Rscript` to the path of `Rscript` on your machine, or set `global run_R 0` to skip the maps and run `code/figure_3.R`, `code/figure_A1.R` and `code/figure_A2.R` by hand afterwards. When run by hand, each R script takes the package root as its first argument, or you can edit the `root <-` line at its top.
4. Run `master.do` (in batch mode: `stata-mp -b do master.do`).

Tables are written to `output/tables/`, figures to `output/figures/` and logs to `output/logs/` (`master.log` for Stata and one log per R script). `master.do` stops with an error if a map is not produced. On Windows, a command window opens briefly while each R script runs; it closes by itself, so do not close it manually. The repository already contains the tables and figures produced by a full run, for comparison.

## Code

| File | Content |
|---|---|
| `master.do` | Sets the root path, checks/installs packages, runs everything |
| `code/01_controls_istat.do` | ISTAT census controls 1951-2011 → `controls_5111.dta` |
| `code/02_referendum_turnout.do` | Referendum turnout 1946-2020 → `turnout_referendum_wide_yearly_updt.dta` |
| `code/03_european_turnout.do` | European elections turnout 1979-2014 → `turnout_europee_wide_updt.dta` |
| `code/04_voluntary_associations.do` | Voluntary associations 1981-2001 → `n_voluntary_associations_wide_updt.dta` |
| `code/05_merge.do` | Merges all sources → `tv_tax_social_capital.dta` (municipality × decade) and the map datasets `maps_*.dta` |
| `code/06_analysis_setup.do` | Loads the analysis dataset, sets controls and labels (called by each exhibit file) |
| `code/table_*.do`, `code/figure_*.do` | One file per exhibit (see below) |
| `code/figure_*.R` | Maps |
| `code/original_upstream/` | The authors' earlier builder of the voluntary-associations file, kept for reference (not run; personal folder paths replaced by `C:\path\to\`) |

## List of tables and figures

| Exhibit | Program | Output file |
|---|---|---|
| Table 1 | `code/table_1.do` | `output/tables/table_1.tex` |
| Table 2 | `code/table_2.do` | `output/tables/table_2.tex` |
| Table A.1 | — (description of variables; text only, no code) | — |
| Table A.2 | `code/table_A2.do` | `output/tables/table_A2.tex` |
| Figure 1 (a), (b), (c) | `code/figure_1.do` | `output/figures/figure_1a.png`, `figure_1b.png`, `figure_1c.png` |
| Figure 2 (a), (b), (c), (d) | `code/figure_2.do` | `output/figures/figure_2a.png` ... `figure_2d.png` |
| Figure 3 | `code/figure_3.R` | `output/figures/figure_3.png` |
| Figure 4 | `code/figure_4.do` | `output/figures/figure_4.png` |
| Figure A.1 (a), (b), (c) | `code/figure_A1.R` | `output/figures/figure_A1a.png` ... `figure_A1c.png` |
| Figure A.2 (a), (b), (c), (d) | `code/figure_A2.R` | `output/figures/figure_A2a.png` ... `figure_A2d.png` |

## Notes on data construction

These notes describe what the code does, for readers comparing the code with the paper.

1. **Units and identifiers.** The unit of analysis is the municipality, identified by its ISTAT 2011 code, observed by decade (1950s to 2010s).
   - The census controls and the TV-licence data refer to each municipality's territory at the time of each census or yearbook ("confini dell'epoca"), linked to 2011 codes. Territory is not harmonised to constant boundaries.
   - Municipalities observed in at least six of the seven censuses are kept, and a missing census year is filled by interpolation or, at the ends of the period, extrapolation (`mipolate`).
   - The referendum and European election data are merged on the municipality name, harmonised to 2011 names. Homonymous municipalities are distinguished by province.

2. **Decades.** A year of data stands for its decade:

   | Variable | 1950s | 1960s | 1970s | 1980s | 1990s | 2000s | 2010s |
   |---|---|---|---|---|---|---|---|
   | TV fee compliance | 1955 | mean of 1961, 1965 | mean of 1971, 1975 | mean of 1981, 1985 | mean of 1991, 1995 | mean of 2001, 2005 | mean of 2011, 2015 |
   | Referendum turnout | 1946 | – | mean of 1974, 1978 | 1981 | – | mean of 2009, 2011 | mean of 2016, 2020 |
   | European elections turnout | – | – | 1979 | mean of 1984, 1989 | mean of 1994, 1999 | mean of 2004, 2009 | 2014 |
   | Voluntary associations | – | – | – | 1981 | 1991 | 2001 | – |
   | Census controls | 1951 | 1961 | 1971 | 1981 | 1991 | 2001 | 2011 |

   When several referendum questions were voted in the same year, turnout is their average.

3. **Variable definitions.**
   - **TV fee compliance:** number of TV licences per 100 households in the municipality (`d100f_tv_`).
   - **Turnout:** voters divided by eligible voters, in percent.
   - **Voluntary associations:** voluntary associations per 1,000 inhabitants (the source variable, per 100 inhabitants, multiplied by 10).
   - **CONI:** Table 2 column 2 and Figure 2(b) use the number of people registered with CONI per 1,000 inhabitants in 1999 (`coni_registered`). Table A.2 and Figure A.2(b) report the number of CONI associations per 1,000 inhabitants in 1999 (`coni_assoc`).

4. **Cleaning and missing values.**
   - TV fee compliance values above 100 (and negative values in the 1980s) and European turnout values above 100% are set to missing.
   - Missing municipality values of TV fee compliance, of the outcomes and of the census controls are then replaced with the median of the municipality's province for the same decade (`05_merge.do`). Where the whole province is missing, the value stays missing; this concerns mainly 1955 TV data in the South.

5. **Provincial analysis (Table 2, Figure 2).**
   - TV fee compliance and population are averaged, without weights, over the municipalities and decades of each 2011 province. The population control is therefore the mean municipal population.
   - The provincial outcomes come from `SOCIAL_CAPITAL.dta`, defined on the 103 provinces before 2004 and merged on municipal codes. Provinces created after 2001 (Barletta-Andria-Trani, Carbonia-Iglesias, Fermo, Medio Campidano, Monza e Brianza, Ogliastra, Olbia-Tempio) have no matched outcome and do not enter the provincial regressions.
   - Trust is available for the 2000s only. Column 4 aggregates by province and decade, so it relates trust to TV fee compliance in the 2000s.

6. **Estimation and figures.**
   - Table 1 includes municipality and decade fixed effects, with standard errors clustered by municipality.
   - Table 2 has one observation per province, with heteroskedasticity-robust standard errors (`vce(cluster prov)`).
   - Figures 1 and 2 are binned scatter plots (`binscatter`) of the outcome against TV fee compliance after partialling out the controls (and fixed effects in Figure 1). The caption coefficient is the corresponding regression coefficient.
   - Table A.2 summarises all municipality-decade observations of the analysis dataset.

## Licence

The code and the data constructed by the authors are released under the Creative Commons Attribution 4.0 International licence (CC BY 4.0); see `LICENSE`. Third-party data in `data/raw/` remain subject to the terms of their original providers, listed in the data availability statement above; please cite the original sources.

Suggested citation: Calamunci, F.M. and Frattini, F.F. (2026). Replication package for "The civic side of tax compliance: Evidence from Italy", *Economics Letters* 252, 112346. https://github.com/FedFabFrat/Replication-Files-of-The-Civic-Side-of-Tax-Compliance-Evidence-from-Italy

## References
- Calamunci, F.M. and Frattini, F.F. (2026). Eroding civic capital: how persistent organized crime diminishes tax compliance. *Journal of Law, Economics, and Organization*, ewaf022.
- Cartocci, R. (2007). *Mappe del tesoro: atlante del capitale sociale in Italia*. Il Mulino.
- Durante, R., Pinotti, P. and Tesei, A. (2019). The political legacy of entertainment TV. *American Economic Review* 109(7), 2497-2530.
- Guiso, L., Sapienza, P. and Zingales, L. (2004). The role of social capital in financial development. *American Economic Review* 94(3), 526-556.
- Nannicini, T., Stella, A., Tabellini, G. and Troiano, U. (2013). Social capital and political accountability. *American Economic Journal: Economic Policy* 5(2), 222-250.
- Tabellini, G. (2010). Culture and institutions: economic development in the regions of Europe. *Journal of the European Economic Association* 8(4), 677-716.
