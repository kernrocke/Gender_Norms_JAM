cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          GNorms_JAM_001.do
    //  project:                Gender Norms among Adolescents in Jamaica
    //  analysts:               Kern ROCKE
    //  date first created      17-OCT-2024
    // 	date last modified      12-MAY-2026
    //  algorithm task          Cleaning and analysis for preliminary presenttation
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
*import spss "`datapath'/Gender_Norms_JAM/Dataset/GEAS-Jamaica-Phase2baseline-child-2022-10-19_WIDE.sav" , clear
use "`datapath'/Gender_Norms_JAM/Dataset/GEAS-Jamaica-Phase2Baseline_IDCleaned.dta", clear

*Get general description of database size and structure
describe, short

*Begin inital cleaning

** School
gen school_type = .

* --- Primary (1.1 Primary) ---
replace school_type = 1 if inlist(schid, 1, 3, 4, 5, 6, 7, 8, 9, 23, 27, 29)
// schid 1  = Clifton Primary
// schid 3  = Essex Hall Primary
// schid 4  = Franklin Town Primary
// schid 5  = Jones Town Primary
// schid 6  = Louise Bennett Coverley Primary
// schid 7  = St. Benedict's Primary
// schid 8  = St. Michael's Primary
// schid 9  = St. Patrick's Primary
// schid 23 = Jessie Ripoll Primary
// schid 27 = Edward Seaga Primary
// schid 29 = St. Aloysius Primary

* --- Primary and Infant (1.2 Primary and Infant) ---
replace school_type = 2 if inlist(schid, 2, 10, 11, 12, 30)
// schid 2  = Dallas Primary and Infant
// schid 10 = St. George's Girls Primary and Infant
// schid 11 = Stony Hill Primary and Infant
// schid 12 = Whitfield Primary and Infant
// schid 30 = Mountain View Primary and Infant

* --- Cavaliers Primary (schid not in ID list — confirm if added) ---
* replace school_type = 1 if schid == XX   // Cavaliers Primary = 1.1 Primary

* --- Non-traditional High (2.3 Secondary High) ---
replace school_type = 3 if inlist(schid, 14, 15, 16, 17, 18, 19, 20, 21, 22, 25, 28)
// schid 14 = Gaynstead High
// schid 15 = Haile Selassie High
// schid 16 = Kingston High
// schid 17 = Norman Manley High
// schid 18 = Oberlin High
// schid 19 = Papine High
// schid 20 = Tarrant High
// schid 21 = Vauxhall High
// schid 22 = Penwood High
// schid 25 = Mavis Bank High
// schid 28 = Pembroke Hall High

* --- Traditional High (2.3 Secondary High) ---
replace school_type = 4 if inlist(schid, 13, 24, 31)
// schid 13 = Excelsior High
// schid 24 = Ardenne High
// schid 31 = Meadowbrook High

* Note: schid 33 (Eve for Life) is a community org, not a standard
* school type in the KSA census — left as missing (.) pending clarification.

label define school_type_lbl  ///
    1 "Primary"               ///
    2 "Primary and Infant"    ///
    3 "Non-traditional High"  ///
    4 "Traditional High"
label values school_type school_type_lbl
label variable school_type "School type (KSA classification)"

* Verification
tab school_type, miss

gen treat = . 
replace treat = 1 if schid==13 | schid==15 | schid==16 | schid==17 | schid==19 
replace treat = 0 if schid==14 | schid==18 | schid==20 | schid==21

label var treat "Treatment Status"
label define treat 0"Control" 1"Intervention"
label value treat treat

gen locale = . 
replace locale = 1 if schid==1
replace locale = 1 if schid==2
replace locale = 1 if schid==3
replace locale = 2 if schid==4
replace locale = 2 if schid==5
replace locale = 1 if schid==6
replace locale = 1 if schid==7
replace locale = 2 if schid==8
replace locale = 2 if schid==9
replace locale = 2 if schid==10
replace locale = 1 if schid==11
replace locale = 2 if schid==12
replace locale = 2 if schid==13
replace locale = 2 if schid==14
replace locale = 2 if schid==15
replace locale = 2 if schid==16
replace locale = 2 if schid==17
replace locale = 1 if schid==18
replace locale = 1 if schid==19
replace locale = 2 if schid==20
replace locale = 2 if schid==21

replace locale = 2 if schid==22
replace locale = 2 if schid==23
replace locale = 2 if schid==24
replace locale = 1 if schid==25
replace locale = 2 if schid==26
replace locale = 2 if schid==27
replace locale = 2 if schid==28
replace locale = 2 if schid==29
replace locale = 2 if schid==30
replace locale = 2 if schid==31
replace locale = 2 if schid==32
replace locale = 2 if schid==33

label var locale "Locale"
label define locale 1"Rurual" 2"Urban"
label value locale locale

rename ia1age age
gen age_grp = .
replace age_grp = 1 if age == 10
replace age_grp = 1 if age == 11
replace age_grp = 2 if age == 12
replace age_grp = 2 if age == 13
replace age_grp = 2 if age == 14

label define age_grp 1"<12" 2">=12"
label values age_grp age_grp

tab age_grp


rename ia2gender gender
label define gender 0"Male" 1"Female", modify
label value gender gender

rename ia5_wi ethncity

rename ia6religion_wi_1 religion_christian 
rename ia6religion_wi_2 religion_hindu
rename ia6religion_wi_3 religion_islam
rename ia6religion_wi_4 religion_judaism
rename ia6religion_wi_5 religion_rasta
rename ia6religion_wi_997 religion_other
rename ia6religion_wi_0 relgion_none
rename ia6religion_wi_996 religion_refuse

label var religion_christian "Christian" 
label var religion_hindu "Hindu"
label var religion_islam "Islam"
label var religion_judaism "Judaism"
label var religion_rasta "rastafarianism"
label var religion_other "Other"
label var relgion_none "No Religion"

