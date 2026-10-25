-- ============================================================
-- AspirantOS - 21_seed_exams_design_science_research_agri.sql
-- Design & architecture (7 exams), science & research fellowships (7 exams; CSIR NET is in 16,
-- TIFR GS in 17) and agriculture & veterinary (3 exams). Uses 05_seed_helpers.sql. Re-runnable.
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the latest bulletin / notification known to the developer (2025-26). Confirm with the official website.';

CALL sp_seed_body('NID',      'National Institute of Design',                     'https://admissions.nid.edu',   'AUTONOMOUS');
CALL sp_seed_body('NIFT',     'National Institute of Fashion Technology',         'https://nift.ac.in',           'AUTONOMOUS');
CALL sp_seed_body('IIT_BOMBAY', 'IIT Bombay (UCEED / CEED organising institute)', 'https://www.uceed.iitb.ac.in', 'AUTONOMOUS');
CALL sp_seed_body('COA',      'Council of Architecture',                          'https://www.nata.in',          'AUTONOMOUS');
CALL sp_seed_body('FDDI',     'Footwear Design and Development Institute',        'https://fddiindia.com',        'AUTONOMOUS');
CALL sp_seed_body('PEARL',    'Pearl Academy',                                    'https://pearlacademy.com',     'PRIVATE');
CALL sp_seed_body('ICMR',     'Indian Council of Medical Research',               'https://www.icmr.gov.in',      'CENTRAL_GOVT');
CALL sp_seed_body('DBT',      'Department of Biotechnology (BET through NTA / RCB)', 'https://dbtindia.gov.in',   'CENTRAL_GOVT');
CALL sp_seed_body('ICAR',     'Indian Council of Agricultural Research',          'https://icar.org.in',          'AUTONOMOUS');
CALL sp_seed_body('ISI',      'Indian Statistical Institute',                     'https://www.isical.ac.in',     'AUTONOMOUS');
CALL sp_seed_body('CMI',      'Chennai Mathematical Institute',                   'https://www.cmi.ac.in',        'AUTONOMOUS');
CALL sp_seed_body('IISC',     'Indian Institute of Science, Bengaluru',           'https://iisc.ac.in',           'AUTONOMOUS');
CALL sp_seed_body('NBHM',     'National Board for Higher Mathematics (DAE)',      'https://nbhm.dae.gov.in',      'CENTRAL_GOVT');
CALL sp_seed_body('ASRB',     'Agricultural Scientists Recruitment Board',        'https://www.asrb.org.in',      'CENTRAL_GOVT');
CALL sp_seed_body('STATE_AGRI_UNIV', 'State Agricultural Universities (various)', NULL,                           'UNIVERSITY');

-- =================== DESIGN & ARCHITECTURE ===================

CALL sp_seed_exam('NID_DAT', 'NID Design Aptitude Test (B.Des and M.Des)', 'NID DAT', 'DESIGN_ARCH', 'NID',
     'NATIONAL', NULL, 'AUTONOMOUS', 'ADMISSION', 1.0, 10, 12,
     'DAT Prelims → DAT Mains (studio test / interview)', 'B.Des and M.Des at NID Ahmedabad, Bengaluru, Gandhinagar and the new NIDs', 'https://admissions.nid.edu',
     'Design entrance of the National Institutes of Design. B.Des has an upper age limit.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 3000 (Rs 1500 for SC, ST, PwBD)', 'No attempt limit within the age limit.');
CALL sp_seed_age_window('B.Des', NULL, 20, -20, 7, 1, NULL, NULL, NULL, 'B.Des: born on or after 1 July of (year - 20); 3 years relaxation for SC/ST/PwBD');
CALL sp_seed_age_window('M.Des', NULL, 30, -30, 7, 1, NULL, NULL, NULL, 'M.Des: born on or after 1 July of (year - 30); 3 years relaxation for SC/ST/PwBD');
CALL sp_seed_relax('CATEGORY', 'SC', 3, 'REPLACE_WITH_MAX', NULL, FALSE, '3 years relaxation');
CALL sp_seed_relax('CATEGORY', 'ST', 3, 'REPLACE_WITH_MAX', NULL, FALSE, '3 years relaxation');
CALL sp_seed_relax('PWBD', NULL, 3, 'REPLACE_WITH_MAX', NULL, FALSE, '3 years relaxation');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('B.Des', 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'B.Des: Class 12 in any stream (appearing allowed)');
CALL sp_seed_qual('M.Des', 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'M.Des: bachelor''s degree of 4 years (or 3 years + experience as per the bulletin)');

