
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          GNorms_JAM_002.do
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


/*==============================================================================
  JAMAICAN ADOLESCENT GENDER NORMS STUDY
  Stata Do-File: Objectives 1 & 2
  
  Objective 1: Document self-perceived gender norms of Jamaican adolescents
  Objective 2: Measure the impact of gender norms on adolescent health outcomes

  Author:   [Your Name]
  Date:     May 2026
  Dataset:  N = 584 adolescents, ages 10–14, Kingston, Jamaica
  Cluster:  School (schid)
==============================================================================*/

* ---------------------------------------------------------------------------- *
*  HOUSEKEEPING
* ---------------------------------------------------------------------------- *

clear all
set more off
capture log close

* Set your working directory — update this path before running
cd "/Users/kernrocke/Downloads"

* Open log
log using "gender_norms_analysis.log", replace text

*Set working directory
local datapath "/Users/kernrocke/Library/Mobile Documents/com~apple~CloudDocs/Github"


* Load dataset — update filename as needed
use "`datapath'/Gender_Norms_JAM/Dataset/GEAS-Jamaica-Phase2baseline-child-2024-10-22_WIDE_prelim_clean.dta", clear

gen school_type2 = school_type
recode school_type2 (2=1) (3/4=2)
label define school_type2 1"Primary" 2"Secondary"
label value school_type2 school_type2

drop school_type
rename school_type2 school_type
/*==============================================================================
  SECTION 0: DATA CLEANING & RECODING
==============================================================================*/

* ── Recode common "refuse/don't know/missing" codes to Stata missing ──────── *

local skip_codes 996 997 998 999

foreach var of varlist _all {
    capture confirm numeric variable `var'
    if !_rc {
        foreach code of local skip_codes {
            replace `var' = . if `var' == `code'
        }
    }
}

* ── Gender norms items: reverse-code equity-direction items ─────────────────── *
* Convention: higher score = more traditional/gender-stereotyped throughout
* Items needing reverse coding (higher agreement = more equitable, so flip):
foreach var in gn2 gn4 gn9 gn24 gn29 gn32 gn36 {
    capture confirm numeric variable `var'
    if !_rc {
        recode `var' (1=5)(2=4)(3=3)(4=2)(5=1), gen(`var'_r)
        label variable `var'_r "Reversed: `var'"
    }
}

* ── SES Asset Index ──────────────────────────────────────────────────────── *
foreach var in sa22a sa22b sa22c sa22d sa22e sa22f sa22g sa22h ///
               sa22i sa22j sa22k sa22l sa22m sa22n sa22o sa22p {
    capture confirm numeric variable `var'
    if !_rc {
        recode `var' (1=1)(else=0), gen(`var'_bin)
    }
}

egen ses_index = rowtotal(sa22a_bin sa22b_bin sa22c_bin sa22d_bin ///
    sa22e_bin sa22f_bin sa22g_bin sa22h_bin sa22i_bin sa22j_bin ///
    sa22k_bin sa22l_bin sa22m_bin sa22n_bin sa22o_bin sa22p_bin)
label variable ses_index "SES Asset Index (0-16)"

xtile ses_tertile = ses_index, nq(3)
label define ses_lbl 1 "Low SES" 2 "Middle SES" 3 "High SES"
label values ses_tertile ses_lbl
label variable ses_tertile "SES Tertile"

* ── IPV / GBV binary outcomes ─────────────────────────────────────────────── *
label define yn 0 "No" 1 "Yes"

* IPV victimization (any of xb5_1-xb5_4)
egen ipv_victim_max = rowmax(xb5_1 xb5_2 xb5_3 xb5_4)
gen ipv_victim_bin = (ipv_victim_max >= 1) if !missing(ipv_victim_max)
label variable ipv_victim_bin "Any IPV Victimization (partner)"
label values ipv_victim_bin yn

