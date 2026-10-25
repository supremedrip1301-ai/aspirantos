-- ============================================================
-- AspirantOS - 16_seed_exams_teaching.sql
-- Teaching (23 exams): CTET, UGC NET, CSIR NET, 10 state TETs, 5 state SETs,
-- KVS, NVS, DSSSB TGT/PGT, AWES OST, BPSC TRE, UP Super TET.
-- Uses 05_seed_helpers.sql (sp_seed_tet / sp_seed_set for the similar state tests). Re-runnable.
-- REPLACE_WITH_MAX relaxations without a cap do not add up: the biggest one is used
-- (UGC NET JRF: "relaxation up to 5 years" for any one of the listed groups).
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the latest notification / information bulletin known to the developer (2025-26 cycle). Confirm with the official notification.';

CALL sp_seed_body('NVS',     'Navodaya Vidyalaya Samiti',                           'https://navodaya.gov.in',      'AUTONOMOUS');
CALL sp_seed_body('KVS',     'Kendriya Vidyalaya Sangathan',                        'https://kvsangathan.nic.in',   'AUTONOMOUS');
CALL sp_seed_body('DSSSB',   'Delhi Subordinate Services Selection Board',          'https://dsssb.delhi.gov.in',   'STATE_GOVT');
CALL sp_seed_body('AWES',    'Army Welfare Education Society',                      'https://www.awesindia.com',    'PRIVATE');
CALL sp_seed_body('UPESSC',  'UP Education Service Selection Commission / Exam Regulatory Authority', 'https://upessc.up.gov.in', 'STATE_GOVT');
CALL sp_seed_body('RBSE',    'Board of Secondary Education, Rajasthan',             'https://rajeduboard.rajasthan.gov.in', 'STATE_GOVT');
CALL sp_seed_body('MSCE',    'Maharashtra State Council of Examination',            'https://mahatet.in',           'STATE_GOVT');
CALL sp_seed_body('BSEH',    'Board of School Education Haryana',                  'https://bseh.org.in',          'STATE_GOVT');
CALL sp_seed_body('BSEB',    'Bihar School Examination Board',                      'https://biharboardonline.bihar.gov.in', 'STATE_GOVT');
CALL sp_seed_body('PSEB',    'Punjab School Education Board',                       'https://pstet.pseb.ac.in',     'STATE_GOVT');
CALL sp_seed_body('KA_SED',  'Department of School Education, Karnataka',           'https://sts.karnataka.gov.in', 'STATE_GOVT');
CALL sp_seed_body('TN_TRB',  'Teachers Recruitment Board, Tamil Nadu',              'https://www.trb.tn.gov.in',    'STATE_GOVT');
CALL sp_seed_body('AP_DSE',  'Department of School Education, Andhra Pradesh',      'https://aptet.apcfss.in',      'STATE_GOVT');
CALL sp_seed_body('TS_DSE',  'Department of School Education, Telangana',           'https://tgtet.aptonline.in',   'STATE_GOVT');
CALL sp_seed_body('SPPU',    'Savitribai Phule Pune University (MH-SET agency)',    'https://setexam.unipune.ac.in','UNIVERSITY');
CALL sp_seed_body('UOM',     'University of Mysore (KSET agency)',                  'https://kset.uni-mysore.ac.in','UNIVERSITY');
CALL sp_seed_body('TN_SET_UNIV', 'TN SET nodal university / TN TRB',                'https://www.trb.tn.gov.in',    'STATE_GOVT');
CALL sp_seed_body('WBCSC',   'West Bengal College Service Commission',              'https://wbcsconline.in',       'STATE_GOVT');
CALL sp_seed_body('LBS_KERALA', 'LBS Centre for Science & Technology, Kerala',      'https://lbsedp.lbscentre.in',  'STATE_GOVT');