CALL sp_seed_exam('NIFT_ENTRANCE', 'NIFT Entrance Examination', 'NIFT Entrance', 'DESIGN_ARCH', 'NIFT',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 11, 2,
     'GAT + CAT (creative ability) → Situation test / interview', 'B.Des, B.FTech, M.Des, M.F.M and M.FTech at 19 NIFT campuses', 'https://nift.ac.in',
     'Fashion and design entrance. UG programmes have an upper age limit of 24.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 3000 (Rs 1500 for SC, ST, PwBD)', 'No attempt limit within the age limit.');
CALL sp_seed_age('UG (B.Des / B.FTech)', NULL, 24, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'UG: below 24 years on 1 August (5 years relaxation for SC/ST/PwBD)');
CALL sp_seed_age('PG (M.Des / M.F.M / M.FTech)', NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'PG: no age limit');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation (UG)');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation (UG)');
CALL sp_seed_relax('PWBD', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation (UG)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('UG (B.Des / B.FTech)', 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'B.Des: Class 12 any stream; B.FTech: Class 12 with Physics, Chemistry and Maths');
CALL sp_seed_qual('PG (M.Des / M.F.M / M.FTech)', 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'PG: graduation (B.FTech / B.E. for M.FTech)');

CALL sp_seed_exam('UCEED', 'Undergraduate Common Entrance Examination for Design', 'UCEED', 'DESIGN_ARCH', 'IIT_BOMBAY',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 10, 1,
     'Computer-based Part A + drawing Part B', 'B.Des at IIT Bombay, IIT Delhi, IIT Guwahati, IIT Hyderabad, IIITDM Jabalpur and others', 'https://www.uceed.iitb.ac.in',
     'Design entrance of the IITs: born on or after 1 October of (year - 24), at most 2 attempts in consecutive years.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 4000 (Rs 2000 for women, SC, ST, PwBD)', 'At most 2 attempts in 2 consecutive years.');
CALL sp_seed_age_window(NULL, NULL, 24, -24, 10, 1, NULL, NULL, NULL, 'Born on or after 1 October of (year - 24); 5 years relaxation for SC/ST/PwBD');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation');
CALL sp_seed_relax('PWBD', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation');
CALL sp_seed_attempt(NULL, NULL, 2, 'CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM', 2, NULL, 'At most 2 attempts in consecutive years');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, 1, NULL, 'Class 12 (any stream) passed this year or last year');

CALL sp_seed_exam('CEED', 'Common Entrance Examination for Design', 'CEED', 'DESIGN_ARCH', 'IIT_BOMBAY',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 10, 1,
     'Part A (computer-based) + Part B (drawing / design)', 'M.Des at IITs and IISc; PhD in design at some institutes', 'https://www.ceed.iitb.ac.in',
     'PG design entrance; no age limit and no attempt limit.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 4000 (Rs 2000 for women, SC, ST, PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'A 3-year degree / diploma (after Class 12) or appearing; or GD Arts diploma');

CALL sp_seed_exam('NATA', 'National Aptitude Test in Architecture', 'NATA', 'DESIGN_ARCH', 'COA',
     'NATIONAL', NULL, 'AUTONOMOUS', 'ADMISSION', 3.0, 2, 4,
     'Computer-based / drawing test (several sessions; up to 3 attempts per year)', 'B.Arch admission across India (with JEE Main Paper 2 as the alternative)', 'https://www.nata.in',
     'Architecture aptitude test of the Council of Architecture; held in several sessions from April to August.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1750 per attempt (Rs 1250 for SC/ST/PwBD)', 'Up to 3 attempts in a year; the best score is used.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, 3, 'PER_ROLLING_12_MONTHS', NULL, NULL, 'Up to 3 attempts per year');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,MATHS', 45, NULL, NULL, TRUE, NULL, NULL, 'Class 12 with Physics and Maths (45% aggregate) or a 10+3 diploma with Maths');

CALL sp_seed_exam('FDDI_AIST', 'FDDI All India Selection Test', 'FDDI AIST', 'DESIGN_ARCH', 'FDDI',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 1, 5,
     'Computer-based test → Counselling', 'B.Des and M.Des in footwear, fashion, leather goods and retail at 12 FDDI campuses', 'https://fddiindia.com',
     'Entrance of the Footwear Design and Development Institute.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 600 (Rs 300 for SC/ST)', 'One attempt per year.');
CALL sp_seed_age('UG (B.Des)', NULL, 25, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'UG: up to 25 years on 1 July');
CALL sp_seed_age('PG (M.Des)', NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'PG: no age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('UG (B.Des)', 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Class 12 in any stream');
CALL sp_seed_qual('PG (M.Des)', 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation in any discipline');

CALL sp_seed_exam('PEARL_ACADEMY', 'Pearl Academy Entrance Exam', 'Pearl Academy', 'DESIGN_ARCH', 'PEARL',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 4.0, NULL, NULL,
     'Online test → Personal interview (rolling rounds)', 'UG and PG in fashion, design, media and business at Pearl Academy', 'https://pearlacademy.com',
     'Private design school entrance held in several rounds a year.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('About Rs 2500', 'Several rounds a year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Class 12 (UG); graduation (PG)');

-- =================== SCIENCE & RESEARCH ===================

CALL sp_seed_exam('ICMR_JRF', 'ICMR Junior Research Fellowship Examination', 'ICMR JRF', 'SCIENCE_RESEARCH', 'ICMR',
     'NATIONAL', NULL, 'GOVERNMENT', 'FELLOWSHIP', 1.0, 6, 8,
     'Computer-based test (Life Sciences / Social Sciences)', 'Junior Research Fellowship for PhD in biomedical sciences', 'https://www.icmr.gov.in',
     'Fellowship test of the Indian Council of Medical Research; upper age 28.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1500 (Rs 1200 for SC/ST/PwBD/women)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, NULL, 28, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Up to 28 years on the closing date');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'REPLACE_WITH_MAX', NULL, FALSE, 'OBC: 3 years');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'SC/ST: 5 years');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'SC/ST: 5 years');
CALL sp_seed_relax('PWBD', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'PwBD: 5 years');
CALL sp_seed_relax('WOMEN', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'Women: 5 years');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'PG', 'M.Sc,M.A.,M.Tech,M.Pharm,MBBS,BDS', NULL, 55, 50, 'SC,ST,OBC_NCL,PWBD', TRUE, NULL, NULL, 'Master''s / professional degree in a relevant subject with 55% (50% reserved)');

