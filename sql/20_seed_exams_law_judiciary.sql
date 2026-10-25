-- ============================================================
-- AspirantOS - 20_seed_exams_law_judiciary.sql
-- Law entrance and bar exam (6 exams) and Civil Judge (Junior Division) judicial services
-- (8 states + 1 generic = 9 exams). Uses 05_seed_helpers.sql. Re-runnable.
-- Judicial services: the Supreme Court (All India Judges Association, 20 May 2025) restored the
-- condition of at least 3 years of practice as an advocate for Civil Judge (Junior Division);
-- states are amending their rules, so every judiciary row is NEEDS_VERIFICATION and uses
-- min_experience_years = 3 (practice is read from work_experience.is_relevant_professional).
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the latest notification known to the developer (2025-26). Confirm with the current notification / rules.';
SET @jud = 'LLB from a recognised university, enrolled as an advocate, with at least 3 years of practice (Supreme Court ruling of 20 May 2025; check the state''s amended rules)';

CALL sp_seed_body('CONSORTIUM_NLU', 'Consortium of National Law Universities',  'https://consortiumofnlus.ac.in', 'AUTONOMOUS');
CALL sp_seed_body('NLU_DELHI',      'National Law University, Delhi',          'https://nationallawuniversitydelhi.in', 'UNIVERSITY');
CALL sp_seed_body('LSAC',           'Law School Admission Council (LSAT India / LSAT Global)', 'https://www.discoverlaw.in', 'INTERNATIONAL');
CALL sp_seed_body('BCI',            'Bar Council of India',                    'https://allindiabarexamination.com', 'AUTONOMOUS');
CALL sp_seed_body('DELHI_HC',       'High Court of Delhi',                     'https://delhihighcourt.nic.in', 'STATE_GOVT');
CALL sp_seed_body('RAJASTHAN_HC',   'Rajasthan High Court',                    'https://hcraj.nic.in',          'STATE_GOVT');
CALL sp_seed_body('MP_HC',          'High Court of Madhya Pradesh',            'https://mphc.gov.in',           'STATE_GOVT');
CALL sp_seed_body('HIGH_COURTS',    'State High Courts / Public Service Commissions (various)', NULL,      'STATE_GOVT');

-- =================== LAW ENTRANCE & BAR ===================

