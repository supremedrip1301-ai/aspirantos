-- ============================================================
-- AspirantOS - 13_seed_exams_banking_insurance.sql
-- Banking (18 exams) and insurance (8 exams).
-- Uses 05_seed_helpers.sql. Re-runnable.
-- Banks announce the age cut-off date in every notification; the dates below are the
-- usual ones. Percentage rules: min_percent_relaxed applies to the categories in relaxed_for.
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the latest notification known to the developer (2025-26 cycle). Confirm the cut-off date, age and percentage in the current notification.';
SET @nat_bank = 'INDIAN,NEPAL,BHUTAN,TIBETAN_REFUGEE,PIO';

CALL sp_seed_body('NABARD', 'National Bank for Agriculture and Rural Development', 'https://www.nabard.org', 'CENTRAL_GOVT');
CALL sp_seed_body('SIDBI',  'Small Industries Development Bank of India',      'https://www.sidbi.in',    'CENTRAL_GOVT');
CALL sp_seed_body('SEBI',   'Securities and Exchange Board of India',          'https://www.sebi.gov.in', 'CENTRAL_GOVT');
CALL sp_seed_body('IDBI',   'IDBI Bank',                                       'https://www.idbibank.in', 'PSU');
CALL sp_seed_body('EXIM',   'Export-Import Bank of India',                     'https://www.eximbankindia.in', 'CENTRAL_GOVT');
CALL sp_seed_body('LIC',    'Life Insurance Corporation of India',             'https://licindia.in',     'PSU');
CALL sp_seed_body('NIACL',  'The New India Assurance Co. Ltd.',                'https://www.newindia.co.in', 'PSU');
CALL sp_seed_body('UIIC',   'United India Insurance Co. Ltd.',                 'https://uiic.co.in',      'PSU');
CALL sp_seed_body('NICL',   'National Insurance Co. Ltd.',                     'https://nationalinsurance.nic.co.in', 'PSU');
CALL sp_seed_body('GIC',    'General Insurance Corporation of India (GIC Re)', 'https://www.gicre.in',    'PSU');

-- =================== BANKING ===================

