-- ============================================================
-- AspirantOS - 14_seed_exams_railways_defence_police.sql
-- Railways (10 exams), Defence (13 exams; NDA and CDS are in 11_seed_exams_upsc.sql)
-- and Police & CAPF (9 exams). Uses 05_seed_helpers.sql. Re-runnable.
-- Defence entries mostly use a date-of-birth window (sp_seed_age_window): born on/after
-- (Y + from_offset)-from_month-from_day and on/before (Y + to_offset)-to_month-to_day.
-- Gender-specific age limits (UP / Rajasthan police) are separate post groups with a
-- GENDER rule for each group.
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the latest notification known to the developer (2025-26 cycle). Confirm with the current notification / CEN.';
SET @nat_gov = 'INDIAN,NEPAL,BHUTAN,TIBETAN_REFUGEE,PIO';

CALL sp_seed_body('UPPRPB', 'Uttar Pradesh Police Recruitment and Promotion Board', 'https://uppbpb.gov.in', 'STATE_GOVT');
CALL sp_seed_body('CSBC',   'Central Selection Board of Constable, Bihar',        'https://csbc.bihar.gov.in', 'STATE_GOVT');
CALL sp_seed_body('RJ_POLICE', 'Rajasthan Police (Police Headquarters, Jaipur)',  'https://police.rajasthan.gov.in', 'STATE_GOVT');
CALL sp_seed_body('MH_POLICE', 'Maharashtra Police',                              'https://www.mahapolice.gov.in', 'STATE_GOVT');
CALL sp_seed_body('MHA',    'Ministry of Home Affairs (Intelligence Bureau, CAPF)', 'https://www.mha.gov.in', 'CENTRAL_GOVT');

-- =================== RAILWAYS ===================
-- RRB: age on 1 January of the CEN year; OBC +3, SC/ST +5, PwBD +10, ex-servicemen service+3,
-- widows/divorced women up to 35/38/40 (sp_seed_relax_ssc(FALSE, TRUE)).

CALL sp_seed_exam('RRB_NTPC_GRAD', 'RRB Non-Technical Popular Categories (Graduate Level)', 'RRB NTPC Graduate', 'RAILWAYS', 'RRB',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 3,
     'CBT 1 → CBT 2 → Typing skill test / Aptitude test → Document verification',
     'Station Master, Goods Train Manager, Chief Commercial cum Ticket Supervisor, Junior Accounts Assistant cum Typist, Senior Clerk cum Typist',
     'https://indianrailways.gov.in/railwayboard/view_section.jsp?id=0,7,1281',
     'Graduate-level non-technical posts in Indian Railways through the Railway Recruitment Boards.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 400 refunded after CBT 1); Rs 250 for SC, ST, PwBD, women, ex-servicemen (refunded)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 33, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 18-33 on 1 January of the CEN year');
CALL sp_seed_relax_ssc(FALSE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation in any discipline (typing proficiency for typist posts)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_gov, TRUE, 'Indian citizens and the categories listed in the CEN');

CALL sp_seed_exam('RRB_NTPC_UG', 'RRB Non-Technical Popular Categories (Undergraduate Level)', 'RRB NTPC 12th Level', 'RAILWAYS', 'RRB',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 3,
     'CBT 1 → CBT 2 → Typing skill test → Document verification',
     'Commercial cum Ticket Clerk, Accounts Clerk cum Typist, Junior Clerk cum Typist, Trains Clerk',
     'https://indianrailways.gov.in/railwayboard/view_section.jsp?id=0,7,1281',
     'Class 12 level non-technical posts in Indian Railways.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 400 refunded after CBT 1); Rs 250 for SC, ST, PwBD, women, ex-servicemen (refunded)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 18-30 on 1 January of the CEN year');
CALL sp_seed_relax_ssc(FALSE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, 50, 0, 'SC,ST,PWBD', FALSE, NULL, NULL, 'Class 12 with 50% marks (not needed for SC/ST/PwBD/ex-servicemen)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_gov, TRUE, 'Indian citizens and the categories listed in the CEN');

CALL sp_seed_exam('RRB_GROUP_D', 'RRB Level 1 (Group D) Posts', 'RRB Group D', 'RAILWAYS', 'RRB',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 1, 11,
     'CBT → Physical Efficiency Test → Document verification → Medical',
     'Track Maintainer Gr IV, Helper / Assistant (Electrical, Mechanical, S&T), Assistant Pointsman and other Level 1 posts',
     'https://indianrailways.gov.in/railwayboard/view_section.jsp?id=0,7,1281',
     'The largest railway recruitment at Class 10 / ITI level.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 400 refunded after CBT); Rs 250 for SC, ST, PwBD, women, ex-servicemen (refunded)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 33, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 18-33 on 1 January of the CEN year');
CALL sp_seed_relax_ssc(FALSE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 10 pass or ITI (or National Apprenticeship Certificate)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_gov, TRUE, 'Indian citizens and the categories listed in the CEN');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, 'PET: lift and carry 35 kg for 100 m and run 1 km (men); 20 kg and 1 km (women)');