CALL sp_seed_exam('CLAT_UG', 'Common Law Admission Test (UG)', 'CLAT UG', 'JUDICIARY_LAW', 'CONSORTIUM_NLU',
     'NATIONAL', NULL, 'AUTONOMOUS', 'ADMISSION', 1.0, 7, 12,
     'Offline test → Consortium counselling', '5-year integrated LL.B. (Hons) at 24 National Law Universities', 'https://consortiumofnlus.ac.in',
     'No upper age limit. Class 12 with 45% (40% SC/ST); students appearing in Class 12 may apply.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 4000 (Rs 3500 for SC, ST, BPL, PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No upper age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, 45, 40, 'SC,ST', TRUE, NULL, NULL, 'Class 12 with 45% (40% SC/ST); appearing students may apply');

CALL sp_seed_exam('CLAT_PG', 'Common Law Admission Test (PG)', 'CLAT PG', 'JUDICIARY_LAW', 'CONSORTIUM_NLU',
     'NATIONAL', NULL, 'AUTONOMOUS', 'ADMISSION', 1.0, 7, 12,
     'Offline test → Counselling', 'One-year LL.M. at NLUs; score also used by PSUs for legal officer recruitment', 'https://consortiumofnlus.ac.in',
     'PG law entrance; LL.B. with 50% (45% SC/ST); final-year students may apply.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 4000 (Rs 3500 for SC, ST, BPL, PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No upper age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, 50, 45, 'SC,ST,PWBD', TRUE, NULL, NULL, 'LL.B. or equivalent with 50% (45% SC/ST/PwBD); final-year students may apply');

CALL sp_seed_exam('AILET', 'All India Law Entrance Test (NLU Delhi)', 'AILET', 'JUDICIARY_LAW', 'NLU_DELHI',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 8, 12,
     'Offline test → Counselling', 'BA LL.B. (Hons), LL.M. and PhD at National Law University Delhi', 'https://nationallawuniversitydelhi.in',
     'NLU Delhi''s own entrance (it does not use CLAT).', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 3500 (Rs 1500 for SC/ST/PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No upper age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('BA LL.B. (Hons)', 'CLASS_12', 'ANY', NULL, 45, 40, 'SC,ST,PWBD', TRUE, NULL, NULL, 'BA LL.B.: Class 12 with 45% (40% SC/ST/PwBD)');
CALL sp_seed_qual('LL.M.', 'UG', 'LLB', NULL, 50, 45, 'SC,ST,PWBD', TRUE, NULL, NULL, 'LL.M.: LL.B. with 50% (45% SC/ST/PwBD)');

CALL sp_seed_exam('LSAT_INDIA', 'LSAT - India (LSAT Global for Indian law schools)', 'LSAT India', 'JUDICIARY_LAW', 'LSAC',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 2.0, 9, 1,
     'Remote proctored test (January and May sessions)', '5-year and 3-year LL.B. and LL.M. at Jindal and other private law schools', 'https://www.discoverlaw.in',
     'Reasoning-based law entrance used by many private law schools.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 4299', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('5-year LL.B.', 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, '5-year LL.B.: Class 12 (institute-specific minimum marks)');
CALL sp_seed_qual('3-year LL.B. / LL.M.', 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, '3-year LL.B.: graduation; LL.M.: LL.B.');

CALL sp_seed_exam('MH_CET_LAW', 'MH CET Law (3-year and 5-year LL.B.)', 'MH CET Law', 'JUDICIARY_LAW', 'MH_CET_CELL',
     'STATE', 'MH', 'GOVERNMENT', 'ADMISSION', 1.0, 1, 4,
     'Computer-based test → CAP rounds', '3-year and 5-year LL.B. at law colleges of Maharashtra', 'https://cetcell.mahacet.org',
     'State law entrance of Maharashtra; two separate tests (3-year and 5-year).', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1000 (Rs 800 for reserved categories of Maharashtra)', 'One attempt per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('5-year LL.B.', 'CLASS_12', 'ANY', NULL, 45, 40, 'SC,ST,OBC_NCL,PWBD', TRUE, NULL, NULL, '5-year LL.B.: Class 12 with 45% (40% reserved of Maharashtra)');
CALL sp_seed_qual('3-year LL.B.', 'UG', 'ANY', NULL, 45, 40, 'SC,ST,OBC_NCL,PWBD', TRUE, NULL, NULL, '3-year LL.B.: graduation with 45% (40% reserved of Maharashtra)');

CALL sp_seed_exam('AIBE', 'All India Bar Examination', 'AIBE', 'JUDICIARY_LAW', 'BCI',
     'NATIONAL', NULL, 'AUTONOMOUS', 'LICENSING', 1.0, 9, 11,
     'Open-book objective test', 'Certificate of Practice to practise law in Indian courts', 'https://allindiabarexamination.com',
     'Bar exam for law graduates enrolled with a State Bar Council. Final-semester LL.B. students have been allowed recently.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 3500 (Rs 2500 for SC / ST)', 'No limit on attempts.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'LL.B. (3-year or 5-year) from a BCI-recognised university, enrolled with a State Bar Council');
CALL sp_seed_other(NULL, 'REGISTRATION', 'BAR_COUNCIL_ENROLMENT', FALSE, 'Provisional enrolment with a State Bar Council is needed');

-- =================== JUDICIAL SERVICES (CIVIL JUDGE, JUNIOR DIVISION) ===================

CALL sp_seed_exam('UP_PCS_J', 'UP Judicial Services Civil Judge (Junior Division) - PCS-J', 'UP PCS-J', 'JUDICIARY_LAW', 'UPPSC',
     'STATE', 'UP', 'GOVERNMENT', 'RECRUITMENT', 0.5, 2, 5,
     'Preliminary → Main → Interview', 'Civil Judge (Junior Division) in Uttar Pradesh', 'https://uppsc.up.nic.in',
     'Judicial service entry of Uttar Pradesh conducted by UPPSC.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 125 (Rs 65 for SC/ST of UP)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 22, 35, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 22-35 on the cut-off date');
CALL sp_seed_relax_state(5, 5, 0, 15, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, NULL, NULL, NULL, FALSE, NULL, 3.0, @jud);
CALL sp_seed_other(NULL, 'DOMICILE', 'UP', FALSE, 'Reservation and relaxation only for UP domicile; Hindi in Devanagari required');

CALL sp_seed_exam('DELHI_JS', 'Delhi Judicial Service Examination', 'Delhi Judicial Service', 'JUDICIARY_LAW', 'DELHI_HC',
     'STATE', 'DL', 'GOVERNMENT', 'RECRUITMENT', 1.0, 2, 4,
     'Preliminary → Main → Viva-voce', 'Civil Judge in Delhi', 'https://delhihighcourt.nic.in',
     'Judicial service entry of Delhi conducted by the Delhi High Court.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1500 (Rs 100 for SC/ST/PwBD)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, NULL, 32, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Not more than 32 years on 1 January');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('PWBD', NULL, 10, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, NULL, NULL, NULL, FALSE, NULL, 3.0, @jud);

CALL sp_seed_exam('RAJASTHAN_JS', 'Rajasthan Judicial Service (Civil Judge) - RJS', 'Rajasthan Judicial Service', 'JUDICIARY_LAW', 'RAJASTHAN_HC',
     'STATE', 'RJ', 'GOVERNMENT', 'RECRUITMENT', 0.5, 8, 11,
     'Preliminary → Main → Interview', 'Civil Judge in Rajasthan', 'https://hcraj.nic.in',
     'Judicial service entry of Rajasthan conducted by the Rajasthan High Court.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1500 (lower for reserved categories of Rajasthan)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 40, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-40 on 1 January');
CALL sp_seed_relax_state(5, 5, 5, 10, 0);
CALL sp_seed_relax('WOMEN', NULL, 5, 'ADD', NULL, TRUE, 'Women of Rajasthan: +5');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, NULL, NULL, NULL, FALSE, NULL, 3.0, @jud);
CALL sp_seed_other(NULL, 'DOMICILE', 'RJ', FALSE, 'Reservation and relaxation only for Rajasthan domicile');

CALL sp_seed_exam('MP_CIVIL_JUDGE', 'MP Civil Judge (Junior Division) Entry Level Examination', 'MP Civil Judge', 'JUDICIARY_LAW', 'MP_HC',
     'STATE', 'MP', 'GOVERNMENT', 'RECRUITMENT', 0.5, 11, 3,
     'Preliminary → Main → Interview', 'Civil Judge Class II in Madhya Pradesh', 'https://mphc.gov.in',
     'Judicial service entry of Madhya Pradesh conducted by the MP High Court.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1028 (lower for reserved categories of MP)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 35, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-35');
CALL sp_seed_relax_state(3, 3, 0, 0, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, NULL, NULL, NULL, FALSE, NULL, 3.0, @jud);
CALL sp_seed_other(NULL, 'DOMICILE', 'MP', FALSE, 'Reservation and relaxation only for MP domicile');

CALL sp_seed_exam('BIHAR_JS', 'Bihar Judicial Services (Civil Judge) Competitive Examination', 'Bihar Judicial Service', 'JUDICIARY_LAW', 'BPSC',
     'STATE', 'BR', 'GOVERNMENT', 'RECRUITMENT', 0.5, 9, 12,
     'Preliminary → Main → Interview', 'Civil Judge (Junior Division) in Bihar', 'https://bpsc.bihar.gov.in',
     'Judicial service entry of Bihar conducted by BPSC.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 600 (Rs 150 for SC/ST/PwBD of Bihar)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 22, 35, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Unreserved: 22-35');
CALL sp_seed_relax_state(3, 5, 0, 10, 0);
CALL sp_seed_relax('WOMEN', NULL, 3, 'ADD', NULL, TRUE, 'Women of Bihar: +3');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, NULL, NULL, NULL, FALSE, NULL, 3.0, @jud);
CALL sp_seed_other(NULL, 'DOMICILE', 'BR', FALSE, 'Reservation and relaxation only for Bihar domicile');

CALL sp_seed_exam('HARYANA_JS', 'Haryana Civil Service (Judicial Branch)', 'Haryana Judicial Service', 'JUDICIARY_LAW', 'HPSC',
     'STATE', 'HR', 'GOVERNMENT', 'RECRUITMENT', 0.5, 1, 4,
     'Preliminary → Main → Viva-voce', 'Civil Judge (Junior Division) in Haryana', 'https://hpsc.gov.in',
     'Judicial service entry of Haryana (HCS Judicial).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1000 (Rs 250 for reserved / women of Haryana)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 42, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-42');
CALL sp_seed_relax_state(5, 5, 0, 10, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, NULL, NULL, NULL, FALSE, NULL, 3.0, @jud);
CALL sp_seed_other(NULL, 'DOMICILE', 'HR', FALSE, 'Reservation and relaxation only for Haryana domicile; Hindi up to matric');

CALL sp_seed_exam('PUNJAB_JS', 'Punjab Civil Service (Judicial Branch)', 'Punjab Judicial Service', 'JUDICIARY_LAW', 'PPSC',
     'STATE', 'PB', 'GOVERNMENT', 'RECRUITMENT', 0.5, 1, 3,
     'Preliminary → Main → Viva-voce', 'Civil Judge (Junior Division) in Punjab', 'https://ppsc.gov.in',
     'Judicial service entry of Punjab (PCS Judicial).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1500 (Rs 750 for SC/BC of Punjab)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 37, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Age 21-37');
CALL sp_seed_relax_state(5, 5, 0, 10, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, NULL, NULL, NULL, FALSE, NULL, 3.0, @jud);
CALL sp_seed_other(NULL, 'DOMICILE', 'PB', FALSE, 'Reservation and relaxation only for Punjab domicile; Punjabi up to matric');

CALL sp_seed_exam('MAHARASHTRA_JS', 'Maharashtra Civil Judge (Junior Division) & Judicial Magistrate First Class', 'Maharashtra Judicial Service', 'JUDICIARY_LAW', 'MPSC',
     'STATE', 'MH', 'GOVERNMENT', 'RECRUITMENT', 0.5, 2, 6,
     'Preliminary → Main → Viva-voce', 'Civil Judge (Junior Division) and JMFC in Maharashtra', 'https://mpsc.gov.in',
     'Judicial service entry of Maharashtra conducted by MPSC.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 394 (lower for backward classes of Maharashtra)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 35, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Practising advocates: up to 35 (fresh graduates had a lower limit before 2025)');
CALL sp_seed_relax_state(3, 5, 0, 0, 0);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, NULL, NULL, NULL, FALSE, NULL, 3.0, @jud);
CALL sp_seed_other(NULL, 'DOMICILE', 'MH', FALSE, 'Reservation and relaxation only for Maharashtra domicile; knowledge of Marathi');

CALL sp_seed_exam('OTHER_STATE_JS', 'Other State Judicial Services - Civil Judge (Junior Division) (generic)', 'Other State Judicial Services', 'JUDICIARY_LAW', 'HIGH_COURTS',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, NULL, NULL,
     'Preliminary → Main → Interview (varies by state)', 'Civil Judge (Junior Division) in other states', NULL,
     'Generic entry for the remaining states. Age limits and procedures vary - always read that state''s notification.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Varies by state', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 35, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Typical: 21-35 (varies by state)');
CALL sp_seed_relax_central(0, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'LLB', NULL, NULL, NULL, NULL, FALSE, NULL, 3.0, @jud);

SELECT 'Law and judiciary exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'JUDICIARY_LAW') AS law_exams;