rename ia7 religion_impt
rename ia8 religion_freq

rename iia1 caregiver
rename iia1b caregiver_gender

*-------------------------------------------------------------------------------

*PHQ-9 - Depression 
foreach x of varlist phq9_1 phq9_2 phq9_3 phq9_4 phq9_5 phq9_6 phq9_7 phq9_8 phq9_9 {
	
	replace `x' = . if `x' == 996
}

egen Depression_score = rowtotal(phq9_1 phq9_2 phq9_3 phq9_4 phq9_5 phq9_6 phq9_7 phq9_8 phq9_9)
sum Depression_score

label var Depression_score "PHQ-9 Depression score"

alpha phq9_1 phq9_2 phq9_3 phq9_4 phq9_5 phq9_6 phq9_7 phq9_8 phq9_9

*Depression categories
gen dep_cat = . 
replace dep_cat = 0 if Depression_score>=0 & Depression_score<=4
replace dep_cat = 1 if Depression_score>=5 & Depression_score<=9
replace dep_cat = 2 if Depression_score>=10 & Depression_score<=14
replace dep_cat = 3 if Depression_score>=15 & Depression_score<=19
replace dep_cat = 4 if Depression_score>=20 & Depression_score!=.

label var dep_cat "Depression Severity Categories"
label define dep_cat 0"Minimal or none" 1"Mild" 2"Moderate" 3"Moderatly severe" 4"Severe"
label value dep_cat dep_cat

*-------------------------------------------------------------------------------

*Sexual Double Standard
foreach x of varlist gn10 gn11 gn12 gn13 gn16 gn18 {
	
	replace `x' = . if `x' == 996
}

egen SDS_score = rowmean(gn10 gn11 gn12 gn13 gn16 gn18)
sum SDS_score

label var SDS_score "Sexual Double Standard Score"

alpha gn10 gn11 gn12 gn13 gn16 gn18

*Normative Views around Romantic Relationships
foreach x of varlist gn4 gn6 gn9 gn17 {
	
	replace `x' = . if `x' == 996
}

egen NVRR_score = rowmean(gn4 gn6 gn9 gn17)
sum NVRR_score

label var NVRR_score "Normative Views around Romantic Relationships Score"

*Gender Sterotypical Traits
foreach x of varlist gn19 gn20 gn21 gn22 gn23 gn25 gn27 {
	
	replace `x' = . if `x' == 996
}

egen GST_score = rowmean(gn19 gn20 gn21 gn22 gn23 gn25 gn27)
sum GST_score

label var GST_score "Gender Sterotypical Traits Score"

*Gender Sterotypical Roles
foreach x of varlist gn39 gn40 gn41 gn44 {
	
	replace `x' = . if `x' == 996
}

egen GSR_score = rowmean(gn39 gn40 gn41 gn44)
sum GSR_score

label var GSR_score "Gender Sterotypical Roles Score"

*----------------

*Depressive Symptoms
foreach x of varlist ixa1a ixa1b ixa1c ixa1d ixa1e ixa1f{
	
	replace `x' = . if `x' == 996
	replace `x' = 0 if `x' == 1
	replace `x' = 1 if `x' == 2
	replace `x' = 2 if `x' == 3
	replace `x' = 3 if `x' == 4
	replace `x' = 4 if `x' == 5
	
	label define `x' 0"Disagree alot" 1"Disagree a little" 2"Neither agree or disagree" 3"Agree a little" 4"Agree alot", modify
	label value `x' `x'
	
}

vreverse ixa1a, gen(ixa1a_new)

egen depress_symp = rowtotal(ixa1a_new ixa1b ixa1c ixa1d ixa1e ixa1f)
sum depress_symp

label var depress_symp "Depressive Symptoms Score"

*----------------

*Body satisfaction

foreach x of varlist viiid1a viiid1b viiid1c viiid1f viiid1g {
	
	replace `x' = . if `x' == 996
}

egen body_satis_score = rowmean(viiid1a viiid1b viiid1c viiid1f viiid1g)
sum body_satis_score

label var body_satis_score "Body Satisfaction Score"

*----------------

*Adverse Childhood Experiences

foreach x of varlist ixb1a ixb1b ixb1c ixb1d ixb1e ixb1f ixb1g ixb1h ixb1h_wi ixb1i ixb1j ixb1k ixb1l ixb1m {
	
	replace `x' = . if `x' == 999
	replace `x' = . if `x' == 996
	
	replace `x' = 0 if `x' == 1
	replace `x' = 1 if `x' == 2
	replace `x' = 1 if `x' == 3
	
}

egen ACE_score = rowtotal(ixb1a ixb1b ixb1c ixb1d ixb1e ixb1f ixb1g ixb1h ixb1h_wi ixb1i ixb1j ixb1k ixb1l ixb1m)
sum ACE_score

label var ACE_score "Adverse Childhood Experiences Score"
*----------------
* Community Safety & Social Cohesion

foreach x of varlist va1a va1b va1c va1d  va2a va2b va2c va2d {
	replace `x' = . if `x' == 999
	replace `x' = . if `x' == 996
	
}

egen community_safe = rowmean(va1a va1b va1c va1d)
egen social_cohesion = rowmean(va2a va2b va2c va2d)

sum community_safe social_cohesion

label var community_safe "Community Safety Score"
label var social_cohesion "Social Cohesion Score"

*-------------------
* parental comfort & parental monitoring and awareness

foreach x of varlist iib2a iib2b iib2c iic1a iic1b iic1c {
	replace `x' = . if `x' == 999
	replace `x' = . if `x' == 996
	
}

egen parent_comfort = rowmean(iib2a iib2b iib2c)
egen parent_monawe = rowmean(iic1a iic1b iic1c)	

