cls

cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          GNorms_JAM_003.do
    //  project:                Gender Norms among Adolescents in Jamaica
    //  analysts:               Kern ROCKE
    //  date first created      17-OCT-2024
    // 	date last modified      12-MAY-2026
    //  algorithm task          Multilevel Regression_modelling
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


log using "/Users/kernrocke/Downloads/regression_resuls_gender_abby.log", replace
/* ── 3A. PRIMARY OUTCOME 1: EMPOWERMENT ─────────────────────────────────── *
   Outcomes: voice, behav_control, freedom_move
   Model: Multilevel linear regression (mixed)
* ─────────────────────────────────────────────────────────────────────────── */

di _n "Model 3A.1: Voice Score"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

mixed voice `x' i.gender age i.ses_tertile ACE_score parent_monawe social_cohesion  || schid:, mle cformat(%9.2f)

}

di _n "Model 3A.2: Behavioral Control"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

mixed behav_control `x' i.gender age i.ses_tertile ACE_score parent_monawe social_cohesion  || schid:, mle cformat(%9.2f)

}

di _n "Model 3A.3: Freedom of Movement"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

mixed freedom_move `x' i.gender age i.ses_tertile ACE_score parent_monawe social_cohesion  || schid:, mle cformat(%9.2f)

}

*-------------------------------------------------
*-------------------------------------------------
*-------------------------------------------------

/* ── 3B. PRIMARY OUTCOME 2: GBV / IPV ───────────────────────────────────── *
   Outcomes: ipv_victim_bin, ipv_perp_bin, sex_harrass, peer_phys_vict
   Model: melogit (binary); menbreg (count)
* ─────────────────────────────────────────────────────────────────────────── */

di _n "Model 3B.1: IPV Victimization (OR)"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

melogit ipv_victim_bin `x' i.gender age i.ses_tertile ACE_score parent_monawe social_cohesion || schid:, or

}

di _n "Model 3B.2: IPV Perpetration (OR)"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

melogit ipv_perp_bin `x' i.gender age ses_index ACE_score parent_monawe social_cohesion || schid:, or nolog cformat(%9.2f)

}

di _n "Model 3B.3: Sexual Harassment Score (negative binomial IRR)"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

menbreg sex_harrass `x' i.gender age ses_index ACE_score parent_monawe social_cohesion || schid:, nolog irr cformat(%9.2f)

}

di _n "Model 3B.4: Peer Physical Victimization (OR)"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

melogit peer_phys_vict `x' i.gender age ses_index ACE_score parent_monawe social_cohesion || schid:, or nolog cformat(%9.2f)

}
*-------------------------------------------------
*-------------------------------------------------
*-------------------------------------------------

/* ── 3C. SECONDARY OUTCOME 1: DEPRESSION ────────────────────────────────── *
   Outcomes: depress_symp (0-24), phq_case (binary)
* ─────────────────────────────────────────────────────────────────────────── */

di _n "Model 3C.1: Depressive Symptoms Score (continuous)"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

mixed depress_symp `x' i.gender age i.ses_tertile ACE_score parent_monawe social_cohesion  || schid:, mle cformat(%9.2f)

}

di _n "Model 3C.2: PHQ Depression Case - score >=10 (OR)"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

melogit phq_case `x' i.gender age ses_index ACE_score parent_monawe social_cohesion || schid:, or nolog cformat(%9.2f)

}

*-------------------------------------------------
*-------------------------------------------------
*-------------------------------------------------

/* ── 3D. SECONDARY OUTCOME 2: ANXIETY ───────────────────────────────────── *
   Outcomes: anxiety_score (0-21), anx_cat (ordinal 1-4)
* ─────────────────────────────────────────────────────────────────────────── */

di _n "Model 3D.1: GAD-7 Anxiety Score (continuous)"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

mixed anxiety_score `x' i.gender age i.ses_tertile ACE_score parent_monawe social_cohesion  || schid:, mle cformat(%9.2f)

}

di _n "Model 3D.2: Anxiety Categories (ordinal logistic)"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

meologit anx_cat `x' i.gender age ses_index ACE_score parent_monawe social_cohesion || schid:, or nolog cformat(%9.2f)

}

*-------------------------------------------------
*-------------------------------------------------
*-------------------------------------------------

/* ── 3E. SECONDARY OUTCOME 3: BODY SATISFACTION ─────────────────────────── *
   Outcome: body_satis_score
* ─────────────────────────────────────────────────────────────────────────── */

di _n "--- 3E. BODY SATISFACTION ---"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

mixed body_satis_score `x' i.gender age i.ses_tertile ACE_score parent_monawe social_cohesion  || schid:, mle cformat(%9.2f)

}

*-------------------------------------------------
*-------------------------------------------------
*-------------------------------------------------

/* ── 3F. SECONDARY OUTCOME 4: SUBSTANCE USE ─────────────────────────────── *
   Outcomes: substance_any, alcohol_ever, marijuana_ever (binary)
* ─────────────────────────────────────────────────────────────────────────── */

di _n "Model 3F.1: Any Substance Use (OR)"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

melogit substance_any `x' i.gender age ses_index ACE_score parent_monawe social_cohesion || schid:, or nolog cformat(%9.2f)

}

di _n "Model 3F.2: Alcohol Use (OR)"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

melogit alcohol_ever `x' i.gender age ses_index ACE_score parent_monawe social_cohesion || schid:, or nolog cformat(%9.2f)

}

di _n "Model 3F.3: Marijuana Use (OR)"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

melogit marijuana_ever `x' i.gender age ses_index ACE_score parent_monawe social_cohesion || schid:, or nolog cformat(%9.2f)

}

*-------------------------------------------------
*-------------------------------------------------
*-------------------------------------------------

/* ── 3G. SECONDARY OUTCOME 5: DELAY OF COITARCHE ────────────────────────── *
   Outcomes: ever_sex (binary); xc17b (age at first sex among sexually active)
* ─────────────────────────────────────────────────────────────────────────── */


di _n "Model 3G.1: Ever Had Sexual Intercourse (OR)"
cls
foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

melogit ever_sex `x' i.gender age ses_index ACE_score parent_monawe social_cohesion || schid:, or nolog cformat(%9.2f)

}

di _n "Model 3G.2: Age at First Intercourse (linear, sexually active only)"

foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

mixed xc17b `x' i.gender age i.ses_tertile ACE_score parent_monawe social_cohesion  || schid:, mle cformat(%9.2f)

}

*-------------------------------------------------
*-------------------------------------------------
*-------------------------------------------------

*Description of main exposures
d GST_score GSR_score SDS_score NVRR_score

log close


foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

mixed Depression_score `x' i.gender age i.ses_tertile ACE_score parent_monawe social_cohesion  || schid:, mle cformat(%9.2f)

}

cls
foreach x of varlist GST_score GSR_score SDS_score NVRR_score{

melogit dep_binary `x' i.gender age ses_index ACE_score parent_monawe social_cohesion || schid:, or nolog cformat(%9.2f)

}
