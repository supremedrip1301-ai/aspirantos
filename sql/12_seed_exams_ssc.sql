-- ============================================================
-- AspirantOS - 12_seed_exams_ssc.sql
-- Staff Selection Commission exams (11 exams): CGL, CHSL, MTS & Havaldar, GD Constable,
-- CPO, JE, Stenographer C & D, Selection Post, Delhi Police Constable (Executive),
-- Delhi Police Head Constable (Ministerial), Combined Hindi Translators.
-- Uses 05_seed_helpers.sql. Re-runnable.
-- SSC announces the age "crucial date" in every notification; the dates below are the
-- usual ones (1 August for most exams). The engine shows the date it used.
-- Post-wise age limits = one age_rule row per post group.
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the latest SSC notification known to the developer (2025-26 cycle). Confirm the crucial date and limits in the current notification on ssc.gov.in.';
SET @nat_ssc = 'INDIAN,NEPAL,BHUTAN,TIBETAN_REFUGEE,PIO';

-- ---------- SSC CGL ----------
CALL sp_seed_exam('SSC_CGL', 'Combined Graduate Level Examination', 'SSC CGL', 'SSC', 'SSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 6, 9,
     'Tier 1 (CBT) → Tier 2 (CBT) → Document verification / skill test',
     'Assistant Section Officer, Inspector (Income Tax, CGST, Preventive Officer, Examiner), Sub-Inspector (CBI, NIA), Auditor, Accountant, UDC, Tax Assistant, JSO, Statistical Investigator',
     'https://ssc.gov.in',
     'The biggest graduate-level recruitment for Group B and Group C central government posts. Age limits differ by post.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST, PwBD and ex-servicemen', 'No attempt limit; you can appear every year while you are within the age limit of a post.');