sum parent_comfort parent_monawe

label var parent_comfort "Parent Comfort Score"
label var parent_monawe "Parent Monitoring and Awareness Score"

*-------------------
* Sexual Harrassment

foreach x of varlist shs_1 shs_2 shs_3 shs_4 shs_5 shs_6 shs_7 shs_8 shs_9 shs_10 shs_11 shs_12 shs_13 shs_14 shs_15 shs_16 {
	
	replace `x' = . if `x' == 999
	replace `x' = . if `x' == 996
	
	replace `x' = 0 if `x' == 1
	replace `x' = 0 if `x' == 2
	replace `x' = 1 if `x' == 3
	replace `x' = 1 if `x' == 4
	
	label define `x' 0"No/Rare" 1"Yes", modify
	label value `x' `x'
}
mrgraph hbar shs_1 - shs_4, by(gender) response(1) width(50) title("Sexual Harrassment") ylabel(,angle(0)) percent stat(column) ytitle("Percentage (%)", color(black)) name(gs1, replace) xsize(10) ylabel(0(10)80,angle(0)) percent plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white) bar(1, fcolor("44 127 184")) bar(2, fcolor("189 0 38")) ylab(, nogrid) blabel(bar, format(%9.1f)) 

mrgraph hbar shs_5 - shs_8, by(gender) response(1) width(50) title("Sexual Harrassment") ylabel(,angle(0)) percent stat(column) ytitle("Percentage (%)", color(black)) name(gs2, replace) xsize(10) ylabel(0(10)80,angle(0)) percent plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white) bar(1, fcolor("44 127 184")) bar(2, fcolor("189 0 38")) ylab(, nogrid) blabel(bar, format(%9.1f)) 

mrgraph hbar shs_9 - shs_12, by(gender) response(1) width(50) title("Sexual Harrassment") ylabel(,angle(0)) percent stat(column) ytitle("Percentage (%)", color(black)) name(gs3, replace) xsize(10) ylabel(0(10)80,angle(0)) percent plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white) bar(1, fcolor("44 127 184")) bar(2, fcolor("189 0 38")) ylab(, nogrid) blabel(bar, format(%9.1f)) 

mrgraph hbar shs_13 - shs_16, by(gender) response(1) width(50) title("Sexual Harrassment") ylabel(,angle(0)) percent stat(column) ytitle("Percentage (%)", color(black)) name(gs4, replace) xsize(10) ylabel(0(10)80,angle(0)) percent plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white) bar(1, fcolor("44 127 184")) bar(2, fcolor("189 0 38")) ylab(, nogrid) blabel(bar, format(%9.1f)) 


egen sex_harrass = rowtotal(shs_1 shs_2 shs_3 shs_4 shs_5 shs_6 shs_7 shs_8 shs_9 shs_10 shs_11 shs_12 shs_13 shs_14 shs_15 shs_16)
sum sex_harrass

label var sex_harrass "Sexual Harrassment Score"
*-------------------
* Freedom of Movement

foreach x of varlist xia1a xia1b xia1c xia1d xia1f {
	replace `x' = . if `x' == 999
	replace `x' = . if `x' == 996
	
}

egen freedom_move = rowmean(xia1a xia1b xia1c xia1d xia1f)
sum freedom_move

label var freedom_move "Freedom of Movement Score"
*-------------------
* Voice

foreach x of varlist xib1a xib1b xib1c xib1d xib1e xib1f xib1g {
	replace `x' = . if `x' == 999
	replace `x' = . if `x' == 996
	
}

egen voice = rowmean(xib1a xib1b xib1c xib1d xib1e xib1f xib1g)
sum voice

label var voice "Voice Score"

*-------------------
* Behavioral control and Decision Making

foreach x of varlist xic1a xic1b xic1c xic1d xic1e {
	replace `x' = . if `x' == 999
	replace `x' = . if `x' == 996
	
}

egen behav_control = rowmean(xic1a xic1b xic1c xic1d xic1e)
sum behav_control 

label var behav_control "Behavioral Control and Decision Making Score"


*-------------------

tabstat SDS_score NVRR_score GST_score GSR_score depress_symp body_satis_score ACE_score community_safe social_cohesion parent_comfort parent_monawe sex_harrass freedom_move voice behav_control, by(age_grp) stat(n mean sem) format(%9.2f)


foreach x of varlist SDS_score NVRR_score GST_score GSR_score depress_symp body_satis_score ACE_score community_safe social_cohesion parent_comfort parent_monawe sex_harrass freedom_move voice behav_control {

graph bar (mean) `x', over(age_grp) over(gender) blabel(bar, format(%9.1f)) ytitle("Mean Score") title("`x'", color(black)) ylab(, angle(horizontal) nogrid) plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white) name(`x', replace)

}

*Gender distribution
graph pie, over(gender) cw noclockwise plabel(_all percent, color(black) size(large) format(%9.0f)) plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white) title("Gender Distribution") name("Gender_dis", replace) pie(1, color("44 127 184")) pie(2, color("189 0 38"))

*Gender Age Distribution
graph bar, over(age_grp) over(gender) blabel(bar, format(%9.1f)) ytitle("Percentage (%)") title("Gender Age Distribution", color(black)) ylab(,angle(horizontal) nogrid) plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white)  bar(1, fcolor("49 163 84"))

*Religion
mrgraph hbar religion_christian-relgion_none, response(1) width(15) title("Religion Type") ylabel(,angle(0)) percent stat(column) ytitle("Percentage (%)", color(black)) plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white) bar(1, fcolor("49 163 84")) ylab(, nogrid) blabel(bar, format(%9.1f))


