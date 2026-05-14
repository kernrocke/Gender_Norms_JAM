
** DO-FILE SET UP COMMANDS
version 13
clear
capture log close
macro drop _all
set more 1
set linesize 150
cls
set seed 6893209

**  GENERAL DO-FILE COMMENTS
**  Program:		002_adol_intervention.do
**  Project:      	Adolescent Intervention Study
**  Analyst:        Kern Rocke 
**	Date Created:	19/10/2023
**	Date Created:	19/10/2023
**  Algorithm Task: 1) Selection of primary and secondary schools and 
**					2) intervention assignment for secondary schools
					

*Set working directories (Set you working directory to match your OS)
local datapath "/Users/kernrocke/Downloads/2024"

*-----------------------------BEGIN---------------------------------------------

*Primary schools

*Load school level data for selection
import excel "`datapath'/Public schools_KSA_coed_only.xlsx", sheet("Contact") cellrange(A4:Q131) firstrow clear

*Minor data cleaning
rename F SchoolType_cat
rename G Locale
drop if Sector != "P"
encode SchoolType, gen(School)
replace Locale = lower(Locale)

*Remove Non-primary schools 
drop if School == 3 | School == 4 | School == 5

*Random selection of 12 schools stratified by rural/urban - Note: 2 additional added for selection in the event of school refusal
sample 6, count by(Locale)

*Checking location distribution
tab Locale

*Listing selected schools
list SchoolName School SchoolType_cat Locale Parish



*-------------------------------------------------------------------------------

*Secondary schools
*Load school level data for selection
import excel "`datapath'/Public schools_KSA_coed_only.xlsx", sheet("Contact") cellrange(A4:Q131) firstrow clear

*Minor data cleaning
rename F SchoolType_cat
rename G Locale
encode SchoolType_cat, gen (SchoolType_cat1)
drop SchoolType_cat
rename SchoolType_cat1 SchoolType_cat
drop if Sector != "P"
encode SchoolType, gen(School)
replace Locale = lower(Locale)

*Remove Non-secondary schools 
drop if School == 1 | School == 2 | School == 3
keep if SchoolType_cat == 1 | SchoolType_cat == 5 

*Random removal of 1 rural school due to total number being 3, we only need 2
gen random_rural = uniform() if Locale == "rural"
egen order_rural = rank(random_rural)
drop if order_rural == 1
drop random_rural order_rural

*Random selection of 10 schools stratified by rural/urban - Note: 2 additional added for selection in the event of school refusal
sample 8 , by(Locale) count

*Creating random group assignments for intervention and control
bysort Locale: gen random = uniform()
egen order = rank(random)
gen group = .
replace group = 1 if order>=6
replace group = 0 if order<6

*Minor cleaning
label var group "Assignment"
label define group 0"Control" 1"Intervention"
label value group group

*Checking location distribution
tab Locale

*Listing selected schools
list SchoolName School SchoolType_cat Locale group


*-----------------------------END-----------------------------------------------