-- ---------- SBI PO ----------
CALL sp_seed_exam('SBI_PO', 'SBI Probationary Officers', 'SBI PO', 'BANKING', 'SBI',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 6, 8,
     'Preliminary → Main → Psychometric test, Group exercise & Interview',
     'Probationary Officer (Junior Management Grade Scale I)', 'https://sbi.co.in/web/careers',
     'Officer recruitment of the State Bank of India. Unlike IBPS PO, SBI PO has an attempt limit.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 750; no fee for SC, ST and PwBD', 'Number of chances (2026): UR/EWS 6, UR-PwBD/EWS-PwBD/OBC 9, SC/ST no restriction; age relaxations are not cumulative.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 4, 1, 'Age 21-30 on the cut-off date (usually 1 April of the year)');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt('GEN',     FALSE, 6,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'UR: 6 chances');
CALL sp_seed_attempt('EWS',     FALSE, 6,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'EWS: 6 chances');
CALL sp_seed_attempt('GEN',     TRUE,  9,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'UR (PwBD): 9 chances');
CALL sp_seed_attempt('EWS',     TRUE,  9,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'EWS (PwBD): 9 chances');
CALL sp_seed_attempt('OBC_NCL', NULL,  9,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'OBC and OBC (PwBD): 9 chances');
CALL sp_seed_attempt('SC',      NULL,  NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'SC: no limit');
CALL sp_seed_attempt('ST',      NULL,  NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'ST: no limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation in any discipline; final-year students may apply if they pass by the date in the notification');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- SBI Clerk ----------
CALL sp_seed_exam('SBI_CLERK', 'SBI Junior Associates (Customer Support & Sales)', 'SBI Clerk', 'BANKING', 'SBI',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 8, 9,
     'Preliminary → Main → Local language test',
     'Junior Associate (Customer Support & Sales)', 'https://sbi.co.in/web/careers',
     'Clerical recruitment of SBI. Vacancies are state-wise and the local language of the state must be known.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 750; no fee for SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 20, 28, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 4, 1, 'Age 20-28 on the cut-off date (usually 1 April)');
CALL sp_seed_relax_bank_clerk();
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation in any discipline; final-year students may apply');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');
CALL sp_seed_other(NULL, 'OTHER', 'LOCAL_LANGUAGE', FALSE, 'You must read, write and speak the official language of the state you apply for');

-- ---------- SBI SO ----------
CALL sp_seed_exam('SBI_SO', 'SBI Specialist Cadre Officers', 'SBI SO', 'BANKING', 'SBI',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 2.0, 3, 5,
     'Online test or shortlisting → Interview (post-wise)',
     'Deputy Manager / Manager / Assistant Manager in IT, Security, Risk, Law, Engineering and other specialist posts',
     'https://sbi.co.in/web/careers',
     'Many separate specialist notifications every year. Age limit, degree and experience change with each post, so the values here are a typical example.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 750; no fee for SC, ST and PwBD', 'No attempt limit.');
CALL sp_seed_age('Assistant Manager level (typical)', 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 4, 1, 'Typical: 21-30; varies by post');
CALL sp_seed_age('Deputy Manager / Manager level (typical)', 25, 35, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 4, 1, 'Typical: 25-35; varies by post');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPLIED', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('Assistant Manager level (typical)', 'UG', 'B.E.,B.Tech,MCA,M.Sc', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Typical: B.E./B.Tech/MCA/M.Sc in the relevant field');
CALL sp_seed_qual('Deputy Manager / Manager level (typical)', 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, 2.0, 'Typical: relevant degree + 2 or more years of experience');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- IBPS PO ----------
CALL sp_seed_exam('IBPS_PO', 'IBPS Common Recruitment Process for Probationary Officers / Management Trainees', 'IBPS PO', 'BANKING', 'IBPS',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 7, 8,
     'Preliminary → Main → Interview',
     'Probationary Officer / Management Trainee in participating public sector banks',
     'https://www.ibps.in',
     'Common officer recruitment for public sector banks (Bank of Baroda, PNB, Canara Bank and others). No attempt limit.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 850; Rs 175 for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 20, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 20-30 on 1 July (CRP PO/MT-XVI: born 2 Jul 1996 - 1 Jul 2006)');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation in any discipline (passed by the date of registration)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- IBPS Clerk ----------
CALL sp_seed_exam('IBPS_CLERK', 'IBPS Common Recruitment Process for Customer Service Associates (Clerks)', 'IBPS Clerk', 'BANKING', 'IBPS',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 8, 10,
     'Preliminary → Main (no interview)',
     'Customer Service Associate (Clerk) in participating public sector banks',
     'https://www.ibps.in',
     'State-wise clerical recruitment for public sector banks; knowledge of the state''s official language is required.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 850; Rs 175 for SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 20, 28, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 20-28 on the cut-off date (usually 1 August)');
CALL sp_seed_relax_bank_clerk();
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation in any discipline; computer literacy');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');
CALL sp_seed_other(NULL, 'OTHER', 'LOCAL_LANGUAGE', FALSE, 'You must know the official language of the state you apply for');