*Caregiver
graph hbar if caregiver !=996, over(caregiver) bar(1, fcolor(green)) blabel(bar, format(%9.1f)) ytitle("Percentage (%)") title("Caregiver Type", color(black)) ylab(,angle(horizontal) nogrid) plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white)  bar(1, fcolor("197 27 138"))


*Anxiety

foreach x of varlist gad7a gad7b gad7c gad7d gad7e gad7f gad7g {
	
	replace `x' = . if `x' == 999
	replace `x' = . if `x' == 996
}

egen anxiety_score = rowtotal(gad7a gad7b gad7c gad7d gad7e gad7f gad7g)


label var anxiety_score "Anxiety Score (GAD)"

gen anx_cat = .
replace anx_cat = 1 if anxiety_score<5
replace anx_cat = 2 if anxiety_score >=5 & anxiety_score <10
replace anx_cat = 3 if anxiety_score >=10 & anxiety_score <15
replace anx_cat = 4 if anxiety_score>=15 & anxiety_score !=.

label var anx_cat "Anxiety Categories"
label define anx_cat 1"Minimal Anxiety" 2"Mild Anxiety" 3"Moderate Anxiety" 4"Severe Anxiety"
label value anx_cat anx_cat

ttest anxiety_score, by(gender)
proportion anx_cat

mrgraph hbar shs_1 - shs_4, by(gender) response(1) width(50) title("Sexual Harrassment") ylabel(,angle(0)) percent stat(column) ytitle("Percentage (%)", color(black)) name(gs1, replace) xsize(10) ylabel(0(10)80,angle(0)) percent plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white) bar(1, fcolor("44 127 184")) bar(2, fcolor("189 0 38")) ylab(, nogrid) blabel(bar, format(%9.1f)) 

mrgraph hbar shs_5 - shs_8, by(gender) response(1) width(50) title("Sexual Harrassment") ylabel(,angle(0)) percent stat(column) ytitle("Percentage (%)", color(black)) name(gs2, replace) xsize(10) ylabel(0(10)80,angle(0)) percent plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white) bar(1, fcolor("44 127 184")) bar(2, fcolor("189 0 38")) ylab(, nogrid) blabel(bar, format(%9.1f)) 

mrgraph hbar shs_9 - shs_12, by(gender) response(1) width(50) title("Sexual Harrassment") ylabel(,angle(0)) percent stat(column) ytitle("Percentage (%)", color(black)) name(gs3, replace) xsize(10) ylabel(0(10)80,angle(0)) percent plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white) bar(1, fcolor("44 127 184")) bar(2, fcolor("189 0 38")) ylab(, nogrid) blabel(bar, format(%9.1f)) 

mrgraph hbar shs_13 - shs_16, by(gender) response(1) width(50) title("Sexual Harrassment") ylabel(,angle(0)) percent stat(column) ytitle("Percentage (%)", color(black)) name(gs4, replace) xsize(10) ylabel(0(10)80,angle(0)) percent plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) bgcolor(white) bar(1, fcolor("44 127 184")) bar(2, fcolor("189 0 38")) ylab(, nogrid) blabel(bar, format(%9.1f)) 


label var shs_1 "Having someone make unwelcome sexual comments, jokes, or gestures"

cls
preserve
foreach x of varlist gn10 gn11 gn12 gn13 gn16 gn18 {
	
	replace `x' = . if `x' == 996
	
	replace `x' = 0 if `x' == 1 | `x' == 2
	replace `x' = 2 if `x' == 4 | `x' == 5
	replace `x' = 1 if `x' == 3
	
}

mrtab gn10 gn11 gn12 gn13 gn16 gn18, nolabel response(0)
mrtab gn10 gn11 gn12 gn13 gn16 gn18, nolabel response(1)
mrtab gn10 gn11 gn12 gn13 gn16 gn18, nolabel response(2)

restore



preserve
foreach x of varlist gn4 gn6 gn9 gn17 {
	
	replace `x' = . if `x' == 996
	
	replace `x' = 0 if `x' == 1 | `x' == 2
	replace `x' = 2 if `x' == 4 | `x' == 5
	replace `x' = 1 if `x' == 3
	
}

mrtab gn4 gn6 gn9 gn17, nolabel response(0)
mrtab gn4 gn6 gn9 gn17, nolabel response(1)
mrtab gn4 gn6 gn9 gn17, nolabel response(2)

restore






preserve
foreach x of varlist gn19 gn20 gn21 gn22 gn23 gn25 gn27 {
	
	replace `x' = . if `x' == 996
	
	replace `x' = 0 if `x' == 1 | `x' == 2
	replace `x' = 2 if `x' == 4 | `x' == 5
	replace `x' = 1 if `x' == 3
	
}

mrtab gn19 gn20 gn21 gn22 gn23 gn25 gn27, nolabel response(0)
mrtab gn19 gn20 gn21 gn22 gn23 gn25 gn27, nolabel response(1)
mrtab gn19 gn20 gn21 gn22 gn23 gn25 gn27, nolabel response(2)

restore


preserve
foreach x of varlist gn39 gn40 gn41 gn44 {
	
	replace `x' = . if `x' == 996
	
	replace `x' = 0 if `x' == 1 | `x' == 2
	replace `x' = 2 if `x' == 4 | `x' == 5
	replace `x' = 1 if `x' == 3
	
}

mrtab gn39 gn40 gn41 gn44, nolabel response(0)
mrtab gn39 gn40 gn41 gn44, nolabel response(1)
mrtab gn39 gn40 gn41 gn44, nolabel response(2)

restore