* IPV perpetration (any of xb6_1-xb6_4)
egen ipv_perp_max = rowmax(xb6_1 xb6_2 xb6_3 xb6_4)
gen ipv_perp_bin = (ipv_perp_max >= 1) if !missing(ipv_perp_max)
label variable ipv_perp_bin "Any IPV Perpetration (partner)"
label values ipv_perp_bin yn

* Any GBV
gen gbv_any = (ipv_victim_bin==1 | sex_harrass>0) if ///
    !missing(ipv_victim_bin) & !missing(sex_harrass)
label variable gbv_any "Any GBV (IPV or sexual harassment)"
label values gbv_any yn

* Peer victimization
gen peer_phys_vict  = (ixc10 == 1) if !missing(ixc10)
gen peer_verbal_vict = (ixc7 == 1) if !missing(ixc7)
label variable peer_phys_vict   "Peer Physical Victimization"
label variable peer_verbal_vict "Peer Verbal/Relational Victimization"
label values peer_phys_vict peer_verbal_vict yn

* ── Sexual debut ──────────────────────────────────────────────────────────── *
gen ever_sex = (xc11 == 1) if !missing(xc11)
label variable ever_sex "Ever Had Sexual Intercourse"
label values ever_sex yn

* ── Substance use ─────────────────────────────────────────────────────────── *
gen alcohol_ever   = (ixd1 == 1) if !missing(ixd1)
gen smoke_ever     = (ixd4 == 1) if !missing(ixd4)
gen marijuana_ever = (ixd6 == 1) if !missing(ixd6)
gen substance_any  = (alcohol_ever==1 | smoke_ever==1 | marijuana_ever==1) ///
    if !missing(alcohol_ever) & !missing(smoke_ever) & !missing(marijuana_ever)
label variable alcohol_ever    "Ever Used Alcohol"
label variable smoke_ever      "Ever Smoked Cigarettes"
label variable marijuana_ever  "Ever Used Marijuana"
label variable substance_any   "Any Substance Use"
foreach v in alcohol_ever smoke_ever marijuana_ever substance_any {
    label values `v' yn
}

* ── PHQ-9 depression caseness ────────────────────────────────────────────── *
gen phq_case = (depress_symp >= 10) if !missing(depress_symp)
label variable phq_case "PHQ depression case (score >=10)"
label values phq_case yn

* ── Fix parent_comfort coding error (values > 5 likely miscoded) ─────────── *
replace parent_comfort = . if parent_comfort > 5

* ── School connectedness composite ───────────────────────────────────────── *
capture confirm numeric variable ivb1
if !_rc {
    egen school_connect  = rowmean(ivb1 ivb2 ivb3)
    label variable school_connect "School Connectedness Score"
}
else {
    gen school_connect  = .
    label variable school_connect "School Connectedness Score (not constructed)"
}

* ── Label treatment variable ─────────────────────────────────────────────── *
label define treat_lbl 0 "Control" 1 "CrAFT Intervention"
label values treat treat_lbl

* ── Save cleaned dataset ─────────────────────────────────────────────────── *
save "gender_analysis_clean.dta", replace


/*==============================================================================
  SECTION 1: SCALE VALIDATION (Cronbach's Alpha)
==============================================================================*/

di _n "================================================================"
di    "SECTION 1: SCALE RELIABILITY"
di    "================================================================"

di _n "--- GST Scale (Gender Stereotypical Traits) ---"
alpha gn19 gn20 gn21 gn22_wi gn23 gn25 gn27, item

di _n "--- GSR Scale (Gender Stereotypical Roles) ---"
alpha gn23 gn24_r gn36_r, item

di _n "--- SDS Scale (Sexual Double Standards) ---"
alpha gn28 gn29_r gn30 gn31 gn32_r, item

di _n "--- NVRR Scale (Normative Views on Romantic Relationships) ---"
alpha gn1 gn2_r gn3 gn5 gn6 gn7 gn8 gn9_r gn10 gn11 ///
     gn12 gn13 gn14 gn15 gn16 gn17 gn18, item

di _n "--- Resilience / Self-Efficacy Scale ---"
alpha res_1 res_2 res_3 res_4 res_5 res_6 res_7 res_8 res_9 res_10, item

di _n "--- PHQ-9 Depression Scale ---"
alpha phq9_1 phq9_2 phq9_3 phq9_4 phq9_5 phq9_6 phq9_7 phq9_8 phq9_9, item

di _n "--- GAD-7 Anxiety Scale ---"
alpha gad7a gad7b gad7c gad7d gad7e gad7f gad7g, item

di _n "--- Body Satisfaction Scale ---"
alpha viiid1a viiid1b viiid1c viiid1f viiid1g, item


/*==============================================================================
  SECTION 2: OBJECTIVE 1 — DOCUMENTING GENDER NORMS
==============================================================================*/

di _n "================================================================"
di    "SECTION 2: OBJECTIVE 1 — DOCUMENTING GENDER NORMS"
di    "================================================================"

* ── 2.1 Overall descriptives ─────────────────────────────────────────────── *
di _n "--- 2.1 Overall Descriptives: Gender Norm Scores ---"
tabstat GST_score GSR_score SDS_score NVRR_score, ///
    stats(n mean sd min p25 p50 p75 max) columns(statistics) format(%6.3f)

* ── 2.2 By gender ────────────────────────────────────────────────────────── *
di _n "--- 2.2 Gender Norm Scores by Gender ---"
tabstat GST_score GSR_score SDS_score NVRR_score, ///
    by(gender) stats(n mean sd) format(%6.3f)
foreach score in GST_score GSR_score SDS_score NVRR_score {
    ttest `score', by(gender)
}

