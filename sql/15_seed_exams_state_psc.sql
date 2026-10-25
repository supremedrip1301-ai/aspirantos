-- ============================================================
-- AspirantOS - 15_seed_exams_state_psc.sql
-- State Public Service Commission civil services exams (24 exams) and, at the end of the file,
-- state subordinate selection boards (9 exams).
-- Uses 05_seed_helpers.sql (sp_seed_relax_state = reservations for the state's domicile only).
-- A reserved-category candidate from ANOTHER state is treated as General for the age limit;
-- the engine explains this. State rules change often - most rows are NEEDS_VERIFICATION.
-- Re-runnable.
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the latest state notification known to the developer (2024-26). State PSC rules change often - confirm with the current advertisement.';
SET @dom = 'Candidates from other states may apply where allowed, but reservation and age relaxation are only for the state''s domicile';

CALL sp_seed_body('UPPSC',  'Uttar Pradesh Public Service Commission',  'https://uppsc.up.nic.in',     'STATE_GOVT');
CALL sp_seed_body('BPSC',   'Bihar Public Service Commission',          'https://bpsc.bihar.gov.in',   'STATE_GOVT');
CALL sp_seed_body('MPPSC',  'Madhya Pradesh Public Service Commission', 'https://mppsc.mp.gov.in',     'STATE_GOVT');
CALL sp_seed_body('RPSC',   'Rajasthan Public Service Commission',      'https://rpsc.rajasthan.gov.in','STATE_GOVT');
CALL sp_seed_body('MPSC',   'Maharashtra Public Service Commission',    'https://mpsc.gov.in',         'STATE_GOVT');
CALL sp_seed_body('TNPSC',  'Tamil Nadu Public Service Commission',     'https://www.tnpsc.gov.in',    'STATE_GOVT');
CALL sp_seed_body('KPSC',   'Karnataka Public Service Commission',      'https://kpsc.kar.nic.in',     'STATE_GOVT');
CALL sp_seed_body('APPSC',  'Andhra Pradesh Public Service Commission', 'https://psc.ap.gov.in',       'STATE_GOVT');
CALL sp_seed_body('TGPSC',  'Telangana State Public Service Commission','https://www.tspsc.gov.in',    'STATE_GOVT');
CALL sp_seed_body('WBPSC',  'West Bengal Public Service Commission',    'https://wbpsc.gov.in',        'STATE_GOVT');
CALL sp_seed_body('OPSC',   'Odisha Public Service Commission',         'https://www.opsc.gov.in',     'STATE_GOVT');
CALL sp_seed_body('HPSC',   'Haryana Public Service Commission',        'https://hpsc.gov.in',         'STATE_GOVT');
CALL sp_seed_body('PPSC',   'Punjab Public Service Commission',         'https://ppsc.gov.in',         'STATE_GOVT');
CALL sp_seed_body('HPPSC',  'Himachal Pradesh Public Service Commission','https://www.hppsc.hp.gov.in','STATE_GOVT');
CALL sp_seed_body('UKPSC',  'Uttarakhand Public Service Commission',    'https://psc.uk.gov.in',       'STATE_GOVT');
CALL sp_seed_body('JPSC',   'Jharkhand Public Service Commission',      'https://www.jpsc.gov.in',     'STATE_GOVT');
CALL sp_seed_body('CGPSC',  'Chhattisgarh Public Service Commission',   'https://psc.cg.gov.in',       'STATE_GOVT');
CALL sp_seed_body('GPSC',   'Gujarat Public Service Commission',        'https://gpsc.gujarat.gov.in', 'STATE_GOVT');
CALL sp_seed_body('KERALA_PSC', 'Kerala Public Service Commission',     'https://www.keralapsc.gov.in','STATE_GOVT');
CALL sp_seed_body('APSC',   'Assam Public Service Commission',          'https://apsc.nic.in',         'STATE_GOVT');

-- ---------- UPPSC PCS ----------
CALL sp_seed_exam('UPPSC_PCS', 'UPPSC Combined State / Upper Subordinate Services (PCS)', 'UPPSC PCS', 'STATE_PSC', 'UPPSC',
     'STATE', 'UP', 'GOVERNMENT', 'RECRUITMENT', 1.0, 1, 10,
     'Preliminary → Main → Interview', 'SDM, Deputy SP, BDO, Assistant Commissioner and other UP state services', 'https://uppsc.up.nic.in',
     'Uttar Pradesh state civil services. Age is counted on 1 July of the exam year.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 125 (Rs 65 for SC/ST of UP, Rs 25 for PwBD)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 40, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 21-40 on 1 July of the exam year');
CALL sp_seed_relax_state(5, 5, 0, 15, 3);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Bachelor''s degree; final-year students may write the Preliminary exam');
CALL sp_seed_other(NULL, 'DOMICILE', 'UP', FALSE, @dom);

-- ---------- BPSC CCE ----------
CALL sp_seed_exam('BPSC_CCE', 'BPSC Integrated Combined Competitive Examination', 'BPSC CCE', 'STATE_PSC', 'BPSC',
     'STATE', 'BR', 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 12,
     'Preliminary → Main → Interview', 'Bihar Administrative Service, Bihar Police Service, revenue and other state services', 'https://bpsc.bihar.gov.in',
     'Bihar state civil services. Women of Bihar and reserved categories get higher upper age limits.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 600 (Rs 150 for SC/ST/PwBD and Bihar women)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 37, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Unreserved men: 21-37 on 1 August (minimum 20 or 22 for some posts)');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, TRUE, 'BC / EBC of Bihar: up to 40');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, TRUE, 'SC of Bihar: up to 42');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, TRUE, 'ST of Bihar: up to 42');
