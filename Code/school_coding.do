/*============================================================
  Stata Do-File: School ID and Intervention Status Coding
  Study: JAM Intervention Study
  Date: 2024
  Source documents:
    - Schoolname-IDs.docx
    - School_selection_Intervention_study_JAM_v2.docx
    - Additional_Schools_JAM_20240513.docx
============================================================*/


*------------------------------------------------------------
* PART 1: CODE SCHOOL ID (schid) RANGING FROM 1 TO 33
*------------------------------------------------------------
* Note: IDs 26 and 32 are not assigned in the master ID list.
* Cavaliers Primary appears in the additional schools doc
* but has no ID assigned in Schoolname-IDs.docx; include if added later.

gen schid = .

* --- Primary Schools (IDs 1–12, from original selection) ---
replace schid = 1  if schoolname == "Clifton Primary"
replace schid = 2  if schoolname == "Dallas Primary and Infant"
replace schid = 3  if schoolname == "Essex Hall Primary"
replace schid = 4  if schoolname == "Franklin Town Primary"
replace schid = 5  if schoolname == "Jones Town Primary"
replace schid = 6  if schoolname == "Louise Bennett Coverley Primary"
replace schid = 7  if schoolname == "St. Benedict's Primary"
replace schid = 8  if schoolname == "St. Michael's Primary"
replace schid = 9  if schoolname == "St. Patrick's Primary"
replace schid = 10 if schoolname == "St. George's Girls Primary and Infant"
replace schid = 11 if schoolname == "Stony Hill Primary and Infant"
replace schid = 12 if schoolname == "Whitfield Primary and Infant"

* --- Secondary Schools (IDs 13–21, from original selection) ---
replace schid = 13 if schoolname == "Excelsior High"
replace schid = 14 if schoolname == "Gaynstead High"
replace schid = 15 if schoolname == "Haile Selassie High"
replace schid = 16 if schoolname == "Kingston High"
replace schid = 17 if schoolname == "Norman Manley High"
replace schid = 18 if schoolname == "Oberlin High"
replace schid = 19 if schoolname == "Papine High"
replace schid = 20 if schoolname == "Tarrant High"
replace schid = 21 if schoolname == "Vauxhall High"

* --- Additional Schools – Secondary (IDs 22, 24, 25, 28, 31) ---
replace schid = 22 if schoolname == "Penwood High"
replace schid = 24 if schoolname == "Ardenne High"
replace schid = 25 if schoolname == "Mavis Bank High"
replace schid = 28 if schoolname == "Pembroke Hall High"   // listed as "Pembroke High" in ID doc
replace schid = 31 if schoolname == "Meadowbrook High"

* --- Additional Schools – Primary (IDs 23, 27, 29, 30) ---
replace schid = 23 if schoolname == "Jessie Ripoll Primary"
replace schid = 27 if schoolname == "Edward Seaga Primary"
replace schid = 29 if schoolname == "St. Aloysius Primary"  // listed as "St. Aloysis Primary" in ID doc
replace schid = 30 if schoolname == "Mountain View Primary and Infant"  // listed as "Mountain View Primary" in ID doc

* --- Special / Other (ID 33) ---
replace schid = 33 if schoolname == "Eve for Life"

* Note: IDs 26 and 32 are not assigned in source documents.

label variable schid "School ID (1–33)"


*------------------------------------------------------------
* PART 2: CODE INTERVENTION STATUS
*------------------------------------------------------------
* Source: School_selection_Intervention_study_JAM_v2.docx
*         Additional_Schools_JAM_20240513.docx
*
* Coding:  1 = Intervention
*          0 = Control
*
* Primary schools: intervention status not listed in source
*   documents; left as missing (.) unless data become available.
* Secondary schools: status assigned per Treatment Group column.

gen intervention = .

* --- Secondary Schools: Original Selection ---
* Intervention
replace intervention = 1 if schid == 15   // Haile Selassie High
replace intervention = 1 if schid == 13   // Excelsior High
replace intervention = 1 if schid == 17   // Norman Manley High
replace intervention = 1 if schid == 19   // Papine High
replace intervention = 1 if schid == 16   // Kingston High

* Control
replace intervention = 0 if schid == 18   // Oberlin High
replace intervention = 0 if schid == 14   // Gaynstead High
replace intervention = 0 if schid == 20   // Tarrant High
replace intervention = 0 if schid == 21   // Vauxhall High
replace intervention = 0 if schid == 31   // Campion College (Meadowbrook High in ID doc — verify)

* --- Secondary Schools: Additional Schools ---
* Intervention
replace intervention = 1 if schid == 22   // Penwood High
replace intervention = 1 if schid == 28   // Pembroke Hall High
replace intervention = 1 if schid == 24   // Ardenne High

* Control
replace intervention = 0 if schid == 25   // Mavis Bank High

* --- Primary Schools: No treatment group listed in source documents ---
* intervention remains missing (.) for schids 1–12, 23, 27, 29, 30

* Value label
label define intervention_lbl 0 "Control" 1 "Intervention"
label values intervention intervention_lbl
label variable intervention "Intervention status (1=Intervention, 0=Control)"


*------------------------------------------------------------
* VERIFICATION: Quick tabulation
*------------------------------------------------------------
tab schid intervention, miss