CALL sp_seed_exam('RRB_ALP', 'RRB Assistant Loco Pilot', 'RRB ALP', 'RAILWAYS', 'RRB',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 4, 11,
     'CBT 1 → CBT 2 → Computer Based Aptitude Test → Document verification → Medical (A-1)',
     'Assistant Loco Pilot', 'https://indianrailways.gov.in/railwayboard/view_section.jsp?id=0,7,1281',
     'Technical recruitment of assistant loco pilots; needs ITI or an engineering diploma/degree and strict eyesight standards.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 400 refunded after CBT 1); Rs 250 for SC, ST, PwBD, women, ex-servicemen (refunded)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 18-30 on the date in the CEN (approximated as 1 July)');
CALL sp_seed_relax_ssc(FALSE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', 'ITI', NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 10 + ITI in a listed trade (Fitter, Electrician, Mechanic and others)');
CALL sp_seed_qual(NULL, 'DIPLOMA', 'ANY', 'MECHANICAL|ELECTRICAL|ELECTRONICS|AUTOMOBILE', NULL, NULL, NULL, FALSE, NULL, NULL, 'Or a diploma / degree in Mechanical, Electrical, Electronics or Automobile Engineering');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_gov, TRUE, 'Indian citizens and the categories listed in the CEN');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'Safety post with medical standard A-1: PwBD candidates are not eligible');

CALL sp_seed_exam('RRB_JE', 'RRB Junior Engineer, Depot Material Superintendent and Chemical & Metallurgical Assistant', 'RRB JE', 'RAILWAYS', 'RRB',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 7, 12,
     'CBT 1 → CBT 2 → Document verification → Medical',
     'Junior Engineer (Civil, Mechanical, Electrical, Electronics, IT), DMS, CMA',
     'https://indianrailways.gov.in/railwayboard/view_section.jsp?id=0,7,1281',
     'Technical supervisor posts for diploma and degree engineers.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 400 refunded after CBT 1); Rs 250 for SC, ST, PwBD, women, ex-servicemen (refunded)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 33, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 18-33 on 1 January of the CEN year');