CALL sp_seed_relax('WOMEN', NULL, 0, 'REPLACE_WITH_MAX', 40, TRUE, 'Women of Bihar (unreserved / BC / EBC): up to 40');
CALL sp_seed_relax('PWBD', NULL, 10, 'ADD', NULL, TRUE, 'PwBD of Bihar');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation from a recognised university');
CALL sp_seed_other(NULL, 'DOMICILE', 'BR', FALSE, @dom);

-- ---------- MPPSC SSE ----------
CALL sp_seed_exam('MPPSC_SSE', 'MPPSC State Service Examination', 'MPPSC SSE', 'STATE_PSC', 'MPPSC',
     'STATE', 'MP', 'GOVERNMENT', 'RECRUITMENT', 1.0, 1, 6,
     'Preliminary → Main → Interview', 'Deputy Collector, DSP and other MP state services', 'https://mppsc.mp.gov.in',
     'Madhya Pradesh state civil services. Age counted on 1 January of the exam year.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 250 for reserved categories of MP)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 40, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-40 on 1 January of the exam year');
CALL sp_seed_relax_state(5, 5, 5, 5, 5);
CALL sp_seed_relax('WOMEN', NULL, 5, 'ADD', NULL, TRUE, 'Women of MP: +5');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation from a recognised university');
CALL sp_seed_other(NULL, 'DOMICILE', 'MP', FALSE, @dom);

-- ---------- RPSC RAS ----------
CALL sp_seed_exam('RPSC_RAS', 'RPSC Rajasthan State and Subordinate Services Combined Competitive Exam (RAS/RTS)', 'RPSC RAS', 'STATE_PSC', 'RPSC',
     'STATE', 'RJ', 'GOVERNMENT', 'RECRUITMENT', 1.0, 8, 10,
     'Preliminary → Main → Interview', 'Rajasthan Administrative Service, Rajasthan Police Service and allied services', 'https://rpsc.rajasthan.gov.in',
     'Rajasthan state civil services. In Rajasthan the EWS category also gets age relaxation.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 600 (Rs 400 for reserved categories of Rajasthan)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 40, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-40 on 1 January following the advertisement year (= 1 January of the exam year)');
CALL sp_seed_relax_state(5, 5, 5, 0, 0);
CALL sp_seed_relax('WOMEN', NULL, 5, 'ADD', NULL, TRUE, 'Women of Rajasthan: +5 (unreserved women up to 45, reserved women up to 50)');
CALL sp_seed_relax('PWBD', NULL, 10, 'ADD', NULL, TRUE, 'PwBD of Rajasthan');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation; working knowledge of Hindi (Devanagari) and Rajasthani culture');
CALL sp_seed_other(NULL, 'DOMICILE', 'RJ', FALSE, @dom);