CALL sp_seed_exam('DBT_BET', 'DBT Biotechnology Eligibility Test (JRF)', 'DBT BET', 'SCIENCE_RESEARCH', 'DBT',
     'NATIONAL', NULL, 'GOVERNMENT', 'FELLOWSHIP', 1.0, 3, 5,
     'Computer-based test (Part A + Part B)', 'DBT-JRF for PhD in biotechnology and life sciences', 'https://dbtindia.gov.in',
     'Fellowship test of the Department of Biotechnology.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1300 (Rs 650 for SC/ST/PwBD)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, NULL, 28, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 3, 31, 'Up to 28 years on the closing date');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'REPLACE_WITH_MAX', NULL, FALSE, 'OBC: 3 years');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'SC/ST: 5 years');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'SC/ST: 5 years');
CALL sp_seed_relax('PWBD', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'PwBD: 5 years');
CALL sp_seed_relax('WOMEN', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'Women: 5 years');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'PG', 'M.Sc,M.Tech,M.V.Sc,M.Pharm', 'BIOTECHNOLOGY|LIFE SCIENCES|BIOCHEMISTRY|MICROBIOLOGY|BIOINFORMATICS', 60, 55, 'SC,ST,OBC_NCL,PWBD', TRUE, NULL, NULL, 'M.Sc / M.Tech / M.V.Sc in biotechnology or life sciences with 60% (55% reserved)');