CALL sp_seed_relax_ssc(FALSE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'DIPLOMA', 'ANY', 'CIVIL|MECHANICAL|ELECTRICAL|ELECTRONICS|COMPUTER SCIENCE|INFORMATION TECHNOLOGY', NULL, NULL, NULL, FALSE, NULL, NULL,
     'Diploma or degree in the relevant engineering branch (B.Sc Physics & Chemistry for CMA)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_gov, TRUE, 'Indian citizens and the categories listed in the CEN');

CALL sp_seed_exam('RRB_TECHNICIAN', 'RRB Technician Grade I (Signal) and Grade III', 'RRB Technician', 'RAILWAYS', 'RRB',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 6, 12,
     'CBT → Document verification → Medical', 'Technician Grade I Signal; Technician Grade III (many trades)',
     'https://indianrailways.gov.in/railwayboard/view_section.jsp?id=0,7,1281',
     'Technician posts in railway workshops and signal departments.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 400 refunded); Rs 250 for SC, ST, PwBD, women, ex-servicemen (refunded)', 'No attempt limit within the age limit.');
CALL sp_seed_age('Technician Grade I Signal', 18, 33, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 18-33 on the date in the CEN');
CALL sp_seed_age('Technician Grade III', 18, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 18-30 on the date in the CEN');
CALL sp_seed_relax_ssc(FALSE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual('Technician Grade I Signal', 'UG', 'B.Sc,B.E.,B.Tech', 'PHYSICS|ELECTRONICS|COMPUTER SCIENCE|INFORMATION TECHNOLOGY|INSTRUMENTATION', NULL, NULL, NULL, FALSE, NULL, NULL, 'B.Sc in Physics / Electronics / CS / IT / Instrumentation, or a diploma/degree in those engineering branches');
CALL sp_seed_qual('Technician Grade I Signal', 'DIPLOMA', 'ANY', 'ELECTRONICS|ELECTRICAL|COMPUTER SCIENCE|INSTRUMENTATION', NULL, NULL, NULL, FALSE, NULL, NULL, 'Or a diploma in those engineering branches');
CALL sp_seed_qual('Technician Grade III', 'CLASS_10', 'ANY', 'ITI', NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 10 + ITI (or Course Completed Act Apprenticeship) in the relevant trade');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_gov, TRUE, 'Indian citizens and the categories listed in the CEN');

CALL sp_seed_exam('RRB_PARAMEDICAL', 'RRB Paramedical Categories', 'RRB Paramedical', 'RAILWAYS', 'RRB',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 8, 9,
     'CBT → Document verification → Medical', 'Nursing Superintendent, Pharmacist, Lab Assistant, Radiographer, ECG Technician, Health & Malaria Inspector and others',
     'https://indianrailways.gov.in/railwayboard/view_section.jsp?id=0,7,1281',
     'Medical and paramedical staff for railway hospitals. Age and qualification differ by post.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 400 refunded); Rs 250 for SC, ST, PwBD, women, ex-servicemen (refunded)', 'No attempt limit within the age limit.');
CALL sp_seed_age('Nursing Superintendent', 20, 40, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 20-40');
CALL sp_seed_age('Pharmacist / Radiographer / Lab and other posts', 18, 33, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Typical 18-33 (varies by post)');
CALL sp_seed_relax_ssc(FALSE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual('Nursing Superintendent', 'UG', 'B.Sc Nursing,GNM', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Registered Nurse & Midwife with GNM or B.Sc Nursing');
CALL sp_seed_qual('Pharmacist / Radiographer / Lab and other posts', 'DIPLOMA', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Diploma / degree in the relevant paramedical field (D.Pharm, radiography, lab technology ...)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_gov, TRUE, 'Indian citizens and the categories listed in the CEN');

CALL sp_seed_exam('RRB_MINISTERIAL', 'RRB Ministerial and Isolated Categories', 'RRB Ministerial & Isolated', 'RAILWAYS', 'RRB',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 1, 3,
     'CBT → Skill / translation / performance test → Document verification',
     'Junior Stenographer, Chief Law Assistant, Public Prosecutor, Junior Translator Hindi, Teachers (PGT/TGT/PRT), Staff & Welfare Inspector, Lab Assistant and others',
     'https://indianrailways.gov.in/railwayboard/view_section.jsp?id=0,7,1281',
     'Many small specialised posts; age limit and qualification differ by post.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 400 refunded); Rs 250 for SC, ST, PwBD, women, ex-servicemen (refunded)', 'No attempt limit within the age limit.');
CALL sp_seed_age('Graduate / PG level posts (typical)', 18, 33, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Typical 18-33 (some posts up to 48)');
CALL sp_seed_age('Class 12 level posts (typical)', 18, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Typical 18-30');
CALL sp_seed_relax_ssc(FALSE, TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual('Graduate / PG level posts (typical)', 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Degree / PG / B.Ed / LLB as per the post');
CALL sp_seed_qual('Class 12 level posts (typical)', 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 12 (+ stenography for Junior Stenographer)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_gov, TRUE, 'Indian citizens and the categories listed in the CEN');

CALL sp_seed_exam('RPF_CONSTABLE', 'RPF / RPSF Constable (Executive)', 'RPF Constable', 'RAILWAYS', 'RRB',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 4, 3,
     'CBT → PET / PMT → Document verification', 'Constable (Executive) in the Railway Protection Force and RPSF',
     'https://rpf.indianrailways.gov.in',
     'Police force of Indian Railways. 15% of the posts are reserved for women. Irregular recruitment.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 400 refunded); Rs 250 for SC, ST, women, ex-servicemen, minorities, EBC (refunded)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 28, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 18-28 on the date in the CEN');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('EX_SERVICEMAN', NULL, 3, 'ADD_AFTER_SERVICE_DEDUCTION', NULL, FALSE, 'Age minus military service must not exceed the limit by more than 3 years');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 10 pass');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_gov, TRUE, 'Indian citizens and the categories listed in the CEN');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'PwBD candidates are not eligible');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, '1600 m run (men) / 800 m (women), long jump and high jump; height and chest standards');

CALL sp_seed_exam('RPF_SI', 'RPF Sub-Inspector (Executive)', 'RPF SI', 'RAILWAYS', 'RRB',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 4, 12,
     'CBT → PET / PMT → Document verification', 'Sub-Inspector (Executive) in RPF',
     'https://rpf.indianrailways.gov.in',
     'Graduate-level police officers of Indian Railways (irregular).',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 400 refunded); Rs 250 for SC, ST, women, ex-servicemen, minorities, EBC (refunded)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 20, 28, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 20-28 on the date in the CEN');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('EX_SERVICEMAN', NULL, 3, 'ADD_AFTER_SERVICE_DEDUCTION', NULL, FALSE, 'Age minus military service must not exceed the limit by more than 3 years');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Bachelor''s degree in any discipline');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_gov, TRUE, 'Indian citizens and the categories listed in the CEN');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'PwBD candidates are not eligible');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, '1600 m run (men) / 800 m (women), long jump and high jump; height and chest standards');

-- =================== DEFENCE ===================
-- No category relaxation for officer entries unless stated. Unmarried rules are blocking.

CALL sp_seed_exam('AFCAT', 'Air Force Common Admission Test', 'AFCAT', 'DEFENCE', 'IAF',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 2.0, 12, 2,
     'Online test (+ EKT for technical) → AFSB interview → Medical',
     'Flying Branch (SSC); Ground Duty Technical; Ground Duty Non-Technical (Permanent and Short Service)',
     'https://afcat.cdac.in',
     'Officer entry of the Indian Air Force, held twice a year (February and August). Men and women can apply.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 550 + GST', 'No attempt limit; two sittings every year.');
CALL sp_seed_age_window('Flying Branch', 20, 24, -23, 1, 2, -19, 1, 1, 'Flying: born between 2 Jan (year-23) and 1 Jan (year-19); up to 26 for DGCA CPL holders');
CALL sp_seed_age_window('Ground Duty (Technical / Non-Technical)', 20, 26, -25, 1, 2, -19, 1, 1, 'Ground duty: born between 2 Jan (year-25) and 1 Jan (year-19)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('Flying Branch', 'UG', 'ANY', 'CLASS_12:PHYSICS,MATHS', 60, NULL, NULL, TRUE, NULL, NULL, 'Flying: graduation with 60% and Physics & Maths at Class 12 (50% each), or B.E./B.Tech with 60%');
CALL sp_seed_qual('Flying Branch', 'UG', 'B.E.,B.Tech', NULL, 60, NULL, NULL, TRUE, NULL, NULL, 'Flying: or B.E./B.Tech with 60%');
CALL sp_seed_qual('Ground Duty (Technical / Non-Technical)', 'UG', 'ANY', NULL, 60, NULL, NULL, TRUE, NULL, NULL, 'Ground duty non-technical: graduation with 60%; technical branches need B.E./B.Tech');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED', TRUE, 'Candidates below 25 must be unmarried at the start of the course');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');

CALL sp_seed_exam('AGNIVEER_ARMY', 'Agniveer (Army) Common Entrance Exam', 'Agniveer Army', 'DEFENCE', 'ARMY',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 2, 6,
     'Online CEE → Recruitment rally (physical + medical)',
     'Agniveer General Duty, Technical, Clerk / Store Keeper Technical, Tradesman (4-year Agnipath service)',
     'https://joinindianarmy.nic.in',
     'Four-year service under the Agnipath scheme; 25% may be retained as regular soldiers.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 250', 'No attempt limit within the age window.');
CALL sp_seed_age_window(NULL, 17, 21, -21, 10, 1, -17, 4, 1, 'Born between 1 Oct (year-21) and 1 Apr (year-17) - age 17.5 to 21');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('Agniveer GD', 'CLASS_10', 'ANY', NULL, 45, NULL, NULL, FALSE, NULL, NULL, 'GD: Class 10 with 45% aggregate and 33% in each subject');
CALL sp_seed_qual('Agniveer Technical', 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,MATHS,ENGLISH', 50, NULL, NULL, FALSE, NULL, NULL, 'Technical: Class 12 Science with PCM and English, 50% aggregate');
CALL sp_seed_qual('Agniveer Clerk / SKT', 'CLASS_12', 'ANY', NULL, 60, NULL, NULL, FALSE, NULL, NULL, 'Clerk / Store Keeper: Class 12 any stream with 60% aggregate');
CALL sp_seed_qual('Agniveer Tradesman', 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Tradesman: Class 8 or Class 10 pass (by trade)');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED', TRUE, 'Unmarried candidates only; must not marry during the 4-year engagement');
CALL sp_seed_other(NULL, 'GENDER', 'MALE', TRUE, 'Men (women can apply for Agniveer Women Military Police)');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN,NEPAL', TRUE, 'Indian citizens (Nepal domiciled Gorkhas for Gorkha regiments)');

CALL sp_seed_exam('AGNIVEER_NAVY', 'Agniveer (Navy) SSR and MR', 'Agniveer Navy', 'DEFENCE', 'NAVY',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 2.0, 3, 5,
     'Online exam (INET) → PFT + written → Medical',
     'Agniveer Senior Secondary Recruit (SSR); Agniveer Matric Recruit (MR)',
     'https://www.joinindiannavy.gov.in',
     'Four-year Agnipath service in the Navy; two batches a year. Men and women can apply.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 550 + GST', 'No attempt limit within the age window.');
CALL sp_seed_age_window(NULL, 17, 21, -21, 9, 1, -17, 2, 28, 'Born between 1 Sep (year-21) and 28 Feb (year-17), approximately; batch-specific');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,MATHS,CHEMISTRY|BIOLOGY|COMPUTER SCIENCE', 50, NULL, NULL, FALSE, NULL, NULL, 'SSR: Class 12 with Maths and Physics + one of Chemistry / Biology / Computer Science, 50%');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'MR: Class 10 pass');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED', TRUE, 'Unmarried candidates only');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');

CALL sp_seed_exam('AGNIVEERVAYU', 'Agniveervayu Intake (Indian Air Force)', 'Agniveervayu', 'DEFENCE', 'IAF',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 2.0, 1, 3,
     'Online test → Physical fitness + adaptability tests → Medical',
     'Agniveervayu Science and Non-Science subjects (4-year Agnipath service)',
     'https://agnipathvayu.cdac.in',
     'Airmen intake under the Agnipath scheme; two intakes a year. Men and women can apply.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 550 + GST', 'No attempt limit within the age window.');
CALL sp_seed_age_window(NULL, 17, 21, -21, 7, 1, -17, 1, 1, 'Born between 1 Jul (year-21) and 1 Jan (year-17), approximately; intake-specific');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,MATHS,ENGLISH', 50, NULL, NULL, TRUE, NULL, NULL, 'Science: Class 12 with Maths, Physics and English, 50% aggregate and 50% in English (or a 3-year engineering diploma)');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'ENGLISH', 50, NULL, NULL, TRUE, NULL, NULL, 'Non-science: Class 12 in any stream with 50% aggregate and 50% in English');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED', TRUE, 'Unmarried candidates only');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN,NEPAL', TRUE, 'Indian citizens and subjects of Nepal');

CALL sp_seed_exam('ICG_NAVIK_YANTRIK', 'Indian Coast Guard Navik (GD / DB) and Yantrik', 'ICG Navik / Yantrik', 'DEFENCE', 'ICG',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 2.0, 2, 4,
     'Stage I CBT → Stage II assessment + PFT → Stage III medical → Stage IV document verification',
     'Navik General Duty; Navik Domestic Branch; Yantrik (Mechanical, Electrical, Electronics)',
     'https://joinindiancoastguard.cdac.in',
     'Enrolled personnel of the Indian Coast Guard; two batches a year.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 300; no fee for SC and ST', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 22, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 18-22 (the notification gives an exact birth-date window per batch)');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,MATHS', NULL, NULL, NULL, FALSE, NULL, NULL, 'Navik GD: Class 12 with Maths and Physics');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Navik DB: Class 10; Yantrik: Class 10 + 2/3-year engineering diploma');
CALL sp_seed_other(NULL, 'GENDER', 'MALE', TRUE, 'Men only');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'PwBD candidates are not eligible');

CALL sp_seed_exam('ICG_ASST_COMMANDANT', 'Indian Coast Guard Assistant Commandant', 'ICG Assistant Commandant', 'DEFENCE', 'ICG',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 2.0, 12, 2,
     'CGCAT → Preliminary selection board → Final selection board → Medical',
     'Assistant Commandant General Duty and Technical (Engineering / Electrical)',
     'https://joinindiancoastguard.cdac.in',
     'Officer entry of the Indian Coast Guard; two batches a year.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 300; no fee for SC and ST', 'No attempt limit within the age limit.');
CALL sp_seed_age_window(NULL, 21, 25, -24, 7, 1, -20, 6, 30, 'Born between 1 Jul (year-24) and 30 Jun (year-20), approximately (21-25 years)');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, FALSE, 'Moves the "born on or after" date earlier');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, FALSE, 'Moves the "born on or after" date earlier');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, FALSE, 'Moves the "born on or after" date earlier');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', 'CLASS_12:PHYSICS,MATHS', 60, NULL, NULL, TRUE, NULL, NULL, 'GD: degree with 60% and Maths & Physics up to Class 12 (55% for Class 12)');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'PwBD candidates are not eligible');

CALL sp_seed_exam('ARMY_TES', 'Army 10+2 Technical Entry Scheme', 'Army TES', 'DEFENCE', 'ARMY',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 2.0, 5, 8,
     'Shortlisting on JEE Main score → SSB interview → Medical',
     'Permanent commission through 4-year engineering training (Corps of Engineers, Signals, EME)',
     'https://joinindianarmy.nic.in',
     'Class 12 PCM students with a JEE Main score are shortlisted for SSB. Two courses a year.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('No application fee', 'No attempt limit within the age window.');
CALL sp_seed_age_window(NULL, 16, 19, -19, 7, 2, -16, 7, 1, 'Born between 2 Jul (year-19) and 1 Jul (year-16) for the January course, approximately (16.5-19.5)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,MATHS', 60, NULL, NULL, FALSE, NULL, NULL, 'Class 12 with PCM, at least 60% aggregate in PCM, and appeared in JEE Main of the same year');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED', TRUE, 'Unmarried candidates only');
CALL sp_seed_other(NULL, 'GENDER', 'MALE', TRUE, 'Men only (check the latest notification)');
CALL sp_seed_other(NULL, 'REGISTRATION', 'JEE_MAIN', FALSE, 'You must have appeared in JEE Main of the same year');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN,NEPAL', TRUE, 'Indian citizens and subjects of Nepal / Bhutan as per the notification');

CALL sp_seed_exam('NAVY_BTECH', 'Indian Navy 10+2 (B.Tech) Cadet Entry Scheme', 'Navy 10+2 B.Tech', 'DEFENCE', 'NAVY',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 2.0, 6, 9,
     'Shortlisting on JEE Main rank → SSB interview → Medical',
     'Executive and Technical branches through a 4-year B.Tech at the Indian Naval Academy',
     'https://www.joinindiannavy.gov.in',
     'Class 12 PCM students are selected using their JEE Main rank. Men and women can apply.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('No application fee', 'No attempt limit within the age window.');
CALL sp_seed_age_window(NULL, 16, 19, -19, 7, 2, -16, 1, 1, 'Born between 2 Jul (year-19) and 1 Jan (year-16), approximately');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,MATHS,ENGLISH', 70, NULL, NULL, FALSE, NULL, NULL, 'Class 12 with 70% in PCM and 50% in English; JEE Main rank');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED', TRUE, 'Unmarried candidates only');
CALL sp_seed_other(NULL, 'REGISTRATION', 'JEE_MAIN', FALSE, 'You must have appeared in JEE Main of the same year');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');

CALL sp_seed_exam('NAVY_INET', 'Indian Navy Entrance Test (Officers)', 'Navy INET', 'DEFENCE', 'NAVY',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 2.0, 3, 5,
     'INET (online) → SSB interview → Medical',
     'Short Service Commission officers: Executive (GS/X, Pilot, Observer, Logistics, NAIC), Technical, Education',
     'https://www.joinindiannavy.gov.in',
     'Graduate officer entry of the Navy, twice a year. Age and degree depend on the branch.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('No application fee', 'No attempt limit within the age window.');
CALL sp_seed_age_window('Executive / Technical (typical)', 19, 24, -24, 7, 2, -19, 1, 1, 'Typical: born between 2 Jul (year-24) and 1 Jan (year-19); varies by branch');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('Executive / Technical (typical)', 'UG', 'B.E.,B.Tech', NULL, 60, NULL, NULL, TRUE, NULL, NULL, 'Typical: B.E./B.Tech with 60% (other branches: MBA, MCA, M.Sc ...)');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED', TRUE, 'Unmarried candidates only');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');

CALL sp_seed_exam('TERRITORIAL_ARMY', 'Territorial Army Officer (Non-Departmental)', 'Territorial Army', 'DEFENCE', 'ARMY',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 6, 7,
     'Written exam → Interview (Preliminary Interview Board) → SSB → Medical',
     'Officer (part-time citizen soldier) in the Territorial Army',
     'https://jointerritorialarmy.gov.in',
     'For gainfully employed civilians who want to serve part-time as officers.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 42, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 18-42 on the closing date of the application');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduate from a recognised university');
CALL sp_seed_other(NULL, 'OTHER', 'GAINFULLY_EMPLOYED', FALSE, 'Must be gainfully employed or self-employed (not for serving members of the regular forces)');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');

CALL sp_seed_exam('ARMY_SSC_TECH', 'Army Short Service Commission (Technical) Men and Women', 'Army SSC Tech', 'DEFENCE', 'ARMY',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 2.0, 1, 4,
     'Shortlisting on degree marks → SSB interview → Medical',
     'Short Service Commission officers in technical arms (engineering graduates)',
     'https://joinindianarmy.nic.in',
     'Engineering graduates are shortlisted by their marks (no written exam). Two courses a year.',
     'LIKELY', @src);
CALL sp_seed_exam_info('No application fee', 'No attempt limit within the age window.');
CALL sp_seed_age_window(NULL, 20, 27, -27, 10, 2, -20, 10, 1, 'Born between 2 Oct (year-27) and 1 Oct (year-20), approximately (20-27 years)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'B.E.,B.Tech', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'B.E./B.Tech in the notified streams; final-year students may apply');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED', TRUE, 'Unmarried candidates (widows of defence personnel have special rules)');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN,NEPAL', TRUE, 'Indian citizens and subjects of Nepal / Bhutan as per the notification');

CALL sp_seed_exam('ARMY_JAG', 'Army Judge Advocate General (JAG) Entry Scheme', 'Army JAG Entry', 'DEFENCE', 'ARMY',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 2.0, 6, 9,
     'Shortlisting on CLAT PG score → SSB interview → Medical',
     'Short Service Commission officers in the JAG Department (law graduates)',
     'https://joinindianarmy.nic.in',
     'Law graduates are shortlisted using their CLAT PG score. Men and women can apply.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('No application fee', 'No attempt limit within the age window.');
CALL sp_seed_age_window(NULL, 21, 27, -27, 7, 2, -21, 7, 1, 'Born between 2 Jul (year-27) and 1 Jul (year-21), approximately (21-27 years)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, 55, NULL, NULL, TRUE, NULL, NULL, 'LLB (3-year after graduation or 5-year after Class 12) with 55%, eligible for Bar Council enrolment; CLAT PG score');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED', TRUE, 'Unmarried candidates only');
CALL sp_seed_other(NULL, 'REGISTRATION', 'CLAT_PG', FALSE, 'You must have appeared in CLAT PG');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');

CALL sp_seed_exam('ARMY_NCC_SPECIAL', 'Army NCC Special Entry Scheme', 'Army NCC Special Entry', 'DEFENCE', 'ARMY',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 2.0, 1, 4,
     'Shortlisting → SSB interview → Medical',
     'Short Service Commission officers for NCC ''C'' certificate holders (men and women)',
     'https://joinindianarmy.nic.in',
     'Graduates with an NCC ''C'' certificate (at least B grade) can join without a written exam.',
     'LIKELY', @src);
CALL sp_seed_exam_info('No application fee', 'No attempt limit within the age window.');
CALL sp_seed_age_window(NULL, 19, 25, -25, 1, 2, -19, 1, 1, 'Born between 2 Jan (year-25) and 1 Jan (year-19), approximately (19-25 years)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, NULL, NULL, TRUE, NULL, NULL, 'Graduation with 50% aggregate');
CALL sp_seed_other(NULL, 'REGISTRATION', 'NCC_C', FALSE, 'You need an NCC ''C'' certificate with at least B grade and 2-3 years in the NCC Senior Division');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED', TRUE, 'Unmarried candidates only');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');

-- =================== POLICE & CAPF ===================

CALL sp_seed_exam('UP_POLICE_CONSTABLE', 'UP Police Constable (Civil Police)', 'UP Police Constable', 'POLICE_CAPF', 'UPPRPB',
     'STATE', 'UP', 'GOVERNMENT', 'RECRUITMENT', 0.5, 12, 3,
     'Written exam → Document verification & Physical Standard Test → Physical Efficiency Test',
     'Constable (Civil Police) - male and female', 'https://uppbpb.gov.in',
     'Large state police recruitment of Uttar Pradesh. Age limit differs for men and women. Reserved-category relaxation only for UP domicile.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 400', 'No attempt limit within the age limit.');
CALL sp_seed_age('Male candidates', 18, 22, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Men: 18-22 on 1 July of the year');
CALL sp_seed_age('Female candidates', 18, 25, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Women: 18-25 on 1 July of the year');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 5, 'ADD', NULL, TRUE, 'UP domicile only');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, TRUE, 'UP domicile only');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, TRUE, 'UP domicile only');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 12 pass from a recognised board');
CALL sp_seed_other('Male candidates', 'GENDER', 'MALE', TRUE, 'Age limit 18-22 applies to men');
CALL sp_seed_other('Female candidates', 'GENDER', 'FEMALE', TRUE, 'Age limit 18-25 applies to women');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'PwBD candidates are not eligible');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, 'Run 4.8 km in 25 min (men) / 2.4 km in 14 min (women); height and chest standards');

CALL sp_seed_exam('UP_POLICE_SI', 'UP Police Sub-Inspector (Civil Police) and equivalent', 'UP Police SI', 'POLICE_CAPF', 'UPPRPB',
     'STATE', 'UP', 'GOVERNMENT', 'RECRUITMENT', 0.5, 3, 11,
     'Written exam → Document verification & PST → PET',
     'Sub-Inspector (Civil Police), Platoon Commander PAC, Fire Officer II', 'https://uppbpb.gov.in',
     'Graduate-level police officers of Uttar Pradesh.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 400', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 28, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 21-28 on 1 July of the year');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 5, 'ADD', NULL, TRUE, 'UP domicile only');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, TRUE, 'UP domicile only');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, TRUE, 'UP domicile only');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Bachelor''s degree from a recognised university');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'PwBD candidates are not eligible');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, 'Run 4.8 km in 28 min (men) / 2.4 km in 16 min (women); height and chest standards');

CALL sp_seed_exam('BIHAR_POLICE_CONSTABLE', 'Bihar Police Constable (CSBC)', 'Bihar Police Constable', 'POLICE_CAPF', 'CSBC',
     'STATE', 'BR', 'GOVERNMENT', 'RECRUITMENT', 1.0, 6, 7,
     'Written exam → Physical Efficiency Test', 'Constable in Bihar Police and allied units', 'https://csbc.bihar.gov.in',
     'State police constable recruitment of Bihar. Relaxations for BC/EBC, SC/ST and women apply only to Bihar domicile.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 675 (Rs 180 for SC, ST and Bihar women)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 25, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'General: 18-25 on the date in the notification');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 2, 'ADD', NULL, TRUE, 'BC / EBC of Bihar: up to 27 (women 28)');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, TRUE, 'SC of Bihar: up to 30');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, TRUE, 'ST of Bihar: up to 30');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 12 (Intermediate) pass');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'PwBD candidates are not eligible');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, 'Running, high jump and shot put; height and chest standards');

CALL sp_seed_exam('RAJASTHAN_POLICE_CONSTABLE', 'Rajasthan Police Constable', 'Rajasthan Police Constable', 'POLICE_CAPF', 'RJ_POLICE',
     'STATE', 'RJ', 'GOVERNMENT', 'RECRUITMENT', 1.0, 4, 9,
     'Written exam → Physical efficiency & measurement → Medical', 'Constable (General / Driver / Band)', 'https://police.rajasthan.gov.in',
     'State police constable recruitment of Rajasthan. Women and reserved categories of Rajasthan get higher age limits.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 600 (Rs 400 for reserved categories of Rajasthan)', 'No attempt limit within the age limit.');
CALL sp_seed_age('Male candidates', 18, 23, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Men (General): 18-23 on 1 January of the next year');
CALL sp_seed_age('Female candidates', 18, 28, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Women (General): 18-28');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 5, 'ADD', NULL, TRUE, 'Rajasthan domicile only');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, TRUE, 'Rajasthan domicile only');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, TRUE, 'Rajasthan domicile only');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 12 pass');
CALL sp_seed_other('Male candidates', 'GENDER', 'MALE', TRUE, 'Age limit 18-23 applies to men');
CALL sp_seed_other('Female candidates', 'GENDER', 'FEMALE', TRUE, 'Age limit 18-28 applies to women');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'PwBD candidates are not eligible');

CALL sp_seed_exam('MAHARASHTRA_POLICE_BHARTI', 'Maharashtra Police Bharti (Police Constable)', 'Maharashtra Police Bharti', 'POLICE_CAPF', 'MH_POLICE',
     'STATE', 'MH', 'GOVERNMENT', 'RECRUITMENT', 1.0, 3, 6,
     'Physical test → Written exam', 'Police Constable, Driver Constable, SRPF, Bandsman', 'https://www.mahapolice.gov.in',
     'District-wise constable recruitment of Maharashtra; physical test first, then written exam.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 450 (Rs 350 for reserved categories)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 28, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 3, 31, 'Open category: 18-28');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 5, 'ADD', NULL, TRUE, 'Backward classes of Maharashtra: up to 33');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, TRUE, 'Maharashtra domicile only');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, TRUE, 'Maharashtra domicile only');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 12 (HSC) pass');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'PwBD candidates are not eligible');