-- ---------- MPSC Rajyaseva ----------
CALL sp_seed_exam('MPSC_RAJYASEVA', 'MPSC Maharashtra State Services (Rajyaseva) Examination', 'MPSC Rajyaseva', 'STATE_PSC', 'MPSC',
     'STATE', 'MH', 'GOVERNMENT', 'RECRUITMENT', 1.0, 1, 6,
     'Preliminary → Main (descriptive) → Interview', 'Deputy Collector, DSP, Tehsildar and other Maharashtra state services', 'https://mpsc.gov.in',
     'Maharashtra state civil services (moved to a UPSC-like descriptive Main from 2025).', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 544 (Rs 344 for backward classes of Maharashtra)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 19, 38, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Open category: 19-38');
CALL sp_seed_relax_state(5, 5, 0, 7, 5);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation; knowledge of Marathi');
CALL sp_seed_other(NULL, 'DOMICILE', 'MH', FALSE, @dom);

-- ---------- TNPSC Group 1 ----------
CALL sp_seed_exam('TNPSC_GROUP1', 'TNPSC Combined Civil Services Examination - I (Group 1)', 'TNPSC Group 1', 'STATE_PSC', 'TNPSC',
     'STATE', 'TN', 'GOVERNMENT', 'RECRUITMENT', 1.0, 3, 6,
     'Preliminary → Main → Interview', 'Deputy Collector, DSP, Assistant Commissioner (Commercial Taxes) and others', 'https://www.tnpsc.gov.in',
     'Tamil Nadu Group 1 services. "Others" have a lower upper age than reserved communities of Tamil Nadu.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 200 prelims + Rs 200 mains (exemptions for some communities)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 34, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, '"Others": 21-34');
CALL sp_seed_relax_state(5, 5, 0, 10, 0);
CALL sp_seed_relax('WIDOW_DIVORCED_WOMEN', NULL, 5, 'ADD', NULL, TRUE, 'Destitute widows of Tamil Nadu');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation; adequate knowledge of Tamil');
CALL sp_seed_other(NULL, 'DOMICILE', 'TN', FALSE, @dom);

-- ---------- TNPSC Group 2 ----------
CALL sp_seed_exam('TNPSC_GROUP2', 'TNPSC Combined Civil Services Examination - II (Group 2 & 2A)', 'TNPSC Group 2', 'STATE_PSC', 'TNPSC',
     'STATE', 'TN', 'GOVERNMENT', 'RECRUITMENT', 1.0, 6, 9,
     'Preliminary → Main', 'Sub-Registrar, Municipal Commissioner, Assistant Section Officer and other Group 2 / 2A posts', 'https://www.tnpsc.gov.in',
     'Tamil Nadu Group 2 and 2A (interview and non-interview) posts.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 100 + Rs 150 mains (exemptions for some communities)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, '"Others": 18-32 (no upper limit for some reserved communities with a degree)');
CALL sp_seed_relax_state(5, 5, 0, 10, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation; adequate knowledge of Tamil');
CALL sp_seed_other(NULL, 'DOMICILE', 'TN', FALSE, @dom);

-- ---------- TNPSC Group 4 ----------
CALL sp_seed_exam('TNPSC_GROUP4', 'TNPSC Combined Civil Services Examination - IV (Group 4)', 'TNPSC Group 4', 'STATE_PSC', 'TNPSC',
     'STATE', 'TN', 'GOVERNMENT', 'RECRUITMENT', 1.0, 4, 7,
     'Single written exam → Counselling', 'Village Administrative Officer, Junior Assistant, Typist, Steno-Typist and others', 'https://www.tnpsc.gov.in',
     'Class 10 level Tamil Nadu government posts; one of the largest state recruitments.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 100 (exemptions for some communities)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, '"Others": 18-32; VAO 21-32');
CALL sp_seed_relax_state(10, 10, 0, 10, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'SSLC (Class 10) pass; adequate knowledge of Tamil');
CALL sp_seed_other(NULL, 'DOMICILE', 'TN', FALSE, @dom);

-- ---------- KPSC KAS ----------
CALL sp_seed_exam('KPSC_KAS', 'KPSC Karnataka Administrative Service (Gazetted Probationers)', 'KPSC KAS', 'STATE_PSC', 'KPSC',
     'STATE', 'KA', 'GOVERNMENT', 'RECRUITMENT', 0.5, 2, 8,
     'Preliminary → Main → Personality Test', 'Group A and Group B gazetted probationers of Karnataka', 'https://kpsc.kar.nic.in',
     'Karnataka state civil services (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 600 (Rs 300 for 2A/2B/3A/3B, Rs 50 for ex-servicemen; exempt SC/ST/Cat-1/PwBD)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 35, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 3, 1, 'General merit: 21-35 on the last date of application');
CALL sp_seed_relax_state(3, 5, 0, 10, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation; Kannada language test if not studied');
CALL sp_seed_other(NULL, 'DOMICILE', 'KA', FALSE, @dom);

-- ---------- APPSC Group 1 ----------
CALL sp_seed_exam('APPSC_GROUP1', 'APPSC Group-I Services', 'APPSC Group 1', 'STATE_PSC', 'APPSC',
     'STATE', 'AP', 'GOVERNMENT', 'RECRUITMENT', 0.5, 12, 3,
     'Preliminary → Main → Interview', 'Deputy Collector, DSP, Commercial Tax Officer and other AP Group 1 posts', 'https://psc.ap.gov.in',
     'Andhra Pradesh Group 1 services (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 370 (Rs 250 processing fee for reserved categories of AP)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 42, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 18-42 (DSP 21-30)');
CALL sp_seed_relax_state(5, 5, 5, 10, 3);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation from a recognised university');
CALL sp_seed_other(NULL, 'DOMICILE', 'AP', FALSE, @dom);

-- ---------- APPSC Group 2 ----------
CALL sp_seed_exam('APPSC_GROUP2', 'APPSC Group-II Services', 'APPSC Group 2', 'STATE_PSC', 'APPSC',
     'STATE', 'AP', 'GOVERNMENT', 'RECRUITMENT', 0.5, 12, 2,
     'Preliminary → Main', 'Deputy Tahsildar, Sub-Registrar, Municipal Commissioner and other executive / non-executive posts', 'https://psc.ap.gov.in',
     'Andhra Pradesh Group 2 services (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 330 (Rs 250 processing fee for reserved categories of AP)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 42, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 18-42');
CALL sp_seed_relax_state(5, 5, 5, 10, 3);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation from a recognised university');
CALL sp_seed_other(NULL, 'DOMICILE', 'AP', FALSE, @dom);

-- ---------- TGPSC Group 1 ----------
CALL sp_seed_exam('TGPSC_GROUP1', 'TGPSC Group-I Services (Telangana)', 'TGPSC Group 1', 'STATE_PSC', 'TGPSC',
     'STATE', 'TS', 'GOVERNMENT', 'RECRUITMENT', 0.5, 2, 6,
     'Preliminary → Main', 'Deputy Collector, DSP, Commercial Tax Officer and other Telangana Group 1 posts', 'https://www.tspsc.gov.in',
     'Telangana Group 1 services (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 320 (Rs 200 processing fee; exemptions for some categories)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 46, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 18-46 (DSP 21-35)');
CALL sp_seed_relax_state(5, 5, 5, 10, 3);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation from a recognised university');
CALL sp_seed_other(NULL, 'DOMICILE', 'TS', FALSE, @dom);

-- ---------- TGPSC Group 2 ----------
CALL sp_seed_exam('TGPSC_GROUP2', 'TGPSC Group-II Services (Telangana)', 'TGPSC Group 2', 'STATE_PSC', 'TGPSC',
     'STATE', 'TS', 'GOVERNMENT', 'RECRUITMENT', 0.5, 12, 12,
     'Single written exam (4 papers)', 'Municipal Commissioner, Deputy Tahsildar, Sub-Registrar and other Group 2 posts', 'https://www.tspsc.gov.in',
     'Telangana Group 2 services (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 320 (Rs 200 processing fee; exemptions for some categories)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 44, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 18-44');
CALL sp_seed_relax_state(5, 5, 5, 10, 3);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation from a recognised university');
CALL sp_seed_other(NULL, 'DOMICILE', 'TS', FALSE, @dom);

-- ---------- WBPSC WBCS ----------
CALL sp_seed_exam('WBPSC_WBCS', 'West Bengal Civil Service (Executive) and Other Services Examination', 'WBCS', 'STATE_PSC', 'WBPSC',
     'STATE', 'WB', 'GOVERNMENT', 'RECRUITMENT', 1.0, 12, 4,
     'Preliminary → Main → Personality Test', 'WBCS (Exe), WB Police Service, Revenue Service and Group A-D services', 'https://wbpsc.gov.in',
     'West Bengal state services. Group A and C posts 21-36, Group B 21-39, Group D 20-39.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 210 (exempt for SC/ST/PwBD of West Bengal)', 'No attempt limit within the age limit.');
CALL sp_seed_age('Group A and C services', 21, 36, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-36 on 1 January');
CALL sp_seed_age('Group B (WB Police Service)', 21, 39, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-39 on 1 January');
CALL sp_seed_age('Group D services', 20, 39, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 20-39 on 1 January');
CALL sp_seed_relax_state(3, 5, 0, 8, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation; ability to read, write and speak Bengali (or Nepali for some hill areas)');
CALL sp_seed_other(NULL, 'DOMICILE', 'WB', FALSE, @dom);

-- ---------- OPSC OCS ----------
CALL sp_seed_exam('OPSC_OCS', 'OPSC Odisha Civil Services Examination', 'OPSC OCS', 'STATE_PSC', 'OPSC',
     'STATE', 'OD', 'GOVERNMENT', 'RECRUITMENT', 1.0, 12, 6,
     'Preliminary → Main → Personality Test', 'Odisha Administrative Service, Odisha Police Service and allied services', 'https://www.opsc.gov.in',
     'Odisha state civil services.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('No application fee (recent notifications)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-32 on 1 January (recent notifications raised the limit temporarily - verify)');
CALL sp_seed_relax_state(5, 5, 0, 10, 5);
CALL sp_seed_relax('WOMEN', NULL, 5, 'ADD', NULL, TRUE, 'Women of Odisha: +5');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation; Odia language up to Class 7 level');
CALL sp_seed_other(NULL, 'DOMICILE', 'OD', FALSE, @dom);

-- ---------- HPSC HCS ----------
CALL sp_seed_exam('HPSC_HCS', 'Haryana Civil Services (Executive Branch) and Allied Services', 'HPSC HCS', 'STATE_PSC', 'HPSC',
     'STATE', 'HR', 'GOVERNMENT', 'RECRUITMENT', 0.5, 1, 4,
     'Preliminary → Main → Personality Test', 'HCS (Executive), DSP, ETO, Block Development & Panchayat Officer and others', 'https://hpsc.gov.in',
     'Haryana state civil services (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1000 (Rs 250 for reserved / women of Haryana)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 42, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-42');
CALL sp_seed_relax_state(5, 5, 0, 10, 0);
CALL sp_seed_relax('WIDOW_DIVORCED_WOMEN', NULL, 5, 'ADD', NULL, TRUE, 'Widows / divorced women of Haryana');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation; Hindi / Sanskrit up to matric');
CALL sp_seed_other(NULL, 'DOMICILE', 'HR', FALSE, @dom);

-- ---------- PPSC PCS ----------
CALL sp_seed_exam('PPSC_PCS', 'Punjab State Civil Services Combined Competitive Examination', 'PPSC PCS', 'STATE_PSC', 'PPSC',
     'STATE', 'PB', 'GOVERNMENT', 'RECRUITMENT', 0.5, 1, 3,
     'Preliminary → Main → Interview', 'PCS (Executive), DSP, Tehsildar, ETO and other Punjab services', 'https://ppsc.gov.in',
     'Punjab state civil services (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1500 (Rs 750 for SC/BC of Punjab)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 37, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'General: 21-37');
CALL sp_seed_relax_state(5, 5, 0, 10, 0);
CALL sp_seed_relax('GOVT_EMPLOYEE', NULL, 0, 'REPLACE_WITH_MAX', 45, TRUE, 'Punjab government employees: up to 45');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation; Punjabi up to matric');
CALL sp_seed_other(NULL, 'DOMICILE', 'PB', FALSE, @dom);

-- ---------- HPPSC HPAS ----------
CALL sp_seed_exam('HPPSC_HPAS', 'HP Administrative Service Combined Competitive Examination', 'HPPSC HPAS', 'STATE_PSC', 'HPPSC',
     'STATE', 'HP', 'GOVERNMENT', 'RECRUITMENT', 1.0, 3, 6,
     'Preliminary → Main → Personality Test', 'HPAS, HP Police Service, Tehsildar, BDO and others', 'https://www.hppsc.hp.gov.in',
     'Himachal Pradesh state civil services.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 400 (Rs 100 for reserved categories of HP)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 35, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-35 on 1 January');
CALL sp_seed_relax_state(5, 5, 0, 5, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation from a recognised university');
CALL sp_seed_other(NULL, 'DOMICILE', 'HP', FALSE, @dom);

-- ---------- UKPSC PCS ----------
CALL sp_seed_exam('UKPSC_PCS', 'Uttarakhand Combined State Civil / Upper Subordinate Services', 'UKPSC PCS', 'STATE_PSC', 'UKPSC',
     'STATE', 'UK', 'GOVERNMENT', 'RECRUITMENT', 1.0, 6, 10,
     'Preliminary → Main → Interview', 'Deputy Collector, DSP and other Uttarakhand state services', 'https://psc.uk.gov.in',
     'Uttarakhand state civil services.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 176 (Rs 86 for reserved categories of Uttarakhand)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 42, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 21-42 on 1 July');
CALL sp_seed_relax_state(5, 5, 0, 15, 5);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation from a recognised university');
CALL sp_seed_other(NULL, 'DOMICILE', 'UK', FALSE, @dom);

-- ---------- JPSC CCE ----------
CALL sp_seed_exam('JPSC_CCE', 'JPSC Combined Civil Services Examination', 'JPSC CCE', 'STATE_PSC', 'JPSC',
     'STATE', 'JH', 'GOVERNMENT', 'RECRUITMENT', 0.5, 1, 3,
     'Preliminary → Main → Interview', 'Jharkhand Administrative Service, Police Service and allied services', 'https://www.jpsc.gov.in',
     'Jharkhand state civil services (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 100 (Rs 50 for SC/ST of Jharkhand)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 35, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Unreserved: 21-35');
CALL sp_seed_relax_state(2, 5, 0, 10, 0);
CALL sp_seed_relax('WOMEN', NULL, 0, 'REPLACE_WITH_MAX', 38, TRUE, 'Women of Jharkhand (unreserved / BC): up to 38');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation from a recognised university');
CALL sp_seed_other(NULL, 'DOMICILE', 'JH', FALSE, @dom);

-- ---------- CGPSC SSE ----------
CALL sp_seed_exam('CGPSC_SSE', 'CGPSC State Service Examination', 'CGPSC SSE', 'STATE_PSC', 'CGPSC',
     'STATE', 'CG', 'GOVERNMENT', 'RECRUITMENT', 1.0, 12, 2,
     'Preliminary → Main → Interview', 'Deputy Collector, DSP and other Chhattisgarh state services', 'https://psc.cg.gov.in',
     'Chhattisgarh state civil services. Chhattisgarh domicile candidates get 5 extra years.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 400 (Rs 300 for reserved categories of Chhattisgarh)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Non-domicile: 21-30');
CALL sp_seed_relax('STATE_DOMICILE', NULL, 5, 'ADD', NULL, TRUE, 'Chhattisgarh domicile: up to 35');
CALL sp_seed_relax_state(5, 5, 0, 10, 0);
CALL sp_seed_relax('WOMEN', NULL, 10, 'ADD', NULL, TRUE, 'Women of Chhattisgarh: +10');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation from a recognised university');
CALL sp_seed_other(NULL, 'DOMICILE', 'CG', FALSE, @dom);

-- ---------- GPSC Class 1 & 2 ----------
CALL sp_seed_exam('GPSC_CLASS12', 'GPSC Gujarat Administrative Service Class 1 & Civil Services Class 1 and 2', 'GPSC Class 1 & 2', 'STATE_PSC', 'GPSC',
     'STATE', 'GJ', 'GOVERNMENT', 'RECRUITMENT', 1.0, 8, 12,
     'Preliminary → Main → Interview', 'Deputy Collector, DSP, Mamlatdar, TDO and other Gujarat services', 'https://gpsc.gujarat.gov.in',
     'Gujarat state civil services.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 100 (exempt for reserved categories of Gujarat)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 35, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 31, 'Age 21-35 on the last date of application');
CALL sp_seed_relax_state(5, 5, 5, 10, 0);
CALL sp_seed_relax('WOMEN', NULL, 5, 'ADD', NULL, TRUE, 'Women of Gujarat: +5 (total cap 45)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation; knowledge of Gujarati and Hindi');
CALL sp_seed_other(NULL, 'DOMICILE', 'GJ', FALSE, @dom);

-- ---------- Kerala PSC KAS ----------
CALL sp_seed_exam('KERALA_KAS', 'Kerala Administrative Service (Junior Time Scale) Officer Trainee', 'Kerala KAS', 'STATE_PSC', 'KERALA_PSC',
     'STATE', 'KL', 'GOVERNMENT', 'RECRUITMENT', 0.5, 3, 6,
     'Preliminary → Main → Interview', 'KAS Officer (Junior Time Scale) - Stream 1 (direct recruitment)', 'https://www.keralapsc.gov.in',
     'Kerala state administrative service; stream 1 is for open candidates (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('No application fee (one-time registration)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Stream 1: 21-32');
CALL sp_seed_relax_state(3, 5, 0, 10, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation from a recognised university');
CALL sp_seed_other(NULL, 'DOMICILE', 'KL', FALSE, @dom);

-- ---------- APSC CCE ----------
CALL sp_seed_exam('APSC_CCE', 'APSC Combined Competitive Examination (Assam)', 'APSC CCE', 'STATE_PSC', 'APSC',
     'STATE', 'AS', 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 12,
     'Preliminary → Main → Viva-voce', 'Assam Civil Service, Assam Police Service and allied services', 'https://apsc.nic.in',
     'Assam state civil services.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 297 (lower for reserved categories / BPL)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 38, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-38 on 1 January');
CALL sp_seed_relax_state(3, 5, 0, 10, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation; knowledge of Assamese or the official language of the area');
CALL sp_seed_other(NULL, 'DOMICILE', 'AS', FALSE, @dom);

SELECT 'State PSC exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'STATE_PSC') AS state_psc_exams;

-- ============================================================
-- State subordinate selection boards (STATE_SSB category, 9 exams) - added in P2.14.
-- ============================================================

CALL sp_seed_body('UPSSSC', 'Uttar Pradesh Subordinate Services Selection Commission', 'https://upsssc.gov.in', 'STATE_GOVT');
CALL sp_seed_body('RSMSSB', 'Rajasthan Staff Selection Board (RSMSSB)',              'https://rsmssb.rajasthan.gov.in', 'STATE_GOVT');
CALL sp_seed_body('HSSC',   'Haryana Staff Selection Commission',                    'https://hssc.gov.in', 'STATE_GOVT');
CALL sp_seed_body('BSSC',   'Bihar Staff Selection Commission',                      'https://bssc.bihar.gov.in', 'STATE_GOVT');
CALL sp_seed_body('OSSC',   'Odisha Staff Selection Commission',                     'https://www.ossc.gov.in', 'STATE_GOVT');
CALL sp_seed_body('GSSSB',  'Gujarat Subordinate Service Selection Board',           'https://gsssb.gujarat.gov.in', 'STATE_GOVT');
CALL sp_seed_body('PSSSB',  'Punjab Subordinate Services Selection Board',           'https://sssb.punjab.gov.in', 'STATE_GOVT');
CALL sp_seed_body('MPESB',  'Madhya Pradesh Employees Selection Board',              'https://esb.mp.gov.in', 'STATE_GOVT');
CALL sp_seed_body('DSSSB',  'Delhi Subordinate Services Selection Board',            'https://dsssb.delhi.gov.in', 'STATE_GOVT');

CALL sp_seed_exam('UPSSSC_PET', 'UPSSSC Preliminary Eligibility Test (PET)', 'UPSSSC PET', 'STATE_SSB', 'UPSSSC',
     'STATE', 'UP', 'GOVERNMENT', 'CERTIFICATION', 1.0, 5, 9,
     'Single objective test; score valid for 3 years', 'Mandatory screening test for UP Group C recruitments', 'https://upsssc.gov.in',
     'A PET score is needed to apply for most UPSSSC Group C posts.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 185 (Rs 95 for SC/ST, Rs 25 for PwBD)', 'No attempt limit; the score is valid for 3 years.');
CALL sp_seed_age(NULL, 18, 40, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Age 18-40 on 1 July');
CALL sp_seed_relax_state(5, 5, 0, 15, 3);
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 10 pass');
CALL sp_seed_other(NULL, 'DOMICILE', 'UP', FALSE, @dom);

CALL sp_seed_exam('RSMSSB_CET', 'Rajasthan Common Eligibility Test (Graduate and Senior Secondary level)', 'Rajasthan CET', 'STATE_SSB', 'RSMSSB',
     'STATE', 'RJ', 'GOVERNMENT', 'CERTIFICATION', 1.0, 7, 9,
     'Single objective test; score valid for 1 year', 'Screening for Rajasthan Patwari, Gram Sevak, LDC, Constable and other posts', 'https://rsmssb.rajasthan.gov.in',
     'Two separate CETs (graduate and Class 12 level); the score is needed for many Rajasthan posts.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 600 (Rs 400 for reserved categories of Rajasthan)', 'No attempt limit.');
CALL sp_seed_age(NULL, 18, 40, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 18-40 on 1 January');
CALL sp_seed_relax_state(5, 5, 5, 10, 0);
CALL sp_seed_relax('WOMEN', NULL, 5, 'ADD', NULL, TRUE, 'Women of Rajasthan: +5');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('Graduate level CET', 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduate level: graduation');
CALL sp_seed_qual('Senior Secondary level CET', 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Senior Secondary level: Class 12');
CALL sp_seed_other(NULL, 'DOMICILE', 'RJ', FALSE, @dom);

CALL sp_seed_exam('HSSC_CET', 'Haryana Common Eligibility Test (Group C and D)', 'HSSC CET', 'STATE_SSB', 'HSSC',
     'STATE', 'HR', 'GOVERNMENT', 'CERTIFICATION', 0.5, 5, 7,
     'Single objective test; score valid for 3 years', 'Screening for Haryana Group C and Group D government jobs', 'https://hssc.gov.in',
     'A CET pass is needed for most Haryana Group C / D posts.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 250 for reserved / women of Haryana)', 'No attempt limit.');
CALL sp_seed_age(NULL, 18, 42, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 18-42');
CALL sp_seed_relax_state(5, 5, 0, 10, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_10', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Group D: Class 10; Group C: Class 12 or graduation (by post)');
CALL sp_seed_other(NULL, 'DOMICILE', 'HR', FALSE, @dom);

CALL sp_seed_exam('BSSC_GRADUATE', 'BSSC Combined Graduate Level Examination', 'BSSC Graduate Level', 'STATE_SSB', 'BSSC',
     'STATE', 'BR', 'GOVERNMENT', 'RECRUITMENT', 0.5, 4, 8,
     'Preliminary → Main', 'Graduate-level Group C posts in Bihar government departments', 'https://bssc.bihar.gov.in',
     'Graduate-level staff selection exam of Bihar (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 540 (Rs 135 for SC/ST of Bihar)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 37, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Unreserved men: 21-37');
CALL sp_seed_relax_state(3, 5, 0, 10, 0);
CALL sp_seed_relax('WOMEN', NULL, 0, 'REPLACE_WITH_MAX', 40, TRUE, 'Women of Bihar: up to 40');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation from a recognised university');
CALL sp_seed_other(NULL, 'DOMICILE', 'BR', FALSE, @dom);

CALL sp_seed_exam('DSSSB_GENERAL', 'DSSSB Recruitment (non-teaching posts, generic)', 'DSSSB (Non-teaching)', 'STATE_SSB', 'DSSSB',
     'STATE', 'DL', 'GOVERNMENT', 'RECRUITMENT', 1.0, NULL, NULL,
     'One-tier / two-tier CBT (post-wise)', 'LDC, Junior Assistant, Patwari, Accountant, Head Clerk, Stenographer and other Delhi government posts', 'https://dsssb.delhi.gov.in',
     'Generic entry for Delhi government non-teaching posts; every post has its own age limit and qualification.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 100; exempt for women, SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Typical: 18-27 / 18-30 / 18-32 by post');
CALL sp_seed_relax_central(3, 'ADD_AFTER_SERVICE_DEDUCTION', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 12 or graduation (by post)');

CALL sp_seed_exam('OSSC_CGL', 'OSSC Combined Graduate Level Examination', 'OSSC CGL', 'STATE_SSB', 'OSSC',
     'STATE', 'OD', 'GOVERNMENT', 'RECRUITMENT', 1.0, 8, 11,
     'Preliminary → Main → Skill test', 'Graduate-level Group B / C posts in Odisha departments', 'https://www.ossc.gov.in',
     'Graduate-level staff selection exam of Odisha.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('No application fee (recent notices)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 38, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-38 on 1 January');
CALL sp_seed_relax_state(5, 5, 0, 10, 5);
CALL sp_seed_relax('WOMEN', NULL, 5, 'ADD', NULL, TRUE, 'Women of Odisha: +5');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation; Odia language proficiency');
CALL sp_seed_other(NULL, 'DOMICILE', 'OD', FALSE, @dom);

CALL sp_seed_exam('GSSSB_CCE', 'GSSSB Combined Competitive Examination (Group A / B)', 'GSSSB CCE', 'STATE_SSB', 'GSSSB',
     'STATE', 'GJ', 'GOVERNMENT', 'RECRUITMENT', 1.0, 1, 4,
     'Preliminary → Main', 'Class III posts in Gujarat government departments', 'https://gsssb.gujarat.gov.in',
     'Combined exam for Gujarat Class III posts.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 500 (exempt for reserved categories of Gujarat)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 35, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Typical: 18-33 / 18-35 by post');
CALL sp_seed_relax_state(5, 5, 5, 10, 0);
CALL sp_seed_relax('WOMEN', NULL, 5, 'ADD', NULL, TRUE, 'Women of Gujarat: +5 (cap 45)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 12 or graduation (by group)');
CALL sp_seed_other(NULL, 'DOMICILE', 'GJ', FALSE, @dom);

CALL sp_seed_exam('PSSSB_CLERK', 'PSSSB Clerk / Junior Assistant and other posts', 'Punjab SSSB', 'STATE_SSB', 'PSSSB',
     'STATE', 'PB', 'GOVERNMENT', 'RECRUITMENT', 1.0, NULL, NULL,
     'Written test → Typing test (post-wise)', 'Clerk, Junior Assistant, Patwari and other Group C posts in Punjab', 'https://sssb.punjab.gov.in',
     'Staff selection board of Punjab; Punjabi up to matric is compulsory.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1000 (Rs 250 for SC/BC of Punjab)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 37, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'General: 18-37');
CALL sp_seed_relax_state(5, 5, 0, 10, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation + computer course (for clerk posts); Punjabi up to matric');
CALL sp_seed_other(NULL, 'DOMICILE', 'PB', FALSE, @dom);

CALL sp_seed_exam('MPESB_GROUP', 'MPESB Group Recruitment Tests (Group 2, 3, 4 and others)', 'MPESB', 'STATE_SSB', 'MPESB',
     'STATE', 'MP', 'GOVERNMENT', 'RECRUITMENT', 2.0, NULL, NULL,
     'Online CBT (group-wise)', 'Patwari, Constable, teachers, assistant grade-3 and many other MP government posts', 'https://esb.mp.gov.in',
     'MP Employees Selection Board (earlier Vyapam) conducts most Group C recruitment of Madhya Pradesh.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 250 for reserved categories of MP)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 40, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Typical: 18-40 for MP domicile');
CALL sp_seed_relax_state(5, 5, 5, 5, 5);
CALL sp_seed_relax('WOMEN', NULL, 5, 'ADD', NULL, TRUE, 'Women of MP: +5');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 10 / 12 / graduation by post');
CALL sp_seed_other(NULL, 'DOMICILE', 'MP', FALSE, @dom);

SELECT 'State selection board exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'STATE_SSB') AS state_ssb_exams;
