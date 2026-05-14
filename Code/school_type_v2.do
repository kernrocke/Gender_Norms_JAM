/*============================================================
  Stata Do-File: School Type Variable
  Study: JAM Intervention Study
  Source: Public_schools_KSA_coed_only.xlsx (Annual School Census 2021)
  
  School Type categories (from KSA "School Type" column):
    1 = Primary              (1.1 Primary)
    2 = Primary and Infant   (1.2 Primary and Infant)
    3 = Non-traditional high (2.3 Secondary High – Non-traditional)
    4 = Traditional high     (2.3 Secondary High – Traditional)
    
  Note: Campion College (schid not in ID doc) is a private school
  and does not appear in the public schools census file.
  Louise Bennett Coverley Primary (schid=6) confirmed as Primary
  based on school name and study docs.
============================================================*/

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