CALL sp_seed_exam('CAPF_TRADESMAN', 'CAPF Constable (Tradesman) - BSF / CRPF / ITBP / CISF', 'CAPF Tradesman', 'POLICE_CAPF', 'MHA',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 3, 6,
     'PST / PET → Trade test → Written exam → Medical',
     'Constable (Tradesman): cook, cobbler, tailor, barber, washerman, sweeper, carpenter, painter and others',
     'https://www.mha.gov.in',
     'Generic entry for tradesman constables; each force publishes its own notification.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 23, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 18-23 (varies by force)');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('EX_SERVICEMAN', NULL, 3, 'ADD_AFTER_SERVICE_DEDUCTION', NULL, FALSE, 'Age minus military service must not exceed the limit by more than 3 years');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 10 pass + proficiency (or ITI) in the trade');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'PwBD candidates are not eligible');

CALL sp_seed_exam('IB_ACIO', 'Intelligence Bureau Assistant Central Intelligence Officer Grade II / Executive', 'IB ACIO', 'POLICE_CAPF', 'MHA',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 7, 9,
     'Tier 1 (objective) → Tier 2 (descriptive) → Tier 3 (interview)', 'ACIO Grade II / Executive', 'https://www.mha.gov.in',
     'Graduate-level intelligence officer recruitment of the Intelligence Bureau.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 650 (Rs 550 processing fee for SC, ST, women and ex-servicemen)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 27, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 10, 'Age 18-27 on the closing date of the application');
CALL sp_seed_relax_central(3, 'ADD_AFTER_SERVICE_DEDUCTION', FALSE);
CALL sp_seed_relax('GOVT_EMPLOYEE', NULL, 5, 'ADD', NULL, FALSE, 'Departmental / central government employees with 3 years service: up to 40');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation; computer knowledge is desirable');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');

CALL sp_seed_exam('IB_SECURITY_ASSISTANT', 'Intelligence Bureau Security Assistant / Executive', 'IB Security Assistant', 'POLICE_CAPF', 'MHA',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 7, 9,
     'Tier 1 (objective) → Tier 2 (local language test) → Tier 3 (interview)', 'Security Assistant / Executive (state-wise)', 'https://www.mha.gov.in',
     'Class 10 level recruitment of the Intelligence Bureau; applicants need the domicile of the state they apply for.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 650 (Rs 550 processing fee for SC, ST, women and ex-servicemen)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 27, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 17, 'Age 18-27 on the closing date of the application');
CALL sp_seed_relax_central(3, 'ADD_AFTER_SERVICE_DEDUCTION', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 10 pass and knowledge of the local language of the state');
CALL sp_seed_other(NULL, 'DOMICILE', 'ANY_STATE_OF_VACANCY', FALSE, 'You need the domicile certificate of the state (SIB) you apply for');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');

SELECT 'Railways, defence and police exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'RAILWAYS')    AS railways,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'DEFENCE')     AS defence,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'POLICE_CAPF') AS police_capf;