* ── 2.3 By age group ─────────────────────────────────────────────────────── *
di _n "--- 2.3 Gender Norm Scores by Age Group ---"
tabstat GST_score GSR_score SDS_score NVRR_score, ///
    by(age_grp) stats(n mean sd) format(%6.3f)
foreach score in GST_score GSR_score SDS_score NVRR_score {
    ttest `score', by(age_grp)
}

* ── 2.4 By school type ───────────────────────────────────────────────────── *
di _n "--- 2.4 Gender Norm Scores by School Type ---"
tabstat GST_score GSR_score SDS_score NVRR_score, ///
    by(school_type) stats(n mean sd) format(%6.3f)
foreach score in GST_score GSR_score SDS_score NVRR_score {
    ttest `score', by(school_type)
}

* ── 2.5 By locale ────────────────────────────────────────────────────────── *
di _n "--- 2.5 Gender Norm Scores by Locale ---"
tabstat GST_score GSR_score SDS_score NVRR_score, ///
    by(locale) stats(n mean sd) format(%6.3f)
foreach score in GST_score GSR_score SDS_score NVRR_score {
    ttest `score', by(locale)
}

* ── 2.6 By SES tertile (ANOVA) ───────────────────────────────────────────── *
di _n "--- 2.6 Gender Norm Scores by SES Tertile ---"
tabstat GST_score GSR_score SDS_score NVRR_score, ///
    by(ses_tertile) stats(n mean sd) format(%6.3f)
foreach score in GST_score GSR_score SDS_score NVRR_score {
    oneway `score' ses_tertile, tabulate
}

* ── 2.7 Individual norm item frequencies ─────────────────────────────────── *
di _n "--- 2.7 Individual Norm Item Distributions ---"
foreach var in gn1 gn2 gn3 gn4 gn5 gn6 gn7 gn8 gn9 gn10 ///
               gn11 gn12 gn13 gn14 gn15 gn16 gn17 gn18 ///
               gn19 gn20 gn21 gn22_wi gn23 gn24 gn25 gn26 gn27 ///
               gn28 gn29 gn30 gn31 gn32 gn36 {
    capture tab `var', missing
}

* ── 2.8 Norm items by gender ─────────────────────────────────────────────── *
di _n "--- 2.8 Key Norm Items by Gender (Chi-square) ---"
foreach var in gn1 gn3 gn5 gn7 gn10 gn11 gn12 gn13 gn16 gn18 ///
               gn19 gn20 gn21 gn25 gn26 gn27 gn28 gn30 {
    capture tab `var' gender, row chi2
}