-- ---------- CTET ----------
CALL sp_seed_exam('CTET', 'Central Teacher Eligibility Test', 'CTET', 'TEACHING', 'CBSE',
     'NATIONAL', NULL, 'GOVERNMENT', 'CERTIFICATION', 2.0, 5, 9,
     'Paper 1 (Classes I-V) and / or Paper 2 (Classes VI-VIII)',
     'Eligibility for teacher posts in KVS, NVS, central government and many state / private schools', 'https://ctet.nic.in',
     'Teacher eligibility test conducted by CBSE, usually twice a year. The certificate is valid for life.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1000 (one paper) / Rs 1200 (both); Rs 500 / Rs 600 for SC, ST and PwBD', 'No limit on the number of attempts.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('Paper 1 (Classes I-V)', 'CLASS_12', 'ANY', NULL, 50, 45, 'SC,ST,OBC_NCL,PWBD', TRUE, NULL, NULL, 'Class 12 with 50% (45% reserved) + 2-year D.El.Ed (final-year allowed), or B.El.Ed');
CALL sp_seed_qual('Paper 2 (Classes VI-VIII)', 'UG', 'ANY', NULL, 50, 45, 'SC,ST,OBC_NCL,PWBD', TRUE, NULL, NULL, 'Graduation with 50% (45% reserved) + B.Ed (final-year allowed), or 4-year B.A.Ed / B.Sc.Ed');
CALL sp_seed_other(NULL, 'OTHER', 'TEACHER_TRAINING', FALSE, 'A teacher-training course (D.El.Ed / B.Ed) is required');

-- ---------- UGC NET ----------
CALL sp_seed_exam('UGC_NET', 'UGC National Eligibility Test', 'UGC NET', 'TEACHING', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'CERTIFICATION', 2.0, 3, 6,
     'Single CBT: Paper 1 (teaching & research aptitude) + Paper 2 (subject)',
     'Junior Research Fellowship (JRF) and Assistant Professor; admission to PhD', 'https://ugcnet.nta.ac.in',
     'Held in June and December. JRF has an upper age limit; Assistant Professor and PhD admission have none.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1150 (General), Rs 600 (EWS/OBC-NCL), Rs 325 (SC/ST/PwBD/transgender)', 'No attempt limit.');
CALL sp_seed_age('JRF', NULL, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 12, 1, 'JRF: not more than 30 years on the 1st day of the month in which the exam ends (December 2026 cycle: 1 Dec)');
CALL sp_seed_age('Assistant Professor / PhD admission', NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No upper age limit');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'JRF: up to 5 years (not added to other relaxations)');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'JRF: up to 5 years');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'JRF: up to 5 years');
CALL sp_seed_relax('PWBD', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'JRF: up to 5 years');
CALL sp_seed_relax('WOMEN', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'JRF: women applicants up to 5 years');
CALL sp_seed_relax('TRANSGENDER', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'JRF: transgender applicants up to 5 years');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'PG', 'ANY', NULL, 55, 50, 'OBC_NCL,SC,ST,PWBD,TRANSGENDER', TRUE, NULL, NULL,
     'Master''s degree with 55% (50% for OBC-NCL/SC/ST/PwBD/transgender); final-year PG students may apply. 4-year UG with 75% may apply for JRF/PhD');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', FALSE, 'Indian nationals');

-- ---------- CSIR UGC NET ----------
CALL sp_seed_exam('CSIR_NET', 'Joint CSIR-UGC NET for JRF and Assistant Professor', 'CSIR NET', 'TEACHING', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'CERTIFICATION', 2.0, 3, 7,
     'Single CBT (Parts A, B, C)',
     'JRF and Assistant Professor in Chemical, Earth, Life, Mathematical and Physical Sciences', 'https://csirnet.nta.ac.in',
     'Science NET held twice a year. JRF has an upper age limit.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1150 (General), Rs 600 (EWS/OBC-NCL), Rs 325 (SC/ST/PwBD/transgender)', 'No attempt limit.');
CALL sp_seed_age('JRF', NULL, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 12, 1, 'JRF: not more than 30 years on the 1st day of the month in which the exam ends (December 2026 cycle: 1 Dec)');
CALL sp_seed_age('Assistant Professor / PhD admission', NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No upper age limit');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'JRF: up to 5 years');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'JRF: up to 5 years');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'JRF: up to 5 years');
CALL sp_seed_relax('PWBD', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'JRF: up to 5 years');
CALL sp_seed_relax('WOMEN', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'JRF: women applicants up to 5 years');
CALL sp_seed_relax('TRANSGENDER', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'JRF: transgender applicants up to 5 years');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'PG', 'M.Sc,Integrated BS-MS,B.Tech,B.E.,B.Pharm,MBBS', NULL, 55, 50, 'OBC_NCL,SC,ST,PWBD,TRANSGENDER', TRUE, NULL, NULL,
     'M.Sc or equivalent (integrated BS-MS, 4-year BS, B.E./B.Tech, B.Pharm, MBBS) with 55% (50% reserved); final-year students may apply');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', FALSE, 'Indian nationals');

-- ---------- State TETs ----------
CALL sp_seed_tet('UPTET',   'Uttar Pradesh Teacher Eligibility Test', 'UPTET',   'UPESSC', 'UP', 9, 1,  'https://upessc.up.gov.in', @src);
CALL sp_seed_tet('REET',    'Rajasthan Eligibility Examination for Teachers', 'REET', 'RBSE', 'RJ', 10, 2, 'https://reet2025.co.in', @src);
CALL sp_seed_tet('MAHATET', 'Maharashtra Teacher Eligibility Test', 'MAHATET', 'MSCE', 'MH', 9, 11, 'https://mahatet.in', @src);
CALL sp_seed_tet('HTET',    'Haryana Teacher Eligibility Test', 'HTET', 'BSEH', 'HR', 6, 7, 'https://bseh.org.in', @src);
CALL sp_seed_tet('BIHAR_STET', 'Bihar Special / Secondary Teacher Eligibility Test', 'Bihar STET', 'BSEB', 'BR', 4, 5, 'https://bsebstet.com', @src);
CALL sp_seed_tet('PSTET',   'Punjab State Teacher Eligibility Test', 'PSTET', 'PSEB', 'PB', 11, 12, 'https://pstet.pseb.ac.in', @src);
CALL sp_seed_tet('KARTET',  'Karnataka Teacher Eligibility Test', 'KARTET', 'KA_SED', 'KA', 5, 6, 'https://sts.karnataka.gov.in', @src);
CALL sp_seed_tet('TNTET',   'Tamil Nadu Teacher Eligibility Test', 'TNTET', 'TN_TRB', 'TN', 3, 6, 'https://www.trb.tn.gov.in', @src);
CALL sp_seed_tet('AP_TET',  'Andhra Pradesh Teacher Eligibility Test', 'AP TET', 'AP_DSE', 'AP', 7, 10, 'https://aptet.apcfss.in', @src);
CALL sp_seed_tet('TS_TET',  'Telangana Teacher Eligibility Test', 'TS TET', 'TS_DSE', 'TS', 4, 6, 'https://tgtet.aptonline.in', @src);

-- ---------- State SETs ----------
CALL sp_seed_set('MH_SET',     'Maharashtra State Eligibility Test (MH-SET)', 'MH-SET', 'SPPU', 'MH', 2, 6, 'https://setexam.unipune.ac.in', @src);
CALL sp_seed_set('KSET',       'Karnataka State Eligibility Test', 'KSET', 'UOM', 'KA', 9, 11, 'https://kset.uni-mysore.ac.in', @src);
CALL sp_seed_set('TN_SET',     'Tamil Nadu State Eligibility Test', 'TN SET', 'TN_SET_UNIV', 'TN', 2, 3, 'https://www.trb.tn.gov.in', @src);
CALL sp_seed_set('WB_SET',     'West Bengal State Eligibility Test', 'WB SET', 'WBCSC', 'WB', 8, 12, 'https://wbcsconline.in', @src);
CALL sp_seed_set('KERALA_SET', 'Kerala State Eligibility Test', 'Kerala SET', 'LBS_KERALA', 'KL', 5, 7, 'https://lbsedp.lbscentre.in', @src);

-- ---------- KVS PRT / TGT / PGT ----------
CALL sp_seed_exam('KVS_TEACHERS', 'KVS Teacher Recruitment (PRT, TGT, PGT)', 'KVS PRT/TGT/PGT', 'TEACHING', 'KVS',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 12, 2,
     'Written test (CBT) → Interview / skill test (post-wise)', 'Primary Teacher (PRT), Trained Graduate Teacher (TGT), Post Graduate Teacher (PGT)', 'https://kvsangathan.nic.in',
     'Teacher recruitment for Kendriya Vidyalayas (irregular; recent recruitments use a combined exam with NVS).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1500 (PGT/TGT/PRT); no fee for SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age('PGT', NULL, 40, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'PGT: up to 40 years on the closing date');
CALL sp_seed_age('TGT', NULL, 35, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'TGT: up to 35 years');
CALL sp_seed_age('PRT', NULL, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'PRT: up to 30 years');
CALL sp_seed_relax_central(0, 'ADD', FALSE);
CALL sp_seed_relax('WOMEN', NULL, 10, 'ADD', NULL, FALSE, 'Women: up to 10 years (as per KVS rules)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual('PGT', 'PG', 'ANY', NULL, 50, NULL, NULL, FALSE, NULL, NULL, 'PGT: Master''s degree with 50% in the subject + B.Ed');
CALL sp_seed_qual('TGT', 'UG', 'ANY', NULL, 50, NULL, NULL, FALSE, NULL, NULL, 'TGT: graduation with 50% in the subject combination + B.Ed + CTET Paper 2');
CALL sp_seed_qual('PRT', 'CLASS_12', 'ANY', NULL, 50, NULL, NULL, FALSE, NULL, NULL, 'PRT: Class 12 with 50% + D.El.Ed (or B.El.Ed) + CTET Paper 1');
CALL sp_seed_other('TGT', 'REGISTRATION', 'CTET', FALSE, 'TGT needs a CTET Paper 2 pass');
CALL sp_seed_other('PRT', 'REGISTRATION', 'CTET', FALSE, 'PRT needs a CTET Paper 1 pass');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');

-- ---------- NVS TGT / PGT ----------
CALL sp_seed_exam('NVS_TEACHERS', 'NVS Teacher Recruitment (TGT, PGT)', 'NVS TGT/PGT', 'TEACHING', 'NVS',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 12, 2,
     'Written test (CBT) → Interview', 'Trained Graduate Teacher (TGT), Post Graduate Teacher (PGT) for Jawahar Navodaya Vidyalayas', 'https://navodaya.gov.in',
     'Teacher recruitment for residential Navodaya schools (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1500 (PGT) / Rs 1500 (TGT); no fee for SC, ST and PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age('PGT', NULL, 40, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'PGT: up to 40 years');
CALL sp_seed_age('TGT', NULL, 35, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'TGT: up to 35 years');
CALL sp_seed_relax_central(0, 'ADD', FALSE);
CALL sp_seed_relax('WOMEN', NULL, 10, 'ADD', NULL, FALSE, 'Women: up to 10 years (as per NVS rules)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual('PGT', 'PG', 'ANY', NULL, 50, NULL, NULL, FALSE, NULL, NULL, 'PGT: Master''s degree with 50% + B.Ed');
CALL sp_seed_qual('TGT', 'UG', 'ANY', NULL, 50, NULL, NULL, FALSE, NULL, NULL, 'TGT: graduation with 50% + B.Ed + CTET Paper 2');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');

-- ---------- DSSSB TGT / PGT ----------
CALL sp_seed_exam('DSSSB_TEACHERS', 'DSSSB Teacher Recruitment (TGT, PGT) for Delhi Government Schools', 'DSSSB TGT/PGT', 'TEACHING', 'DSSSB',
     'STATE', 'DL', 'GOVERNMENT', 'RECRUITMENT', 1.0, 8, 11,
     'One-tier / two-tier CBT', 'TGT and PGT in Directorate of Education, Delhi (and other Delhi departments)', 'https://dsssb.delhi.gov.in',
     'Delhi government teacher recruitment. Candidates from all states may apply; reservation follows Delhi rules.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age('PGT', NULL, 36, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'PGT: up to 36 years');
CALL sp_seed_age('TGT', NULL, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'TGT: up to 32 years');
CALL sp_seed_relax_central(0, 'ADD', FALSE);
CALL sp_seed_relax('WOMEN', NULL, 10, 'ADD', NULL, FALSE, 'Women: up to 10 years for teacher posts (Delhi govt rules)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual('PGT', 'PG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'PGT: Master''s degree in the subject + B.Ed');
CALL sp_seed_qual('TGT', 'UG', 'ANY', NULL, 45, NULL, NULL, FALSE, NULL, NULL, 'TGT: graduation with 45% + B.Ed + CTET Paper 2');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN,NEPAL,BHUTAN,TIBETAN_REFUGEE,PIO', TRUE, 'Indian citizens and the categories listed in the advertisement');

-- ---------- AWES Army Public School OST ----------
CALL sp_seed_exam('AWES_OST', 'AWES Online Screening Test for Army Public Schools', 'AWES OST', 'TEACHING', 'AWES',
     'NATIONAL', NULL, 'PRIVATE', 'RECRUITMENT', 1.0, 9, 11,
     'Online Screening Test → Interview → Teaching skill evaluation (by the school)', 'PGT, TGT and PRT in 130+ Army Public Schools', 'https://www.awesindia.com',
     'Screening test for teachers of Army Public Schools. The score card is valid for 3 years.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 385', 'No attempt limit.');
CALL sp_seed_age('Fresh candidates', NULL, 40, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 4, 1, 'Fresh candidates: below 40 years on 1 April');
CALL sp_seed_age('Experienced candidates (5+ years)', NULL, 57, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 4, 1, 'Experienced (5 years in the last 10): below 57 years');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, NULL, NULL, FALSE, NULL, NULL, 'Graduation (TGT/PRT) or PG (PGT) with 50% + B.Ed with 50%; CTET/TET for PRT and TGT');
CALL sp_seed_qual('Experienced candidates (5+ years)', 'UG', 'ANY', NULL, 50, NULL, NULL, FALSE, NULL, 5.0, 'As above, plus 5 years of teaching experience in the last 10 years');

-- ---------- BPSC TRE ----------
CALL sp_seed_exam('BPSC_TRE', 'BPSC School Teacher Recruitment Exam (TRE)', 'BPSC TRE', 'TEACHING', 'BPSC',
     'STATE', 'BR', 'GOVERNMENT', 'RECRUITMENT', 1.0, 7, 9,
     'Single written exam', 'School teachers for Classes 1-5, 6-8, 9-10 and 11-12 in Bihar', 'https://bpsc.bihar.gov.in',
     'Large teacher recruitment of Bihar. Recent rounds reserve posts for Bihar domicile candidates.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 750 (Rs 200 for SC/ST/PwBD/Bihar women)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 37, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Unreserved men: 18-37 (Classes 9-12: minimum 21)');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, TRUE, 'BC/EBC of Bihar: up to 40');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, TRUE, 'SC/ST of Bihar: up to 42');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, TRUE, 'SC/ST of Bihar: up to 42');
CALL sp_seed_relax('WOMEN', NULL, 0, 'REPLACE_WITH_MAX', 40, TRUE, 'Women of Bihar: up to 40');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, 45, 'SC,ST,OBC_NCL,PWBD', FALSE, NULL, NULL, 'Graduation / PG with 50% + B.Ed / D.El.Ed and a CTET or Bihar STET pass (by class group)');
CALL sp_seed_other(NULL, 'REGISTRATION', 'CTET_OR_STET', FALSE, 'You need a CTET or Bihar TET / STET pass for the class group');
CALL sp_seed_other(NULL, 'DOMICILE', 'BR', FALSE, 'Recent rounds give most posts to Bihar domicile candidates');

-- ---------- UP Super TET ----------
CALL sp_seed_exam('UP_SUPER_TET', 'UP Assistant Teacher Recruitment Examination (Super TET)', 'UP Super TET', 'TEACHING', 'UPESSC',
     'STATE', 'UP', 'GOVERNMENT', 'RECRUITMENT', 0.5, 12, 2,
     'Single written exam → Counselling', 'Assistant Teacher in UP Basic Education Council primary schools', 'https://upessc.up.gov.in',
     'Recruitment exam for primary teachers in Uttar Pradesh; a UPTET or CTET pass is required to apply.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 600 (Rs 400 for OBC, Rs 200 for SC/ST of UP)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 40, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 21-40 on 1 July');
CALL sp_seed_relax_state(5, 5, 0, 15, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation + D.El.Ed / BTC (or as allowed) + UPTET / CTET Paper 1 pass');
CALL sp_seed_other(NULL, 'REGISTRATION', 'UPTET_OR_CTET', FALSE, 'You need a UPTET or CTET (Paper 1) pass');

SELECT 'Teaching exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'TEACHING') AS teaching_exams;