CALL sp_seed_exam('ICAR_AICE_PHD', 'ICAR AICE-JRF/SRF (PhD) Admission', 'ICAR AICE JRF/SRF', 'SCIENCE_RESEARCH', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'FELLOWSHIP', 1.0, 5, 7,
     'Computer-based test', 'PhD admission with JRF / SRF in agricultural universities', 'https://icar.nta.nic.in',
     'PhD entrance for agricultural sciences conducted by NTA for ICAR.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1875 (Rs 975 for SC/ST/PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No upper age limit for PhD admission (fellowship rules may apply)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'PG', 'M.Sc,M.Tech,M.V.Sc,MBA', 'AGRICULTURE|HORTICULTURE|FORESTRY|VETERINARY|FISHERIES|DAIRY|AGRICULTURAL ENGINEERING', 60, 50, 'SC,ST,PWBD', TRUE, NULL, NULL, 'Master''s in agriculture or an allied subject with OGPA 6.5/10 or 60% (lower for SC/ST/PwBD)');

CALL sp_seed_exam('ISI_ADMISSION', 'Indian Statistical Institute Admission Test', 'ISI Admission', 'SCIENCE_RESEARCH', 'ISI',
     'NATIONAL', NULL, 'AUTONOMOUS', 'ADMISSION', 1.0, 2, 5,
     'Written test (UGA / UGB, PGA / PGB) → Interview', 'B.Stat, B.Math, M.Stat, M.Math, M.S. (QE), JRF and others', 'https://www.isical.ac.in',
     'Admission test of the Indian Statistical Institute.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1500 (Rs 1000 for SC/ST/PwBD/women)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit for most programmes');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('B.Stat / B.Math', 'CLASS_12', 'ANY', 'MATHS,ENGLISH', NULL, NULL, NULL, TRUE, NULL, NULL, 'B.Stat / B.Math: Class 12 with Mathematics and English');
CALL sp_seed_qual('M.Stat / M.Math / M.S.', 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Masters: a 3-year bachelor''s degree as specified for each programme');

CALL sp_seed_exam('CMI_ENTRANCE', 'Chennai Mathematical Institute Entrance Examination', 'CMI Entrance', 'SCIENCE_RESEARCH', 'CMI',
     'NATIONAL', NULL, 'AUTONOMOUS', 'ADMISSION', 1.0, 2, 5,
     'Written test → Interview (PG / PhD)', 'B.Sc (Hons) Mathematics & CS / Maths & Physics, M.Sc, PhD', 'https://www.cmi.ac.in',
     'Entrance of the Chennai Mathematical Institute.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2400 (Rs 1200 for SC/ST/PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('B.Sc programmes', 'CLASS_12', 'ANY', 'MATHS', NULL, NULL, NULL, TRUE, NULL, NULL, 'B.Sc: Class 12 with Mathematics');
CALL sp_seed_qual('M.Sc / PhD', 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'M.Sc / PhD: bachelor''s degree in the relevant subject');

CALL sp_seed_exam('IISC_RESEARCH', 'IISc Research Programme Admissions (PhD / M.Tech Research)', 'IISc Research', 'SCIENCE_RESEARCH', 'IISC',
     'NATIONAL', NULL, 'AUTONOMOUS', 'ADMISSION', 2.0, 2, 5,
     'Shortlisting on GATE / NET / JEST score → Written test / interview', 'PhD and M.Tech (Research) at the Indian Institute of Science', 'https://iisc.ac.in',
     'Research admissions at IISc, twice a year; shortlisting uses national test scores.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1000 (Rs 500 for SC/ST/PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'B.E.,B.Tech,M.Sc,MBBS,M.E.,M.Tech', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'B.E./B.Tech, M.Sc, MBBS or equivalent + a valid GATE / NET / JEST score as per the department');
CALL sp_seed_other(NULL, 'REGISTRATION', 'GATE_NET_JEST', FALSE, 'A valid GATE / UGC-CSIR NET / JEST score is usually needed');

CALL sp_seed_exam('NBHM_PHD', 'NBHM PhD Scholarship Test', 'NBHM PhD Scholarship', 'SCIENCE_RESEARCH', 'NBHM',
     'NATIONAL', NULL, 'GOVERNMENT', 'SCHOLARSHIP', 1.0, 11, 1,
     'Written test → Interview', 'PhD scholarship in Mathematics', 'https://nbhm.dae.gov.in',
     'Scholarship test of the National Board for Higher Mathematics.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('No fee', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'PG', 'M.Sc,M.A.', 'MATHS', 55, NULL, NULL, TRUE, NULL, NULL, 'M.Sc / M.A. Mathematics with 55% (or 4-year B.S. / B.Tech with 60%)');

-- =================== AGRICULTURE & VETERINARY ===================

CALL sp_seed_exam('ICAR_AIEEA_PG', 'ICAR AIEEA PG (Masters Admission)', 'ICAR AIEEA PG', 'AGRICULTURE_VET', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 5, 7,
     'Computer-based test', 'Masters in agriculture and allied subjects with ICAR PG scholarship', 'https://icar.nta.nic.in',
     'PG entrance for agricultural universities. Minimum age 19 on 31 August.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1875 (Rs 975 for SC/ST/PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, 19, NULL, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 31, 'At least 19 years on 31 August; no upper age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'B.Sc,B.Tech,B.V.Sc,B.F.Sc', 'AGRICULTURE|HORTICULTURE|FORESTRY|VETERINARY|FISHERIES|DAIRY|AGRICULTURAL ENGINEERING|HOME SCIENCE', 60, 50, 'SC,ST,PWBD', TRUE, NULL, NULL, 'Bachelor''s in agriculture or an allied subject with OGPA 6.0/10 or 60% (5.0 / 50% for SC/ST/PwBD)');

CALL sp_seed_exam('ASRB_NET_ARS', 'ASRB NET / ARS / STO Examination', 'ASRB NET / ARS', 'AGRICULTURE_VET', 'ASRB',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 4, 6,
     'NET (eligibility) / ARS Prelims → Mains → Interview', 'National Eligibility Test (lecturer in agri universities), Agricultural Research Service scientists, Senior Technical Officer', 'https://www.asrb.org.in',
     'Agricultural Scientists Recruitment Board exams: NET has no age limit; ARS scientists 21-32.', 'LIKELY', @src);
CALL sp_seed_exam_info('NET Rs 1000; ARS Rs 1000 (reduced for SC/ST/PwBD/women)', 'No attempt limit within the age limit.');
CALL sp_seed_age('ARS Scientist', 21, 32, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 5, 1, 'ARS: 21-32 on the closing date');
CALL sp_seed_age('NET', NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'NET: no age limit');
CALL sp_seed_relax_central(0, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'PG', 'M.Sc,M.Tech,M.V.Sc,M.F.Sc', 'AGRICULTURE|HORTICULTURE|FORESTRY|VETERINARY|FISHERIES|DAIRY|AGRICULTURAL ENGINEERING', NULL, NULL, NULL, TRUE, NULL, NULL, 'Master''s degree in the relevant agricultural discipline');

CALL sp_seed_exam('STATE_AGRI_UG', 'State Agricultural University Entrance (UG) - generic', 'State Agri University Entrance', 'AGRICULTURE_VET', 'STATE_AGRI_UNIV',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, NULL, NULL,
     'State entrance (often through the state CET or CUET-ICAR)', 'B.Sc (Hons) Agriculture, Horticulture, B.V.Sc and other UG courses at state agricultural universities', NULL,
     'Generic entry: most states admit through their own CET; 20% seats in state universities go through ICAR (CUET UG).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Varies by state', 'One attempt per year.');
CALL sp_seed_age(NULL, 16, NULL, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 12, 31, 'Typical: at least 16-17 years on 31 December');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,BIOLOGY|MATHS|AGRICULTURE', 50, 40, 'SC,ST,OBC_NCL', TRUE, NULL, NULL, 'Class 12 with Physics, Chemistry and Biology / Maths / Agriculture, about 50% (lower for reserved)');

SELECT 'Design, science and agriculture exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'DESIGN_ARCH')      AS design,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'SCIENCE_RESEARCH') AS science,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'AGRICULTURE_VET')  AS agriculture;