* ── 2.9 Vignette response distributions by gender ────────────────────────── *
di _n "--- 2.9 Vignette Responses by Gender ---"

* Romantic initiation vignettes
foreach var in v1f1a v1f1b v1f1c v1f2a v1f2b v1f2c v1f2d ///
               v1m1a v1m1b v1m1c v1m2a v1m2b v1m2c v1m2d {
    capture tab `var' gender, row chi2
}
* Pregnancy vignettes
foreach var in v4f1a v4f1b v4f1c v4f2 v4f3 v4f4a v4f4b ///
               v4m1a v4m1b v4m1c v4m2 v4m3 v4m4a v4m4b {
    capture tab `var' gender, row chi2
}
* Peer exclusion vignettes
foreach var in v2f1a v2f2a v2f3a v2f4a v2f4b v2f4c ///
               v2m1a v2m2a v2m3a v2m4a v2m4b v2m4c {
    capture tab `var' gender, row chi2
}

* ── 2.10 Correlations among norm scores ──────────────────────────────────── *
di _n "--- 2.10 Correlations Among Norm Scores ---"
pwcorr GST_score GSR_score SDS_score NVRR_score, sig star(0.05)


/*==============================================================================
  SECTION 3: OBJECTIVE 2 — IMPACT OF GENDER NORMS ON HEALTH OUTCOMES
  Multilevel models: random intercept for school (schid)
  All models adjust for: gender, age, ses_index, ACE_score,
                         parent_monawe, social_cohesion, 
==============================================================================*/

di _n "================================================================"
di    "SECTION 3: OBJECTIVE 2 — GENDER NORMS AND HEALTH OUTCOMES"
di    "================================================================"

* Global variable lists
global norm_scores  "GST_score GSR_score SDS_score NVRR_score"
global covariates   "i.gender age ses_index ACE_score parent_monawe social_cohesion"
global covariates2  "$covariates "

* ── 3.0 Bivariate screening ──────────────────────────────────────────────── *
di _n "--- 3.0 Bivariate Correlations: Norm Scores vs. All Outcomes ---"
pwcorr $norm_scores voice behav_control freedom_move ///
    depress_symp anxiety_score body_satis_score ///
    sex_harrass ipv_victim_bin ever_sex substance_any, sig star(0.05)


/* ── 3A. PRIMARY OUTCOME 1: EMPOWERMENT ─────────────────────────────────── *
   Outcomes: voice, behav_control, freedom_move
   Model: Multilevel linear regression (mixed)
* ─────────────────────────────────────────────────────────────────────────── */

di _n "--- 3A. EMPOWERMENT OUTCOMES ---"
tabstat voice behav_control freedom_move, ///
    by(gender) stats(n mean sd) format(%6.3f)

di _n "Model 3A.1: Voice Score"
mixed voice $norm_scores $covariates2 || schid:, mle
estat icc
estimates store voice_model

di _n "Model 3A.2: Behavioral Control"
mixed behav_control $norm_scores $covariates2 || schid:, mle
estat icc
estimates store behav_model

di _n "Model 3A.3: Freedom of Movement"
mixed freedom_move $norm_scores $covariates2 || schid:, mle
estat icc
estimates store freedom_model

* Gender × norm interaction tests
di _n "--- Gender x Norm Interactions: Empowerment ---"
foreach outcome in voice behav_control freedom_move {
    di _n "Outcome: `outcome'"
    mixed `outcome' c.GST_score##i.gender c.SDS_score##i.gender ///
        GSR_score NVRR_score age ses_index ACE_score ///
        parent_monawe social_cohesion  || schid:, mle
}


/* ── 3B. PRIMARY OUTCOME 2: GBV / IPV ───────────────────────────────────── *
   Outcomes: ipv_victim_bin, ipv_perp_bin, sex_harrass, peer_phys_vict
   Model: melogit (binary); menbreg (count)
* ─────────────────────────────────────────────────────────────────────────── */

di _n "--- 3B. GBV / IPV OUTCOMES ---"
foreach v in ipv_victim_bin ipv_perp_bin gbv_any peer_phys_vict peer_verbal_vict {
    tab `v' gender, row chi2
}