CALL sp_seed_age('Posts with limit 18-27 (Auditor, Accountant, UDC, Tax Assistant, Inspector NCB)', 18, 27, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 18-27 on the crucial date (usually 1 August)');
CALL sp_seed_age('Posts with limit 18-30 (Inspector Income Tax/CGST/Posts, Assistant Audit Officer)', 18, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 18-30 on the crucial date');
CALL sp_seed_age('Posts with limit 20-30 (ASO CSS/MEA, Sub-Inspector CBI/NIA)', 20, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 20-30 on the crucial date');
CALL sp_seed_age('Posts with limit 18-32 (JSO, Statistical Investigator Gr II)', 18, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 18-32 on the crucial date');
CALL sp_seed_relax_ssc(TRUE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL,
     'Bachelor''s degree in any discipline; final-year students may apply if they pass by the cut-off date in the notification');
CALL sp_seed_qual('Posts with limit 18-32 (JSO, Statistical Investigator Gr II)', 'UG', 'ANY', 'CLASS_12:MATHS', 60, NULL, NULL, TRUE, NULL, NULL,
     'JSO: graduation with at least 60% in Mathematics at Class 12');
CALL sp_seed_qual('Posts with limit 18-32 (JSO, Statistical Investigator Gr II)', 'UG', 'ANY', 'STATISTICS', NULL, NULL, NULL, TRUE, NULL, NULL,
     'JSO: or graduation with Statistics as one of the subjects');
CALL sp_seed_qual('Posts with limit 18-32 (JSO, Statistical Investigator Gr II)', 'UG', 'ANY',
     'STATISTICS|MATHS|ECONOMICS|DEMOGRAPHY|POPULATION STUDIES|OPERATIONS RESEARCH|INFORMATION TECHNOLOGY|COMPUTER SCIENCE|COMPUTER APPLICATION|DATA SCIENCE|ARTIFICIAL INTELLIGENCE',
     NULL, NULL, NULL, TRUE, NULL, NULL,
     'Statistical Investigator Gr II: bachelor''s degree in Statistics, Maths, Economics, Demography, Population Studies, OR, IT, CS / Computer Engg / Application, Data Science or AI');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_ssc, TRUE, 'Indian citizens and the categories listed in the notification');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, 'Inspector (CGST, Preventive Officer, Examiner, CBN) and Sub-Inspector posts have physical standards and tests');

-- ---------- SSC CHSL ----------
CALL sp_seed_exam('SSC_CHSL', 'Combined Higher Secondary (10+2) Level Examination', 'SSC CHSL', 'SSC', 'SSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 6, 11,
     'Tier 1 (CBT) → Tier 2 (CBT + typing / skill test)',
     'Lower Division Clerk / Junior Secretariat Assistant, Data Entry Operator, Postal Assistant / Sorting Assistant',
     'https://ssc.gov.in',
     'Class 12 level recruitment for clerical and data entry posts in central ministries and offices.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 27, 'NOT_ATTAINED', 'FIXED_DATE_IN_NEXT_YEAR', 1, 1, 'Age 18-27 on 1 January after the exam year (CHSL 2025: exam from Nov 2025, age on 01-01-2026)');
CALL sp_seed_relax_ssc(TRUE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL,
     'Class 12 pass from a recognised board; DEO in C&AG needs Class 12 with Mathematics (Science stream)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_ssc, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- SSC MTS & Havaldar ----------
CALL sp_seed_exam('SSC_MTS', 'Multi Tasking (Non-Technical) Staff and Havaldar (CBIC & CBN) Examination', 'SSC MTS', 'SSC', 'SSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 6, 2,
     'CBT → PET/PST (Havaldar only) → Document verification',
     'Multi Tasking Staff (Group C); Havaldar in CBIC and CBN',
     'https://ssc.gov.in',
     'Class 10 level recruitment for multi-tasking staff and Havaldar posts.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age('MTS (most posts)', 18, 25, 'NOT_ATTAINED', 'FIXED_DATE_IN_PREVIOUS_YEAR', 8, 1, 'Age 18-25 on 1 August of the year before the CBE (MTS 2025: CBE in early 2026, age on 01-08-2025)');
CALL sp_seed_age('Havaldar (CBIC, CBN) and some MTS posts', 18, 27, 'NOT_ATTAINED', 'FIXED_DATE_IN_PREVIOUS_YEAR', 8, 1, 'Age 18-27 on 1 August of the year before the CBE');
CALL sp_seed_relax_ssc(TRUE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Class 10 (Matriculation) pass');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_ssc, TRUE, 'Indian citizens and the categories listed in the notification');
CALL sp_seed_other('Havaldar (CBIC, CBN) and some MTS posts', 'PHYSICAL_STANDARD', NULL, FALSE, 'Havaldar: walking test (1600 m in 15 min men / 1 km in 20 min women) and height/chest standards');

-- ---------- SSC GD Constable ----------
CALL sp_seed_exam('SSC_GD', 'Constable (General Duty) in CAPFs, SSF, Rifleman in Assam Rifles and Sepoy in NCB', 'SSC GD', 'SSC', 'SSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 12, 2,
     'CBT → Physical Efficiency & Standard Test → Medical → Document verification',
     'Constable GD in BSF, CISF, CRPF, ITBP, SSB, SSF; Rifleman in Assam Rifles; Sepoy in NCB',
     'https://ssc.gov.in',
     'Class 10 level recruitment of constables for the central armed police forces. Men and women can apply; state-wise vacancies.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 23, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 18-23 on 1 January of the exam year');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('EX_SERVICEMAN', NULL, 3, 'ADD_AFTER_SERVICE_DEDUCTION', NULL, FALSE, 'Age minus military service must not exceed the limit by more than 3 years');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 10 (Matriculation) pass on or before the cut-off date');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'Combat posts: PwBD candidates are not eligible');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, 'Race (5 km in 24 min men / 1.6 km in 8.5 min women), height and chest standards');

-- ---------- SSC CPO ----------
CALL sp_seed_exam('SSC_CPO', 'Sub-Inspector in Delhi Police and Central Armed Police Forces Examination', 'SSC CPO', 'SSC', 'SSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 11,
     'Paper 1 (CBT) → PST/PET → Paper 2 (CBT) → Medical',
     'Sub-Inspector (Executive) in Delhi Police; Sub-Inspector (GD) in BSF, CISF, CRPF, ITBP, SSB',
     'https://ssc.gov.in',
     'Graduate-level recruitment of Sub-Inspectors. Men and women can apply.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 20, 25, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 20-25 on the crucial date');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('EX_SERVICEMAN', NULL, 3, 'ADD_AFTER_SERVICE_DEDUCTION', NULL, FALSE, 'Age minus military service must not exceed the limit by more than 3 years');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Bachelor''s degree; must be passed by the cut-off date');
CALL sp_seed_relax('WIDOW_DIVORCED_WOMEN', 'GEN',     0, 'REPLACE_WITH_MAX', 35, FALSE, 'SI in Delhi Police: widows / divorced / judicially separated women not remarried, up to 35');
CALL sp_seed_relax('WIDOW_DIVORCED_WOMEN', 'EWS',     0, 'REPLACE_WITH_MAX', 35, FALSE, 'SI in Delhi Police: up to 35');
CALL sp_seed_relax('WIDOW_DIVORCED_WOMEN', 'OBC_NCL', 0, 'REPLACE_WITH_MAX', 35, FALSE, 'SI in Delhi Police: up to 35');
CALL sp_seed_relax('WIDOW_DIVORCED_WOMEN', 'SC',      0, 'REPLACE_WITH_MAX', 40, FALSE, 'SI in Delhi Police (SC): up to 40');
CALL sp_seed_relax('WIDOW_DIVORCED_WOMEN', 'ST',      0, 'REPLACE_WITH_MAX', 40, FALSE, 'SI in Delhi Police (ST): up to 40');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_ssc, TRUE, 'Indian citizens and the categories listed in the notification');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'PwBD candidates are not eligible');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, 'Height, chest and physical efficiency tests; male candidates for Delhi Police need a valid LMV driving licence at the PET');

-- ---------- SSC JE ----------
CALL sp_seed_exam('SSC_JE', 'Junior Engineer (Civil, Mechanical, Electrical) Examination', 'SSC JE', 'SSC', 'SSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 7, 10,
     'Paper 1 (CBT) → Paper 2 (descriptive / CBT) → Document verification',
     'Junior Engineer in CPWD, CWC, MES, BRO, Farakka Barrage, NTRO and others',
     'https://ssc.gov.in',
     'Recruitment of diploma / degree engineers as Junior Engineers (Group B). Age limit depends on the department.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age('Departments with limit 32 (CPWD, MES, Farakka and others)', 18, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Up to 32 years on the crucial date');
CALL sp_seed_age('Departments with limit 30 (CWC, BRO and others)', 18, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Up to 30 years on the crucial date');
CALL sp_seed_relax_ssc(TRUE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'DIPLOMA', 'ANY', 'CIVIL|MECHANICAL|ELECTRICAL', NULL, NULL, NULL, FALSE, NULL, NULL,
     'Diploma or degree in Civil / Mechanical / Electrical Engineering (some departments ask for a degree or diploma + 2 years experience)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_ssc, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- SSC Stenographer Grade C & D ----------
CALL sp_seed_exam('SSC_STENO', 'Stenographer Grade C and D Examination', 'SSC Steno', 'SSC', 'SSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 7, 10,
     'CBT → Stenography skill test',
     'Stenographer Grade C (Group B) and Grade D (Group C)',
     'https://ssc.gov.in',
     'Class 12 level recruitment of stenographers; a shorthand skill test follows the written exam.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age('Stenographer Grade C', 18, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 18-30 on the crucial date');
CALL sp_seed_age('Stenographer Grade D', 18, 27, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 18-27 on the crucial date');
CALL sp_seed_relax_ssc(TRUE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Class 12 pass from a recognised board');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_ssc, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- SSC Selection Post ----------
CALL sp_seed_exam('SSC_SELECTION_POST', 'Selection Post Examination (Phase)', 'SSC Selection Post', 'SSC', 'SSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 6, 7,
     'CBT → Skill test / document verification (post-wise)',
     'Hundreds of department-specific posts at Matriculation, Class 12 and Graduation level',
     'https://ssc.gov.in',
     'One combined exam for many small department-specific posts. Every post has its own age limit and qualification, so always read the post list.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 100 per post; no fee for women, SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit of the post.');
CALL sp_seed_age('Matriculation level posts', 18, 25, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Typical limit 18-25 (varies by post)');
CALL sp_seed_age('Higher Secondary level posts', 18, 27, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Typical limit 18-27 (varies by post)');
CALL sp_seed_age('Graduation level posts', 18, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Typical limit 18-30 (varies by post)');
CALL sp_seed_relax_ssc(TRUE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual('Matriculation level posts', 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 10 pass (plus post-specific skills)');
CALL sp_seed_qual('Higher Secondary level posts', 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 12 pass (plus post-specific skills)');
CALL sp_seed_qual('Graduation level posts', 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation (plus post-specific degree / experience)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_ssc, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- Delhi Police Constable (Executive) ----------
CALL sp_seed_exam('SSC_DP_CONSTABLE', 'Constable (Executive) Male and Female in Delhi Police', 'Delhi Police Constable', 'SSC', 'SSC',
     'STATE', 'DL', 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 12,
     'CBT → Physical Endurance & Measurement Test → Medical',
     'Constable (Executive) - Male and Female',
     'https://ssc.gov.in',
     'Recruitment of Delhi Police constables through SSC. Candidates from all states can apply.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 25, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 18-25 on 1 July of the exam year');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, FALSE, 'Not linked to the Delhi domicile - open to all states');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('EX_SERVICEMAN', NULL, 3, 'ADD_AFTER_SERVICE_DEDUCTION', NULL, FALSE, 'Age minus military service must not exceed the limit by more than 3 years');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 12 pass (Class 11 for wards of Delhi Police personnel)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_ssc, TRUE, 'Indian citizens and the categories listed in the notification');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'PwBD candidates are not eligible');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, 'Race, long jump and high jump; height and chest standards');

-- ---------- Delhi Police Head Constable (Ministerial) ----------
CALL sp_seed_exam('SSC_DP_HCM', 'Head Constable (Ministerial) in Delhi Police', 'Delhi Police HC (Min)', 'SSC', 'SSC',
     'STATE', 'DL', 'GOVERNMENT', 'RECRUITMENT', 1.0, 6, 10,
     'CBT → PE&MT → Typing test → Computer formatting test',
     'Head Constable (Ministerial) - Male and Female',
     'https://ssc.gov.in',
     'Clerical Head Constable posts in Delhi Police. Typing speed (English 30 wpm or Hindi 25 wpm) is tested.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 25, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 18-25 on 1 January of the exam year');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('EX_SERVICEMAN', NULL, 3, 'ADD_AFTER_SERVICE_DEDUCTION', NULL, FALSE, 'Age minus military service must not exceed the limit by more than 3 years');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 12 pass and the typing speed in the notification');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_ssc, TRUE, 'Indian citizens and the categories listed in the notification');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, 'Physical endurance and measurement test');

-- ---------- SSC Combined Hindi Translators ----------
CALL sp_seed_exam('SSC_JHT', 'Combined Hindi Translators Examination', 'SSC JHT', 'SSC', 'SSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 6, 8,
     'Paper 1 (CBT) → Paper 2 (descriptive translation)',
     'Junior Hindi Translator, Junior Translator, Senior Hindi Translator',
     'https://ssc.gov.in',
     'Recruitment of Hindi translators for central ministries and departments.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 18-30 on the crucial date');
CALL sp_seed_relax_ssc(TRUE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'PG', 'ANY', 'HINDI|ENGLISH', NULL, NULL, NULL, FALSE, NULL, NULL,
     'Master''s degree in Hindi or English with the other language as a compulsory / elective subject at degree level (or the alternatives in the notification)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_ssc, TRUE, 'Indian citizens and the categories listed in the notification');

SELECT 'SSC exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN conducting_body b ON b.id = e.body_id WHERE b.short_name = 'SSC') AS ssc_exams;