-- ---------- IBPS SO ----------
CALL sp_seed_exam('IBPS_SO', 'IBPS Common Recruitment Process for Specialist Officers', 'IBPS SO', 'BANKING', 'IBPS',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 7, 8,
     'Preliminary → Main (professional knowledge) → Interview',
     'IT Officer, Agricultural Field Officer, Rajbhasha Adhikari, Law Officer, HR/Personnel Officer, Marketing Officer',
     'https://www.ibps.in',
     'Specialist officers (Scale I) for public sector banks. Each post needs a specific degree.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 850; Rs 175 for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 20, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 20-30 on the cut-off date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'B.E.,B.Tech', 'COMPUTER SCIENCE|INFORMATION TECHNOLOGY|ELECTRONICS', NULL, NULL, NULL, FALSE, NULL, NULL, 'IT Officer: 4-year engineering degree in CS / IT / Electronics (or PG in CS/IT)');
CALL sp_seed_qual(NULL, 'UG', 'B.Sc', 'AGRICULTURE|HORTICULTURE|ANIMAL HUSBANDRY|DAIRY|FISHERIES|FORESTRY', NULL, NULL, NULL, FALSE, NULL, NULL, 'Agricultural Field Officer: 4-year degree in Agriculture or allied subjects');
CALL sp_seed_qual(NULL, 'PG', 'M.A.', 'HINDI', NULL, NULL, NULL, FALSE, NULL, NULL, 'Rajbhasha Adhikari: PG in Hindi with English at graduation (or the reverse)');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Law Officer: LLB and enrolment with the Bar Council');
CALL sp_seed_qual(NULL, 'PG', 'MBA,PGDM,M.A.', 'HR|PERSONNEL|LABOUR LAW|MARKETING', NULL, NULL, NULL, FALSE, NULL, NULL, 'HR / Marketing Officer: 2-year PG degree or diploma in HR / Personnel / Marketing');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- IBPS RRB Officer Scale I ----------
CALL sp_seed_exam('IBPS_RRB_PO', 'IBPS RRB Officer Scale I (Assistant Manager)', 'IBPS RRB PO', 'BANKING', 'IBPS',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 11,
     'Preliminary → Main → Interview',
     'Officer Scale I in Regional Rural Banks', 'https://www.ibps.in',
     'Officer recruitment for the Regional Rural Banks (Gramin banks). The local language of the state is needed.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 850; Rs 175 for SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 9, 1, 'Age 18-30 on the cut-off date (usually 1 September)');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation in any discipline (preference to agriculture, horticulture, IT, law, economics, accountancy etc.)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');
CALL sp_seed_other(NULL, 'OTHER', 'LOCAL_LANGUAGE', FALSE, 'Proficiency in the local language of the RRB''s state');

-- ---------- IBPS RRB Office Assistant ----------
CALL sp_seed_exam('IBPS_RRB_CLERK', 'IBPS RRB Office Assistant (Multipurpose)', 'IBPS RRB Clerk', 'BANKING', 'IBPS',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 11,
     'Preliminary → Main (no interview)',
     'Office Assistant (Multipurpose) in Regional Rural Banks', 'https://www.ibps.in',
     'Clerical recruitment for Regional Rural Banks; local language proficiency is required.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 850; Rs 175 for SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 28, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 9, 1, 'Age 18-28 on the cut-off date (usually 1 September)');
CALL sp_seed_relax_bank_clerk();
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation in any discipline');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');
CALL sp_seed_other(NULL, 'OTHER', 'LOCAL_LANGUAGE', FALSE, 'Proficiency in the local language of the RRB''s state');

-- ---------- IBPS RRB Officer Scale II / III ----------
CALL sp_seed_exam('IBPS_RRB_SCALE2_3', 'IBPS RRB Officer Scale II and Scale III', 'IBPS RRB Scale II/III', 'BANKING', 'IBPS',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 12,
     'Single online exam → Interview',
     'Scale II General Banking / Specialist Officers; Scale III Senior Manager', 'https://www.ibps.in',
     'Experienced-officer recruitment for Regional Rural Banks.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 850; Rs 175 for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age('Officer Scale II', 21, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 9, 1, 'Age 21-32 on the cut-off date');
CALL sp_seed_age('Officer Scale III', 21, 40, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 9, 1, 'Age 21-40 on the cut-off date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual('Officer Scale II', 'UG', 'ANY', NULL, 50, NULL, NULL, FALSE, NULL, 2.0, 'Graduation with at least 50% and 2 years as an officer in a bank / financial institution');
CALL sp_seed_qual('Officer Scale III', 'UG', 'ANY', NULL, 50, NULL, NULL, FALSE, NULL, 5.0, 'Graduation with at least 50% and 5 years as an officer in a bank / financial institution');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- RBI Grade B ----------
CALL sp_seed_exam('RBI_GRADE_B', 'RBI Officers in Grade B (DR) - General, DEPR, DSIM', 'RBI Grade B', 'BANKING', 'RBI',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 7, 10,
     'Phase 1 (objective) → Phase 2 (objective + descriptive) → Interview',
     'Grade B Officer (DR) - General; Department of Economic & Policy Research (DEPR); Department of Statistics & Information Management (DSIM)',
     'https://opportunities.rbi.org.in',
     'Direct-recruit officers of the Reserve Bank of India. General-category candidates have an attempt limit for the General stream.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 850; Rs 100 for SC, ST and PwBD', 'Appearing in Phase 1 counts as an attempt; the limit applies to General-category candidates.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 21-30 on the cut-off date in the notification (approximated as 1 July)');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt('GEN', NULL, 6, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'General category: maximum 6 attempts (Grade B DR - General)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'Other categories: no limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 60, 50, 'SC,ST,PWBD', FALSE, NULL, NULL, 'General stream: graduation with 60% (50% for SC/ST/PwBD) in aggregate of all semesters / years');
CALL sp_seed_qual(NULL, 'PG', 'ANY', NULL, 55, NULL, NULL, FALSE, NULL, NULL, 'General stream: or post-graduation with 55% (pass marks for SC/ST/PwBD)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- RBI Assistant ----------
CALL sp_seed_exam('RBI_ASSISTANT', 'RBI Assistant', 'RBI Assistant', 'BANKING', 'RBI',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 12,
     'Preliminary → Main → Language Proficiency Test',
     'Assistant in RBI offices (state-wise vacancies)', 'https://opportunities.rbi.org.in',
     'Clerical recruitment of the Reserve Bank; the language of the state is tested.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 450; Rs 50 for SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 20, 28, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 9, 1, 'Age 20-28 on the cut-off date (usually 1 September)');
CALL sp_seed_relax_bank_clerk();
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, 0, 'SC,ST,PWBD', FALSE, NULL, NULL, 'Graduation with 50% (pass class for SC/ST/PwBD/ex-servicemen) and computer knowledge');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');
CALL sp_seed_other(NULL, 'OTHER', 'LOCAL_LANGUAGE', FALSE, 'Language Proficiency Test in the official language of the state');

-- ---------- RBI Office Attendant ----------
CALL sp_seed_exam('RBI_OFFICE_ATTENDANT', 'RBI Office Attendant', 'RBI Office Attendant', 'BANKING', 'RBI',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 2, 3,
     'Online test → Language Proficiency Test',
     'Office Attendant in RBI offices', 'https://opportunities.rbi.org.in',
     'Class 10 level recruitment. Graduates are NOT eligible for this post.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 450; Rs 50 for SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 25, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 2, 1, 'Age 18-25 on the cut-off date');
CALL sp_seed_relax_bank_clerk();
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 10 pass from the state of the vacancy');
CALL sp_seed_other(NULL, 'OTHER', 'NOT_GRADUATE', TRUE, 'Graduates (and higher) are not eligible');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- NABARD Grade A ----------
CALL sp_seed_exam('NABARD_GRADE_A', 'NABARD Assistant Manager Grade A (RDBS / Rajbhasha / Legal)', 'NABARD Grade A', 'BANKING', 'NABARD',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 7, 9,
     'Phase 1 → Phase 2 → Interview',
     'Assistant Manager Grade A - Rural Development Banking Service (General and specialist disciplines), Rajbhasha, Legal',
     'https://www.nabard.org',
     'Officer recruitment of NABARD; many specialist disciplines (agriculture, finance, IT, engineering).',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 800; Rs 150 for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 21-30 on the cut-off date (approximated as 1 July)');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 60, 55, 'SC,ST,PWBD', FALSE, NULL, NULL, 'RDBS General: graduation with 60% (55% SC/ST/PwBD)');
CALL sp_seed_qual(NULL, 'PG', 'ANY', NULL, 55, 50, 'SC,ST,PWBD', FALSE, NULL, NULL, 'RDBS General: or post-graduation with 55% (50% SC/ST/PwBD), or MBA/PGDM 55%');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- NABARD Development Assistant ----------
CALL sp_seed_exam('NABARD_DA', 'NABARD Development Assistant / Development Assistant (Hindi)', 'NABARD DA', 'BANKING', 'NABARD',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 1, 2,
     'Preliminary → Main → Language Proficiency Test',
     'Development Assistant; Development Assistant (Hindi)', 'https://www.nabard.org',
     'Group B staff recruitment of NABARD (irregular).',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 450; Rs 50 for SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 35, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-35 on the cut-off date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, 0, 'SC,ST,PWBD', FALSE, NULL, NULL, 'Graduation with 50% (pass class for SC/ST/PwBD/ex-servicemen)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- SIDBI Grade A ----------
CALL sp_seed_exam('SIDBI_GRADE_A', 'SIDBI Assistant Manager Grade A (General Stream)', 'SIDBI Grade A', 'BANKING', 'SIDBI',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 7, 8,
     'Phase 1 → Phase 2 → Interview', 'Assistant Manager Grade A (General / Legal / IT)',
     'https://www.sidbi.in',
     'Officer recruitment of the Small Industries Development Bank of India.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1100; Rs 175 for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 21-30 on the cut-off date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 60, 55, 'SC,ST,PWBD', FALSE, NULL, NULL, 'Graduation with 60% (55% SC/ST/PwBD), or CA / CS / CMA / CFA, or MBA / PGDM, or a degree in Law or Engineering');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- SEBI Grade A ----------
CALL sp_seed_exam('SEBI_GRADE_A', 'SEBI Officer Grade A (Assistant Manager)', 'SEBI Grade A', 'BANKING', 'SEBI',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 7, 9,
     'Phase 1 → Phase 2 → Interview', 'Assistant Manager - General, Legal, IT, Research, Official Language, Engineering',
     'https://www.sebi.gov.in',
     'Officer recruitment of the capital-market regulator.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1000; Rs 100 for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, NULL, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 3, 31, 'Not more than 30 years on the cut-off date (approximated as 31 March)');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'PG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'General stream: Master''s degree or 2-year PG diploma in any discipline');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'General stream: or a Bachelor''s degree in Law');
CALL sp_seed_qual(NULL, 'PROFESSIONAL', 'CA,CS,CMA,CFA', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'General stream: or CA / CS / CMA / CFA');
CALL sp_seed_qual(NULL, 'UG', 'B.E.,B.Tech', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'General stream: or a Bachelor''s degree in Engineering');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- IDBI Junior Assistant Manager ----------
CALL sp_seed_exam('IDBI_JAM', 'IDBI Bank Junior Assistant Manager (PGDBF)', 'IDBI JAM', 'BANKING', 'IDBI',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 5, 6,
     'Online test → Personal interview → PGDBF course', 'Junior Assistant Manager (Grade O) through the PG Diploma in Banking & Finance',
     'https://www.idbibank.in',
     'Entry-level officers selected through a one-year banking diploma.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1050; Rs 250 for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 20, 25, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 3, 1, 'Age 20-25 on the cut-off date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 60, 55, 'SC,ST,PWBD', FALSE, NULL, NULL, 'Graduation with 60% (55% SC/ST/PwBD)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- EXIM Bank Management Trainee ----------
CALL sp_seed_exam('EXIM_MT', 'EXIM Bank Management Trainee', 'EXIM Bank MT', 'BANKING', 'EXIM',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 3, 4,
     'Online test → Interview', 'Management Trainee (Banking Operations, Digital Technology, Research, Legal)',
     'https://www.eximbankindia.in',
     'Officer recruitment of the Export-Import Bank of India.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 600; Rs 100 for SC, ST, PwBD, EWS and women', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 28, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 3, 1, 'Age 21-28 on the cut-off date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'PG', 'MBA,PGDM,PGDBA', 'FINANCE|INTERNATIONAL BUSINESS|FOREIGN TRADE|BANKING', 60, NULL, NULL, TRUE, NULL, NULL, 'Banking Operations: graduation and MBA/PGDBA with Finance / International Business / Foreign Trade, 60%');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- =================== INSURANCE ===================

-- ---------- LIC AAO ----------
CALL sp_seed_exam('LIC_AAO', 'LIC Assistant Administrative Officer (Generalist)', 'LIC AAO', 'INSURANCE', 'LIC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 8, 10,
     'Preliminary → Main → Interview → Medical', 'Assistant Administrative Officer (Generalist and specialist)',
     'https://licindia.in/careers',
     'Officer recruitment of the Life Insurance Corporation of India.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 700; Rs 85 for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 21-30 on the cut-off date (usually 1 August)');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Generalist: Bachelor''s degree in any discipline');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- LIC ADO ----------
CALL sp_seed_exam('LIC_ADO', 'LIC Apprentice Development Officer', 'LIC ADO', 'INSURANCE', 'LIC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 1, 3,
     'Preliminary → Main → Interview', 'Apprentice Development Officer (zone-wise)',
     'https://licindia.in/careers',
     'Development officer recruitment of LIC (irregular, zone-wise).',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 750; Rs 100 for SC and ST', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-30 on the cut-off date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Bachelor''s degree in any discipline');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- LIC Assistant ----------
CALL sp_seed_exam('LIC_ASSISTANT', 'LIC Assistant', 'LIC Assistant', 'INSURANCE', 'LIC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 9, 10,
     'Preliminary → Main → Language test', 'Assistant (clerical cadre)', 'https://licindia.in/careers',
     'Clerical recruitment of LIC (irregular).',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 700; Rs 85 for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 9, 1, 'Age 18-30 on the cut-off date');
CALL sp_seed_relax_bank_clerk();
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Bachelor''s degree in any discipline');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- NIACL AO ----------
CALL sp_seed_exam('NIACL_AO', 'New India Assurance Administrative Officer (Scale I)', 'NIACL AO', 'INSURANCE', 'NIACL',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 9,
     'Preliminary → Main → Interview', 'Administrative Officer (Generalist and specialist)', 'https://www.newindia.co.in',
     'Officer recruitment of the largest public sector general insurer.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 850; Rs 100 for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 9, 1, 'Age 21-30 on the cut-off date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 60, 55, 'SC,ST,PWBD', FALSE, NULL, NULL, 'Generalist: graduation or PG with 60% (55% SC/ST/PwBD)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- NIACL Assistant ----------
CALL sp_seed_exam('NIACL_ASSISTANT', 'New India Assurance Assistant', 'NIACL Assistant', 'INSURANCE', 'NIACL',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 12, 1,
     'Preliminary → Main → Regional Language Test', 'Assistant (state-wise)', 'https://www.newindia.co.in',
     'Clerical recruitment; the regional language of the state is tested.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 850; Rs 100 for SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 12, 1, 'Age 21-30 on the cut-off date');
CALL sp_seed_relax_bank_clerk();
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Bachelor''s degree in any discipline');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');
CALL sp_seed_other(NULL, 'OTHER', 'LOCAL_LANGUAGE', FALSE, 'Must read, write and speak the regional language of the state');

-- ---------- UIIC AO ----------
CALL sp_seed_exam('UIIC_AO', 'United India Insurance Administrative Officer (Scale I)', 'UIIC AO', 'INSURANCE', 'UIIC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 1, 3,
     'Online exam → Interview', 'Administrative Officer (Generalist and specialist)', 'https://uiic.co.in',
     'Officer recruitment of United India Insurance (irregular).',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1000; Rs 250 for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-30 on the cut-off date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 60, 55, 'SC,ST,PWBD', FALSE, NULL, NULL, 'Generalist: graduation with 60% (55% SC/ST/PwBD)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- NICL AO ----------
CALL sp_seed_exam('NICL_AO', 'National Insurance Administrative Officer (Scale I)', 'NICL AO', 'INSURANCE', 'NICL',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 1, 3,
     'Preliminary → Main → Interview', 'Administrative Officer (Generalist and specialist)', 'https://nationalinsurance.nic.co.in',
     'Officer recruitment of National Insurance Company (irregular).',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1000; Rs 250 for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-30 on the cut-off date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 60, 55, 'SC,ST,PWBD', FALSE, NULL, NULL, 'Generalist: graduation with 60% (55% SC/ST/PwBD)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- GIC Assistant Manager ----------
CALL sp_seed_exam('GIC_AM', 'GIC Re Assistant Manager (Scale I)', 'GIC Assistant Manager', 'INSURANCE', 'GIC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 12, 1,
     'Online exam → Group discussion → Interview', 'Assistant Manager (Scale I) - Generalist, Legal, Actuarial, IT, Finance',
     'https://www.gicre.in',
     'Officer recruitment of the national reinsurer (irregular).',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1000; no fee for SC, ST, PwBD and women', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 11, 1, 'Age 21-30 on the cut-off date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 60, 55, 'SC,ST,PWBD', FALSE, NULL, NULL, 'Generalist: graduation with 60% (55% SC/ST/PwBD)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_bank, TRUE, 'Indian citizens and the categories listed in the notification');

SELECT 'Banking and insurance exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'BANKING')   AS banking_exams,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'INSURANCE') AS insurance_exams;