di _n "Model 3B.1: IPV Victimization (OR)"
melogit ipv_victim_bin $norm_scores $covariates || schid:, or
estat icc
estimates store ipv_victim_model

di _n "Model 3B.2: IPV Perpetration (OR)"
melogit ipv_perp_bin $norm_scores $covariates || schid:, or
estat icc
estimates store ipv_perp_model

di _n "Model 3B.3: Sexual Harassment Score (negative binomial IRR)"
menbreg sex_harrass $norm_scores $covariates || schid:
estimates store sex_harrass_model

di _n "Model 3B.4: Peer Physical Victimization (OR)"
melogit peer_phys_vict $norm_scores $covariates2 || schid:, or
estimates store peer_phys_model

* Gender x SDS interaction for IPV
di _n "--- Gender x SDS Interaction: IPV Victimization ---"
melogit ipv_victim_bin c.SDS_score##i.gender c.NVRR_score##i.gender ///
    GST_score GSR_score age ses_index ACE_score ///
    parent_monawe social_cohesion || schid:, or


/* ── 3C. SECONDARY OUTCOME 1: DEPRESSION ────────────────────────────────── *
   Outcomes: depress_symp (0-24), phq_case (binary)
* ─────────────────────────────────────────────────────────────────────────── */

di _n "--- 3C. DEPRESSION ---"
tabstat depress_symp, by(gender) stats(n mean sd p50) format(%6.3f)
tab phq_case gender, row chi2

di _n "Model 3C.1: Depressive Symptoms Score (continuous)"
mixed depress_symp $norm_scores $covariates || schid:, mle
estat icc
estimates store depress_model

di _n "Model 3C.2: PHQ Depression Case - score >=10 (OR)"
melogit phq_case $norm_scores $covariates || schid:, or
estimates store depress_case_model


/* ── 3D. SECONDARY OUTCOME 2: ANXIETY ───────────────────────────────────── *
   Outcomes: anxiety_score (0-21), anx_cat (ordinal 1-4)
* ─────────────────────────────────────────────────────────────────────────── */

di _n "--- 3D. ANXIETY ---"
tabstat anxiety_score, by(gender) stats(n mean sd) format(%6.3f)
tab anx_cat gender, row chi2

di _n "Model 3D.1: GAD-7 Anxiety Score (continuous)"
mixed anxiety_score $norm_scores $covariates || schid:, mle
estat icc
estimates store anxiety_model

di _n "Model 3D.2: Anxiety Categories (ordinal logistic)"
* meologit requires Stata 16+; falls back to ologit with cluster SEs if unavailable
capture meologit anx_cat $norm_scores $covariates || schid:, or
if _rc {
    di "NOTE: meologit unavailable — using ologit with cluster SEs"
    ologit anx_cat $norm_scores $covariates, vce(cluster schid) or
}
estimates store anxiety_cat_model


/* ── 3E. SECONDARY OUTCOME 3: BODY SATISFACTION ─────────────────────────── *
   Outcome: body_satis_score
* ─────────────────────────────────────────────────────────────────────────── */

di _n "--- 3E. BODY SATISFACTION ---"
tabstat body_satis_score, by(gender) stats(n mean sd) format(%6.3f)
ttest body_satis_score, by(gender)

di _n "Model 3E.1: Body Satisfaction Score"
mixed body_satis_score $norm_scores $covariates || schid:, mle
estat icc
estimates store body_satis_model


/* ── 3F. SECONDARY OUTCOME 4: SUBSTANCE USE ─────────────────────────────── *
   Outcomes: substance_any, alcohol_ever, marijuana_ever (binary)
* ─────────────────────────────────────────────────────────────────────────── */