cls
foreach x of varlist SDS_score NVRR_score GST_score GSR_score depress_symp body_satis_score ACE_score community_safe social_cohesion parent_comfort parent_monawe sex_harrass freedom_move voice behav_control {
	
	ttest `x', by(gender)
}
cls
preserve
foreach x of varlist ixa1a_new ixa1b ixa1c ixa1d ixa1e ixa1f {
	
	gen `x'_dep = .
	replace `x'_dep = 0 if `x'==0
	replace `x'_dep = 0 if `x'==1
	replace `x'_dep = 0 if `x'==2
	replace `x'_dep = 1 if `x'==3
	replace `x'_dep = 1 if `x'==4
	
	proportion `x'_dep, percent cformat(%9.1f)
	proportion `x'_dep, over(gender) percent cformat(%9.1f)
	
	ttest `x'_dep, by(gender)
}

restore

*Reliability Score
alpha gn10 gn11 gn12 gn13 gn16 gn18 // Sexual Double Standard
alpha gn4 gn6 gn9 gn17 // Normative Views around Romantic Relationships
alpha gn19 gn20 gn21 gn22 gn23 gn25 gn27 // Gender Sterotypical Traits
alpha gn39 gn40 gn41 gn44 // Gender Sterotypical Roles
alpha ixa1a_new ixa1b ixa1c ixa1d ixa1e ixa1f // Depressive Sympoms
alpha phq9_1 phq9_2 phq9_3 phq9_4 phq9_5 phq9_6 phq9_7 phq9_8 phq9_9 // PHQ-9 Depression
alpha viiid1a viiid1b viiid1c viiid1f viiid1g // Body Satisfaction
*-------
alpha ixb1a ixb1b ixb1c ixb1d ixb1e ixb1f ixb1g ixb1h ixb1h_wi ixb1i ixb1j ixb1k ixb1l ixb1m // Adverse Childhood Experiences
alpha va1a va1b va1c va1d // Community Safety
alpha va2a va2b va2c va2d // Social Cohesion
alpha iib2a iib2b iib2c // Parent Comfort
alpha iic1a iic1b iic1c // Parent Monitoring and Awareness
alpha shs_1 shs_2 shs_3 shs_4 shs_5 shs_6 shs_7 shs_8 shs_9 shs_10 shs_11 shs_12 shs_13 shs_14 shs_15 shs_16 // Sexual Harrassment
*-------
alpha xia1a xia1b xia1c xia1d xia1f // Freedom of Movement
alpha xib1a xib1b xib1c xib1d xib1e xib1f xib1g // Voice
alpha xic1a xic1b xic1c xic1d xic1e // Behavioral control and Decision Making
alpha gad7a gad7b gad7c gad7d gad7e gad7f gad7g // Anxiety

*Save Dataset	
save"`datapath'/Gender_Norms_JAM/Dataset/GEAS-Jamaica-Phase2baseline-child-2024-10-22_WIDE_prelim_clean.dta" , replace
exit
* Set output file
local outfile "_results.xlsx"

* Delete existing file so we start fresh
capture erase "`outfile'"


********************************************************************************
* Sexual Double Standard
********************************************************************************
preserve

foreach x of varlist gn10 gn11 gn12 gn13 gn16 gn18 {
	gen `x'_new = `x'
	recode `x'_new (2=1) (3=2) (4=3) (5=3)
	label define `x'_new 1 "Disagree" 2 "Neutral" 3 "Agree", replace
	label value `x'_new `x'_new
	tab `x'_new
}

local varlist gn10 gn11 gn12 gn13 gn16 gn18

tempname memhold
postfile `memhold' str30 characteristic str30 disagree str30 neutral str30 agree ///
	using "sds_results_temp", replace

foreach x of local varlist {
	quietly count if `x'_new == 1
	local n1 = r(N)
	quietly count if `x'_new == 2
	local n2 = r(N)
	quietly count if `x'_new == 3
	local n3 = r(N)
	quietly count if !missing(`x'_new)
	local ntot = r(N)

	local pct1 : display %5.2f (`n1'/`ntot')*100
	local pct2 : display %5.2f (`n2'/`ntot')*100
	local pct3 : display %5.2f (`n3'/`ntot')*100

	local dis = "`n1' (" + strtrim("`pct1'") + ")"
	local neu = "`n2' (" + strtrim("`pct2'") + ")"
	local agr = "`n3' (" + strtrim("`pct3'") + ")"

	post `memhold' ("`x'") ("`dis'") ("`neu'") ("`agr'")
}

postclose `memhold'
use "sds_results_temp", clear

* First sheet: replace to create the file
export excel using "`outfile'", replace firstrow(variables) sheet("Sexual_Double_Standard")

putexcel set "`outfile'", sheet("Sexual_Double_Standard") modify
putexcel A1 = "Characteristic"
putexcel B1 = "Disagree"
putexcel C1 = "Neutral"
putexcel D1 = "Agree"
putexcel A1:D1, bold
local nrows = _N
putexcel B1:D`=`nrows'+1', hcenter

restore
erase "sds_results_temp.dta"


********************************************************************************
* Normative Views around Romantic Relationships
********************************************************************************
preserve

foreach x of varlist gn4 gn6 gn9 gn17 {
	gen `x'_new = `x'
	recode `x'_new (2=1) (3=2) (4=3) (5=3)
	label define `x'_new 1 "Disagree" 2 "Neutral" 3 "Agree", replace
	label value `x'_new `x'_new
	tab `x'_new
}

local varlist gn4 gn6 gn9 gn17

tempname memhold
postfile `memhold' str30 characteristic str30 disagree str30 neutral str30 agree ///
	using "sds_results_temp", replace

foreach x of local varlist {
	quietly count if `x'_new == 1
	local n1 = r(N)
	quietly count if `x'_new == 2
	local n2 = r(N)
	quietly count if `x'_new == 3
	local n3 = r(N)
	quietly count if !missing(`x'_new)
	local ntot = r(N)

	local pct1 : display %5.2f (`n1'/`ntot')*100
	local pct2 : display %5.2f (`n2'/`ntot')*100
	local pct3 : display %5.2f (`n3'/`ntot')*100

	local dis = "`n1' (" + strtrim("`pct1'") + ")"
	local neu = "`n2' (" + strtrim("`pct2'") + ")"
	local agr = "`n3' (" + strtrim("`pct3'") + ")"

	post `memhold' ("`x'") ("`dis'") ("`neu'") ("`agr'")
}

postclose `memhold'
use "sds_results_temp", clear

* Subsequent sheets: modify to add to the existing file
export excel using "`outfile'", firstrow(variables) sheet("Normative_Views", replace)

putexcel set "`outfile'", sheet("Normative_Views") modify
putexcel A1 = "Characteristic"
putexcel B1 = "Disagree"
putexcel C1 = "Neutral"
putexcel D1 = "Agree"
putexcel A1:D1, bold
local nrows = _N
putexcel B1:D`=`nrows'+1', hcenter

restore
erase "sds_results_temp.dta"


********************************************************************************
* Gender Stereotypical Traits
********************************************************************************
preserve

foreach x of varlist gn19 gn20 gn21 gn22_wi gn23 gn25 gn27 {
	gen `x'_new = `x'
	recode `x'_new (2=1) (3=2) (4=3) (5=3)
	label define `x'_new 1 "Disagree" 2 "Neutral" 3 "Agree", replace
	label value `x'_new `x'_new
	tab `x'_new
}

local varlist gn19 gn20 gn21 gn22_wi gn23 gn25 gn27

tempname memhold
postfile `memhold' str30 characteristic str30 disagree str30 neutral str30 agree ///
	using "sds_results_temp", replace

foreach x of local varlist {
	quietly count if `x'_new == 1
	local n1 = r(N)
	quietly count if `x'_new == 2
	local n2 = r(N)
	quietly count if `x'_new == 3
	local n3 = r(N)
	quietly count if !missing(`x'_new)
	local ntot = r(N)

	local pct1 : display %5.2f (`n1'/`ntot')*100
	local pct2 : display %5.2f (`n2'/`ntot')*100
	local pct3 : display %5.2f (`n3'/`ntot')*100

	local dis = "`n1' (" + strtrim("`pct1'") + ")"
	local neu = "`n2' (" + strtrim("`pct2'") + ")"
	local agr = "`n3' (" + strtrim("`pct3'") + ")"

	post `memhold' ("`x'") ("`dis'") ("`neu'") ("`agr'")
}

postclose `memhold'
use "sds_results_temp", clear

export excel using "`outfile'", firstrow(variables) sheet("Gender_Stereotypical_Traits", replace)

putexcel set "`outfile'", sheet("Gender_Stereotypical_Traits") modify
putexcel A1 = "Characteristic"
putexcel B1 = "Disagree"
putexcel C1 = "Neutral"
putexcel D1 = "Agree"
putexcel A1:D1, bold
local nrows = _N
putexcel B1:D`=`nrows'+1', hcenter

restore
erase "sds_results_temp.dta"


********************************************************************************
* Gender Stereotypical Roles
********************************************************************************
preserve

foreach x of varlist gn39 gn40 gn41 gn44 {
	gen `x'_new = `x'
	recode `x'_new (2=1) (3=2) (4=3) (5=3)
	label define `x'_new 1 "Disagree" 2 "Neutral" 3 "Agree", replace
	label value `x'_new `x'_new
	tab `x'_new
}

local varlist gn39 gn40 gn41 gn44

tempname memhold
postfile `memhold' str30 characteristic str30 disagree str30 neutral str30 agree ///
	using "sds_results_temp", replace

foreach x of local varlist {
	quietly count if `x'_new == 1
	local n1 = r(N)
	quietly count if `x'_new == 2
	local n2 = r(N)
	quietly count if `x'_new == 3
	local n3 = r(N)
	quietly count if !missing(`x'_new)
	local ntot = r(N)

	local pct1 : display %5.2f (`n1'/`ntot')*100
	local pct2 : display %5.2f (`n2'/`ntot')*100
	local pct3 : display %5.2f (`n3'/`ntot')*100

	local dis = "`n1' (" + strtrim("`pct1'") + ")"
	local neu = "`n2' (" + strtrim("`pct2'") + ")"
	local agr = "`n3' (" + strtrim("`pct3'") + ")"

	post `memhold' ("`x'") ("`dis'") ("`neu'") ("`agr'")
}

postclose `memhold'
use "sds_results_temp", clear

export excel using "`outfile'", firstrow(variables) sheet("Gender_Stereotypical_Roles", replace)

putexcel set "`outfile'", sheet("Gender_Stereotypical_Roles") modify
putexcel A1 = "Characteristic"
putexcel B1 = "Disagree"
putexcel C1 = "Neutral"
putexcel D1 = "Agree"
putexcel A1:D1, bold
local nrows = _N
putexcel B1:D`=`nrows'+1', hcenter

restore
erase "sds_results_temp.dta"


ttest SDS_score, by(gender)
ttest NVRR_score, by(gender)
ttest GST_score, by(gender)
ttest GSR_score, by(gender)

*------------------------------------------------------

foreach x of varlist SDS_score NVRR_score GST_score GSR_score depress_symp body_satis_score ACE_score community_safe social_cohesion parent_comfort parent_monawe sex_harrass freedom_move voice behav_control anxiety_score {
	
	ttest `x', by(locale)
	
}




* Create a temporary dataset to store results
tempfile results
preserve
clear
set obs 0
gen variable = ""
gen total = ""
gen rural = ""
gen urban = ""
save `results', replace
restore

* Loop through each variable
foreach x of varlist SDS_score NVRR_score GST_score GSR_score depress_symp body_satis_score ACE_score community_safe social_cohesion parent_comfort parent_monawe sex_harrass freedom_move voice behav_control anxiety_score {
    
    * Run ttest - stores all group stats including combined
    quietly ttest `x', by(locale)
    
    * Group 1 = Rural, Group 2 = Urban, combined from ttest scalars
    local rural_mean = string(round(r(mu_1),  0.1), "%9.1f")
    local rural_sd   = string(round(r(sd_1),  0.1), "%9.1f")
    local urban_mean = string(round(r(mu_2),  0.1), "%9.1f")
    local urban_sd   = string(round(r(sd_2),  0.1), "%9.1f")
    
    * Combined (total) mean and SD come from ttest r(mu_1), r(mu_2) and N weighted
    * r(mu_1) and r(mu_2) are group means; combined mean is stored in r(mu_1) weighted
    * Use the combined row directly: mean from r(mu_1)*r(N_1) + r(mu_2)*r(N_2) / (r(N_1)+r(N_2))
    local n1 = r(N_1)
    local n2 = r(N_2)
    local mu1 = r(mu_1)
    local mu2 = r(mu_2)
    local sd1 = r(sd_1)
    local sd2 = r(sd_2)
    
    * Weighted combined mean
    local combined_mean = (`n1' * `mu1' + `n2' * `mu2') / (`n1' + `n2')
    
    * Pooled combined SD (using the combined formula)
    local combined_sd = sqrt((`n1' * (`sd1'^2 + (`mu1' - `combined_mean')^2) + ///
                              `n2' * (`sd2'^2 + (`mu2' - `combined_mean')^2)) / ///
                             (`n1' + `n2'))
    
    local total_mean = string(round(`combined_mean', 0.1), "%9.1f")
    local total_sd   = string(round(`combined_sd',   0.1), "%9.1f")
    
    * Append row to results dataset
    preserve
    use `results', clear
    local n = _N + 1
    set obs `n'
    replace variable = "`x'"                           in `n'
    replace total    = "`total_mean' [`total_sd']"     in `n'
    replace rural    = "`rural_mean' [`rural_sd']"     in `n'
    replace urban    = "`urban_mean' [`urban_sd']"     in `n'
    save `results', replace
    restore
}

* Export to Excel
preserve
use `results', clear
export excel using "descriptive_stats.xlsx", firstrow(variables) replace
restore

*-----------------------------
cls
preserve
foreach x of varlist ixa1a ixa1b ixa1c ixa1d ixa1e ixa1f{
	
	gen `x'_ncat = `x'
	recode `x'_ncat (0/2=0) (3/4=1)
	
	
	proportion `x'_ncat, cformat(%9.1f) percent
	proportion `x'_ncat, over(gender) cformat(%9.1f) percent
	prtest `x'_ncat, by(gender)
	
}
restore

/*===========================================================================
  Export proportion table to Excel
  Variables: ixa1a ixa1b ixa1c ixa1d ixa1e ixa1f
  Output:    table_output.xlsx
===========================================================================*/

cls
preserve

* ---- Labels for each item (edit as needed) --------------------------------
local label_ixa1a "In general, I see myself as a happy person"
local label_ixa1b "I blame myself when things go wrong"
local label_ixa1c "I worry for no good reason"
local label_ixa1d "I am so unhappy I can't sleep at night"
local label_ixa1e "I feel sad"
local label_ixa1f "I am so unhappy I think of harming myself"

* ---- Recode variables ------------------------------------------------------
foreach x of varlist ixa1a ixa1b ixa1c ixa1d ixa1e ixa1f {
	capture drop `x'_ncat
	gen `x'_ncat = `x'
	recode `x'_ncat (0/2=0) (3/4=1)
}

* ---- Set up Excel file using putexcel ---------------------------------------
local outfile "table_output.xlsx"
putexcel set "`outfile'", sheet("Table") replace

* ---- Header row -------------------------------------------------------------
putexcel A1 = "Characteristic"
putexcel B1 = "Total"
putexcel C1 = "Male"
putexcel D1 = "Female"
putexcel E1 = "P-value"

* Bold + center header
putexcel A1:E1, bold border(bottom, medium, black)

* ---- Loop over variables and populate rows ----------------------------------
local row = 2

foreach x of varlist ixa1a ixa1b ixa1c ixa1d ixa1e ixa1f {

	* -- Total proportion (category = 1) --
	quietly proportion `x'_ncat, percent
	matrix M = r(table)
	* row 1 = estimate, row 5 = lower CI, row 6 = upper CI (for category 1, col 2)
	local est_tot  = M[1,2]
	local lo_tot   = M[5,2]
	local hi_tot   = M[6,2]
	local cell_tot = string(round(`est_tot',0.1), "%9.1f") + ///
	                 " (" + string(round(`lo_tot',0.1), "%9.1f") + ///
	                 ", " + string(round(`hi_tot',0.1), "%9.1f") + ")"

	* -- By gender (assumes gender: 1=Male, 2=Female) --
	quietly proportion `x'_ncat, over(gender) percent
	matrix MG = r(table)

	* Column order in matrix: cat0_male, cat1_male, cat0_female, cat1_female
	* We want cat=1 for male (col 2) and cat=1 for female (col 4)
	local est_m  = MG[1,2]
	local lo_m   = MG[5,2]
	local hi_m   = MG[6,2]
	local cell_m = string(round(`est_m',0.1), "%9.1f") + ///
	               " (" + string(round(`lo_m',0.1), "%9.1f") + ///
	               ", " + string(round(`hi_m',0.1), "%9.1f") + ")"

	local est_f  = MG[1,4]
	local lo_f   = MG[5,4]
	local hi_f   = MG[6,4]
	local cell_f = string(round(`est_f',0.1), "%9.1f") + ///
	               " (" + string(round(`lo_f',0.1), "%9.1f") + ///
	               ", " + string(round(`hi_f',0.1), "%9.1f") + ")"

	* -- P-value from prtest --
	quietly prtest `x'_ncat, by(gender)
	local pval = r(p)
	local cell_p = string(round(`pval',0.001), "%9.3f")

	* -- Write row to Excel --
	putexcel A`row' = "``label_`x'''", txtwrap
	putexcel B`row' = "`cell_tot'", hcenter
	putexcel C`row' = "`cell_m'",   hcenter
	putexcel D`row' = "`cell_f'",   hcenter
	putexcel E`row' = "`cell_p'",   hcenter

	local row = `row' + 1
}

* ---- Column widths (putexcel does not set widths; use a post-open script) ---
* Tip: After running, manually widen column A to ~35 and B-E to ~20,
*      or add an xlsxwriter/openpyxl post-processing step.

* ---- Bottom border on last data row ----------------------------------------
local lastrow = `row' - 1
putexcel A`lastrow':E`lastrow', border(bottom, thin, black)

* ---- Save ------------------------------------------------------------------
putexcel save

di as result "Table exported to `outfile'"

restore

*-------------------------------------------------------------------------------

/*============================================================
  anxiety_table_export.do
  Exports anxiety score summary table to Excel in the format:
  Characteristic | Total | Male | Female
  Values shown as: mean (95% CI) or % (95% CI)
============================================================*/

* ---------- 0. Setup ----------
local outfile "anxiety_results.xlsx"
local sheet   "Table1"

* ---------- 1. Anxiety Score (GAD) — two-sample t-test ----------

* Overall mean + 95% CI
quietly ci means anxiety_score
local mean_all  = string(round(r(mean),  0.1), "%9.1f")
local lb_all    = string(round(r(lb),    0.1), "%9.1f")
local ub_all    = string(round(r(ub),    0.1), "%9.1f")
local ci_all    "`mean_all' (`lb_all', `ub_all')"

* By gender
foreach g in 0 1 {
    quietly ci means anxiety_score if gender == `g'
    local mean_`g' = string(round(r(mean), 0.1), "%9.1f")
    local lb_`g'   = string(round(r(lb),   0.1), "%9.1f")
    local ub_`g'   = string(round(r(ub),   0.1), "%9.1f")
    local ci_`g'   "`mean_`g'' (`lb_`g'', `ub_`g'')"
}
* gender==0 → Male, gender==1 → Female (adjust if your coding differs)
local ci_male   "`ci_0'"
local ci_female "`ci_1'"

* ---------- 2. Anxiety Categories (%) ----------

* Overall proportions with 95% CI (Wilson)
quietly proportion anx_cat
matrix P = r(table)          // rows: b se z p ll ul df crit eform

* Identify row indices for each category level
levelsof anx_cat, local(cats)
local ncat : word count `cats'

* Store overall CIs
local k = 0
foreach c of local cats {
    local ++k
    local pct_all_`c'  = string(round(P[1,`k']*100, 0.1), "%9.1f")
    local lb_all_`c'   = string(round(P[5,`k']*100, 0.1), "%9.1f")
    local ub_all_`c'   = string(round(P[6,`k']*100, 0.1), "%9.1f")
    local cipct_all_`c' "`pct_all_`c'' (`lb_all_`c'', `ub_all_`c'')"
}

* By gender
foreach g in 0 1 {
    quietly proportion anx_cat if gender == `g'
    matrix Pg`g' = r(table)
    local k = 0
    foreach c of local cats {
        local ++k
        local pct_`g'_`c'  = string(round(Pg`g'[1,`k']*100, 0.1), "%9.1f")
        local lb_`g'_`c'   = string(round(Pg`g'[5,`k']*100, 0.1), "%9.1f")
        local ub_`g'_`c'   = string(round(Pg`g'[6,`k']*100, 0.1), "%9.1f")
        local cipct_`g'_`c' "`pct_`g'_`c'' (`lb_`g'_`c'', `ub_`g'_`c'')"
    }
}

* ---------- 3. Build Excel table with putexcel ----------

putexcel set "`outfile'", sheet("`sheet'") replace

* --- Header row ---
putexcel A1 = "Characteristic"   ///
         B1 = "Total"            ///
         C1 = "Male"             ///
         D1 = "Female"

* Header formatting
putexcel A1:D1, bold border(bottom, medium, black) hcenter

* --- Row 2: Anxiety Score (GAD) ---
putexcel A2 = "Anxiety Score (GAD)" B2 = "`ci_all'" C2 = "`ci_male'" D2 = "`ci_female'"

* --- Row 3: Anxiety Categories header (no values) ---
putexcel A3 = "Anxiety Categories (%)", bold

* --- Category rows (Minimal Mild Moderate Severe) ---
* Map anx_cat values to labels — adjust labels to match your data
local rownum = 4
foreach c of local cats {

    * Get value label if defined, otherwise use numeric value
    local lbl : label (anx_cat) `c', strict
    if "`lbl'" == "" local lbl = "`c'"

    local val_male   "`cipct_0_`c''"
    local val_female "`cipct_1_`c''"

    putexcel A`rownum' = "    `lbl'"         ///
             B`rownum' = "`cipct_all_`c''"   ///
             C`rownum' = "`val_male'"         ///
             D`rownum' = "`val_female'"

    local ++rownum
}

* ---------- 4. Column widths & alignment ----------

putexcel A1:A`=`rownum'-1', txtwrap left
putexcel B1:D`=`rownum'-1', hcenter

* Column widths
putexcel set "`outfile'", sheet("`sheet'") modify


* Outer border around table
putexcel A1:D`=`rownum'-1', border(all, thin, black)
putexcel A1:D1,              border(bottom, medium, black)

putexcel save

display as result "Table exported to `outfile', sheet `sheet'"
