** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          GNorms_JAM_001.do
    //  project:                Gender Norms among Adolescents in Jamaica
    //  analysts:               Kern ROCKE
    //  date first created      17-OCT-2024
    // 	date last modified      17-OCT-2024
    //  algorithm task          Cleaning variables from SPSS
    //  status                  In Progress


    ** General algorithm set-up
    version 17.0
    clear all
    macro drop _all
    set more off

    ** Initialising the STATA log and allow automatic page scrolling
    capture {
            program drop _all
    	drop _all
    	log close
    	}



*Set working directory
local datapath "/Users/kernrocke/Library/Mobile Documents/com~apple~CloudDocs/Github"

*Load dataset for inital cleaning
import spss "`datapath'/Gender_Norms_JAM/Dataset/GEAS-Jamaica-Phase2baseline-child-2022-10-19_WIDE.sav" , clear

*Get general description of database size and structure
describe, short

*Begin inital cleaning
rename IA1age age

rename IA2gender gender
label define gender 0"Male" 1"Female", modify
label value gender gender

rename IA5_wi ethncity

rename IA6religion_wi_1 religion_christian 
rename IA6religion_wi_2 religion_hindu
rename IA6religion_wi_3 religion_islam
rename IA6religion_wi_4 religion_judaism
rename IA6religion_wi_5 religion_rasta
rename IA6religion_wi_997 religion_other
rename IA6religion_wi_0 relgion_none
rename IA6religion_wi_996 religion_refuse

rename IA7 religion_impt
rename IA8 religion_freq

rename IIA1 caregiver
rename IIA1b caregiver_gender