di _n "--- 3F. SUBSTANCE USE ---"
foreach v in alcohol_ever smoke_ever marijuana_ever substance_any {
    tab `v' gender, row chi2
}

di _n "Model 3F.1: Any Substance Use (OR)"
melogit substance_any $norm_scores $covariates || schid:, or
estimates store substance_model

di _n "Model 3F.2: Alcohol Use (OR)"
melogit alcohol_ever $norm_scores $covariates || schid:, or
estimates store alcohol_model

di _n "Model 3F.3: Marijuana Use (OR)"
melogit marijuana_ever $norm_scores $covariates || schid:, or
estimates store marijuana_model


/* ── 3G. SECONDARY OUTCOME 5: DELAY OF COITARCHE ────────────────────────── *
   Outcomes: ever_sex (binary); xc17b (age at first sex among sexually active)
* ─────────────────────────────────────────────────────────────────────────── */

di _n "--- 3G. SEXUAL DEBUT (COITARCHE) ---"
tab ever_sex gender, row chi2

di _n "Model 3G.1: Ever Had Sexual Intercourse (OR)"
melogit ever_sex $norm_scores $covariates || schid:, or
estat icc
estimates store coitarche_model

di _n "Model 3G.2: Age at First Intercourse (linear, sexually active only)"
*mixed xc17b $norm_scores $covariates if ever_sex==1 || schid:, mle
*estimates store age_sex_model


/*==============================================================================
  SECTION 4: MEDIATION ANALYSIS
  Pathway: Gender Norms → [Mediator] → Health Outcome
  Bootstrapped indirect effects (1000 reps)
  Install: ssc install sgmediation  (if Stata < 17)
==============================================================================*/

di _n "================================================================"
di    "SECTION 4: MEDIATION ANALYSIS"
di    "================================================================"

* Detect available mediation command
capture which mediate
if !_rc {
    local med_available "stata17"
    di "Using built-in -mediate- (Stata 17+)"
}
else {
    capture which sgmediation
    if !_rc {
        local med_available "sgmed"
        di "Using -sgmediation-"
    }
    else {
        local med_available "none"
        di "NOTE: No mediation package found. Run: ssc install sgmediation"
    }
}

* ── 4.1 SDS → Parental Monitoring → IPV Victimization ───────────────────── *
di _n "--- 4.1: SDS_score -> parent_monawe -> ipv_victim_bin ---"
if "`med_available'" == "stata17" {
    mediate (ipv_victim_bin, logit) (parent_monawe) (SDS_score), ///
        vce(bootstrap, reps(1000) seed(12345))
}
else if "`med_available'" == "sgmed" {
    sgmediation ipv_victim_bin, mv(parent_monawe) iv(SDS_score) ///
        cv(age ses_index ACE_score social_cohesion i.gender)
}

* ── 4.2 GST → Social Cohesion → Depression ──────────────────────────────── *
di _n "--- 4.2: GST_score -> social_cohesion -> depress_symp ---"
if "`med_available'" == "stata17" {
    mediate (depress_symp) (social_cohesion) (GST_score), ///
        vce(bootstrap, reps(1000) seed(12345))
}
else if "`med_available'" == "sgmed" {
    sgmediation depress_symp, mv(social_cohesion) iv(GST_score) ///
        cv(age ses_index ACE_score parent_monawe i.gender)
}

* ── 4.3 NVRR → ACE Score → Anxiety ─────────────────────────────────────── *
di _n "--- 4.3: NVRR_score -> ACE_score -> anxiety_score ---"
if "`med_available'" == "stata17" {
    mediate (anxiety_score) (ACE_score) (NVRR_score), ///
        vce(bootstrap, reps(1000) seed(12345))
}
else if "`med_available'" == "sgmed" {
    sgmediation anxiety_score, mv(ACE_score) iv(NVRR_score) ///
        cv(age ses_index parent_monawe social_cohesion i.gender)
}

* ── 4.4 SDS → Parental Monitoring → Sexual Debut ────────────────────────── *
di _n "--- 4.4: SDS_score -> parent_monawe -> ever_sex ---"
if "`med_available'" == "stata17" {
    mediate (ever_sex, logit) (parent_monawe) (SDS_score), ///
        vce(bootstrap, reps(1000) seed(12345))
}
else if "`med_available'" == "sgmed" {
    sgmediation ever_sex, mv(parent_monawe) iv(SDS_score) ///
        cv(age ses_index ACE_score social_cohesion i.gender)
}

* ── 4.5 GST → School Connectedness → Substance Use ─────────────────────── *
di _n "--- 4.5: GST_score ->  -> substance_any ---"
if "`med_available'" == "stata17" {
    mediate (substance_any, logit) () (GST_score), ///
        vce(bootstrap, reps(1000) seed(12345))
}
else if "`med_available'" == "sgmed" {
    sgmediation substance_any, mv() iv(GST_score) ///
        cv(age ses_index ACE_score parent_monawe i.gender)
}


/*==============================================================================
  SECTION 5: CrAFT INTERVENTION ANALYSIS
  Restricted to participants with treatment data (n~199)
  ANCOVA: Outcome = Treatment + Norm Scores + Covariates (cluster SEs by school)
==============================================================================*/

di _n "================================================================"
di    "SECTION 5: CrAFT INTERVENTION ANALYSIS (treat subsample)"
di    "================================================================"

preserve
keep if !missing(treat)

di "Intervention subsample N = " _N
tab treat gender, row chi2

* Balance check
di _n "--- 5.1 Balance Checks: Norm Scores by Treatment Arm ---"
tabstat GST_score GSR_score SDS_score NVRR_score, ///
    by(treat) stats(n mean sd) format(%6.3f)
foreach score in GST_score GSR_score SDS_score NVRR_score {
    ttest `score', by(treat)
}

* ── 5.2 Treatment effect on empowerment ──────────────────────────────────── *
di _n "--- 5.2 Treatment Effect on Empowerment ---"
foreach outcome in voice behav_control freedom_move {
    di _n "Outcome: `outcome'"
    regress `outcome' i.treat $norm_scores $covariates2, vce(cluster schid)
    lincom 1.treat
}

* ── 5.3 Treatment effect on mental health ────────────────────────────────── *
di _n "--- 5.3 Treatment Effect on Mental Health ---"
foreach outcome in depress_symp anxiety_score body_satis_score {
    di _n "Outcome: `outcome'"
    regress `outcome' i.treat $norm_scores $covariates, vce(cluster schid)
}

* ── 5.4 Treatment effect on GBV/IPV and behavioural outcomes ─────────────── *
di _n "--- 5.4 Treatment Effect on GBV/Behavioural Outcomes ---"
foreach outcome in ipv_victim_bin gbv_any ever_sex substance_any {
    di _n "Outcome: `outcome'"
    logit `outcome' i.treat $norm_scores $covariates, ///
        vce(cluster schid) or
}

* ── 5.5 Treatment × gender interaction ──────────────────────────────────── *
di _n "--- 5.5 Treatment x Gender Interaction ---"
foreach outcome in voice depress_symp ipv_victim_bin {
    di _n "Outcome: `outcome'"
    capture mixed `outcome' i.treat##i.gender $norm_scores ///
        age ses_index ACE_score parent_monawe social_cohesion || schid:, mle
    if _rc {
        regress `outcome' i.treat##i.gender $norm_scores ///
            age ses_index ACE_score parent_monawe, vce(cluster schid)
    }
}

restore


/*==============================================================================
  SECTION 6: EXPORT TABLES (requires -estout-: ssc install estout)
==============================================================================*/

di _n "================================================================"
di    "SECTION 6: EXPORT SUMMARY TABLES"
di    "================================================================"

capture which esttab
if _rc {
    di "NOTE: Install estout first: ssc install estout"
}
else {

    * Table 1: Sample characteristics by gender
    estpost tabstat age ses_index ACE_score parent_monawe social_cohesion ///
        GST_score GSR_score SDS_score NVRR_score voice behav_control ///
        freedom_move depress_symp anxiety_score body_satis_score, ///
        by(gender) stats(mean sd) columns(statistics)
    esttab using "Table1_sample_characteristics.csv", ///
        cells("mean(fmt(2)) sd(fmt(2))") label nostar replace ///
        title("Table 1: Sample Characteristics by Gender")

    * Table 2: Norm scores by gender
    estpost tabstat GST_score GSR_score SDS_score NVRR_score, ///
        by(gender) stats(mean sd n) columns(statistics)
    esttab using "Table2_norm_scores_by_gender.csv", ///
        cells("mean(fmt(2)) sd(fmt(2)) count(fmt(0))") label nostar replace ///
        title("Table 2: Gender Norm Scores by Gender")

    * Table 3: Empowerment outcomes
    esttab voice_model behav_model freedom_model ///
        using "Table3_empowerment_models.csv", ///
        b(3) ci(3) label nostar replace ///
        title("Table 3: Multilevel Linear Regression - Empowerment Outcomes") ///
        mtitles("Voice" "Behavioral Control" "Freedom of Movement")

    * Table 4: GBV/IPV outcomes (OR)
    esttab ipv_victim_model ipv_perp_model peer_phys_model ///
        using "Table4_GBV_models.csv", ///
        b(3) ci(3) eform label nostar replace ///
        title("Table 4: Multilevel Logistic Regression - GBV/IPV Outcomes (OR)") ///
        mtitles("IPV Victim" "IPV Perpetration" "Peer Physical Victim")

    * Table 5: Mental health outcomes
    esttab depress_model anxiety_model body_satis_model ///
        using "Table5_mental_health_models.csv", ///
        b(3) ci(3) label nostar replace ///
        title("Table 5: Multilevel Linear Regression - Mental Health Outcomes") ///
        mtitles("Depression" "Anxiety" "Body Satisfaction")

    * Table 6: Behavioural outcomes (OR)
    esttab coitarche_model substance_model alcohol_model marijuana_model ///
        using "Table6_behavioural_models.csv", ///
        b(3) ci(3) eform label nostar replace ///
        title("Table 6: Multilevel Logistic Regression - Behavioural Outcomes (OR)") ///
        mtitles("Ever Sex" "Any Substance" "Alcohol" "Marijuana")

    di "All tables exported to working directory."
}


/*==============================================================================
  END OF DO FILE
==============================================================================*/

di _n "================================================================"
di    "ANALYSIS COMPLETE"
di    "================================================================"

log close


/*------------------------------------------------------------------------------
  ANALYST NOTES
  
  Before running, update:
    - cd path (line ~25)
    - use filename (line ~30)
  
  Required packages (install if missing):
    ssc install estout      (export tables — Section 6)
    ssc install sgmediation (mediation if Stata <17 — Section 4)
  
  Key data checks:
    1. Confirm GST/GSR/SDS/NVRR item membership matches questionnaire
    2. parent_comfort recoded to missing where >5 — verify original construction
    3. freedom_move, voice, behav_control have ~130 missing — check skip logic
       (may be sex-specific items); inspect before pooled models
    4. treat is missing for 385 obs — Section 5 is underpowered; note in paper
    5. If pwcorr shows r>0.80 between any norm score pair, consider running
       models with one norm score at a time to avoid multicollinearity
    6. meologit (ordinal logistic multilevel) requires Stata 16+;
       code falls back to ologit with cluster SEs automatically
------------------------------------------------------------------------------*/


cls
foreach x of varlis age ses_index ACE_score parent_monawe social_cohesion GST_score GSR_score SDS_score NVRR_score voice behav_control freedom_move depress_symp anxiety_score body_satis_score GST_score GSR_score SDS_score NVRR_score {
	
	ttest `x', by(gender)
}
