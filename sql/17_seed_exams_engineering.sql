-- ============================================================
-- AspirantOS - 17_seed_exams_engineering.sql
-- Engineering entrance (UG, 17 exams) and engineering PG / PSU / science recruitment (12 exams).
-- Uses 05_seed_helpers.sql. Re-runnable.
-- CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM: you may appear only in the Class 12 year and the
-- next (window_years - 1) years (JEE Main = 3 consecutive years, JEE Advanced = 2).
-- max_years_since_passing on the Class 12 row says the same for the qualification check.
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the latest information bulletin known to the developer (2025-26 session). Confirm with the current bulletin.';

CALL sp_seed_body('BITS',        'Birla Institute of Technology and Science, Pilani', 'https://www.bitsadmission.com', 'PRIVATE');
CALL sp_seed_body('VIT',         'Vellore Institute of Technology',                  'https://viteee.vit.ac.in',      'PRIVATE');
CALL sp_seed_body('SRM',         'SRM Institute of Science and Technology',          'https://www.srmist.edu.in',     'PRIVATE');
CALL sp_seed_body('COMEDK',      'Consortium of Medical, Engineering and Dental Colleges of Karnataka', 'https://www.comedk.org', 'PRIVATE');
CALL sp_seed_body('MH_CET_CELL', 'State Common Entrance Test Cell, Maharashtra',     'https://cetcell.mahacet.org',   'STATE_GOVT');
CALL sp_seed_body('WBJEEB',      'West Bengal Joint Entrance Examinations Board',    'https://wbjeeb.nic.in',         'STATE_GOVT');
CALL sp_seed_body('KEA',         'Karnataka Examinations Authority',                 'https://cetonline.karnataka.gov.in/kea', 'STATE_GOVT');
CALL sp_seed_body('APSCHE',      'Andhra Pradesh State Council of Higher Education', 'https://cets.apsche.ap.gov.in', 'STATE_GOVT');
CALL sp_seed_body('TGCHE',       'Telangana Council of Higher Education',            'https://eapcet.tgche.ac.in',    'STATE_GOVT');
CALL sp_seed_body('CEE_KERALA',  'Commissioner for Entrance Examinations, Kerala',   'https://cee.kerala.gov.in',     'STATE_GOVT');
CALL sp_seed_body('GSEB',        'Gujarat Secondary and Higher Secondary Education Board', 'https://gujcet.gseb.org',  'STATE_GOVT');
CALL sp_seed_body('OJEE_BOARD',  'Odisha Joint Entrance Examination Committee',      'https://ojee.nic.in',           'STATE_GOVT');
CALL sp_seed_body('MAHE',        'Manipal Academy of Higher Education',              'https://manipal.edu',           'PRIVATE');
CALL sp_seed_body('IISER',       'Indian Institutes of Science Education and Research','https://www.iiseradmission.in','AUTONOMOUS');
CALL sp_seed_body('NISER',       'NISER Bhubaneswar and UM-DAE CEBS Mumbai (NEST)',  'https://www.nestexam.in',       'AUTONOMOUS');
CALL sp_seed_body('ISRO',        'Indian Space Research Organisation (ICRB)',        'https://www.isro.gov.in',       'CENTRAL_GOVT');
CALL sp_seed_body('BARC',        'Bhabha Atomic Research Centre',                    'https://www.barconlineexam.in', 'CENTRAL_GOVT');
CALL sp_seed_body('DRDO',        'Defence Research and Development Organisation (CEPTAM)', 'https://www.drdo.gov.in', 'CENTRAL_GOVT');
CALL sp_seed_body('AAI',         'Airports Authority of India',                      'https://www.aai.aero',          'PSU');
CALL sp_seed_body('NIELIT',      'National Institute of Electronics and Information Technology', 'https://www.nielit.gov.in', 'AUTONOMOUS');
CALL sp_seed_body('CIL',         'Coal India Limited',                               'https://www.coalindia.in',      'PSU');
CALL sp_seed_body('FCI',         'Food Corporation of India',                        'https://fci.gov.in',            'PSU');
CALL sp_seed_body('JEST_BOARD',  'JEST (Science and Engineering Research Board)',    'https://www.jest.org.in',       'AUTONOMOUS');
CALL sp_seed_body('TIFR',        'Tata Institute of Fundamental Research',           'https://www.tifr.res.in',       'AUTONOMOUS');

-- =================== ENGINEERING ENTRANCE (UG) ===================

CALL sp_seed_exam('JEE_MAIN', 'Joint Entrance Examination (Main)', 'JEE Main', 'ENGINEERING_ENTRANCE', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 2.0, 10, 1,
     'Session 1 (January) and Session 2 (April); best score counts',
     'Paper 1: B.E./B.Tech at NITs, IIITs, GFTIs; Paper 2A: B.Arch; Paper 2B: B.Planning; also the qualifier for JEE Advanced', 'https://jeemain.nta.nic.in',
     'No age limit. You may appear in the year you pass Class 12 and the next two years (3 consecutive years), twice a year.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1000 (boys, General), Rs 800 (girls), Rs 500 (SC/ST/PwBD/transgender) per paper in India', 'Allowed only in 3 consecutive years starting with the Class 12 year; both sessions of a year may be taken.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM', 3, NULL, 'Class 12 year + the next 2 years');
CALL sp_seed_qual('Paper 1 (B.E. / B.Tech)', 'CLASS_12', 'ANY', 'PHYSICS,MATHS', NULL, NULL, NULL, TRUE, 2, NULL,
     'Class 12 passed in the last two years or appearing this year; NIT/IIIT admission needs Physics, Maths and one more science subject (75% / top-20 percentile criterion)');
CALL sp_seed_qual('Paper 2 (B.Arch / B.Planning)', 'CLASS_12', 'ANY', 'MATHS', NULL, NULL, NULL, TRUE, 2, NULL,
     'Class 12 with Mathematics (B.Arch: Physics, Chemistry, Maths) passed in the last two years or appearing');

CALL sp_seed_exam('JEE_ADVANCED', 'Joint Entrance Examination (Advanced)', 'JEE Advanced', 'ENGINEERING_ENTRANCE', 'IIT',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 4, 5,
     'Paper 1 + Paper 2 (same day) → JoSAA counselling',
     'B.Tech, BS, B.Arch and dual-degree programmes at the 23 IITs', 'https://jeeadv.ac.in',
     'Only the top ~2,50,000 JEE Main Paper 1 candidates may register. Born on or after 1 October of (year - 25); at most 2 attempts in 2 consecutive years.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 3200 (General), Rs 1600 (girls, SC, ST, PwBD)', 'Maximum 2 attempts in 2 consecutive years (the Class 12 year and the next).');
CALL sp_seed_age_window(NULL, NULL, 25, -25, 10, 1, NULL, NULL, NULL, 'Born on or after 1 October of (year - 25); SC/ST/PwBD get 5 years');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'Born on or after 1 October of (year - 30)');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'Born on or after 1 October of (year - 30)');
CALL sp_seed_relax('PWBD', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, 'Born on or after 1 October of (year - 30)');
CALL sp_seed_attempt(NULL, NULL, 2, 'CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM', 2, NULL, 'At most 2 attempts in 2 consecutive years');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,MATHS', NULL, NULL, NULL, TRUE, 1, NULL,
     'Class 12 with Physics, Chemistry and Mathematics, first appeared in the current or the previous year');
CALL sp_seed_other(NULL, 'REGISTRATION', 'JEE_MAIN_TOP_250000', FALSE, 'You must be among the top ~2,50,000 (all categories) in JEE Main Paper 1');
CALL sp_seed_other(NULL, 'OTHER', 'NOT_ALREADY_IIT', FALSE, 'Not eligible if you already accepted / joined an IIT seat earlier (with some exceptions)');

CALL sp_seed_exam('BITSAT', 'BITS Admission Test', 'BITSAT', 'ENGINEERING_ENTRANCE', 'BITS',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 2.0, 1, 5,
     'Computer-based test (Session 1 May, Session 2 June)', 'Integrated first degrees at BITS Pilani, Goa and Hyderabad', 'https://www.bitsadmission.com',
     'Entrance test of BITS Pilani. Needs high Class 12 marks in PCM/PCB.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 3500 (one session), Rs 5500 (both) for boys; Rs 3000 / Rs 4500 for girls', 'Two sessions per year; Class 12 of this year or the previous year only.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM', 2, NULL, 'Class 12 year or the next year');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,MATHS|BIOLOGY,ENGLISH', 75, NULL, NULL, TRUE, 1, NULL,
     'Class 12 with Physics, Chemistry, Maths (or Biology for B.Pharm) and English; 75% in PCM/PCB with at least 60% in each');

CALL sp_seed_exam('VITEEE', 'VIT Engineering Entrance Examination', 'VITEEE', 'ENGINEERING_ENTRANCE', 'VIT',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 1.0, 11, 4,
     'Computer-based test → Counselling', 'B.Tech at VIT Vellore, Chennai, AP and Bhopal', 'https://viteee.vit.ac.in',
     'Entrance test of VIT. Candidates must be born on or after 1 July of (year - 22).', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1350', 'One attempt per year.');
CALL sp_seed_age_window(NULL, NULL, 22, -22, 7, 1, NULL, NULL, NULL, 'Born on or after 1 July of (year - 22)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,MATHS|BIOLOGY', 60, 50, 'SC,ST', TRUE, NULL, NULL, 'Class 12 with PCM / PCB, 60% (50% for SC/ST and candidates from J&K, Ladakh and the North-East)');

CALL sp_seed_exam('SRMJEEE', 'SRM Joint Engineering Entrance Examination', 'SRMJEEE', 'ENGINEERING_ENTRANCE', 'SRM',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 3.0, 11, 4,
     'Online test in phases → Counselling', 'B.Tech at SRM Kattankulathur, Ramapuram, Vadapalani, NCR, AP and Sikkim', 'https://www.srmist.edu.in',
     'Entrance test of SRM IST, held in up to three phases.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1300', 'Up to three phases per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No specific age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,MATHS', 50, NULL, NULL, TRUE, NULL, NULL, 'Class 12 with Physics, Maths (+ Chemistry / Biology / CS) and 50% aggregate');

CALL sp_seed_exam('COMEDK_UGET', 'COMEDK Undergraduate Entrance Test', 'COMEDK UGET', 'ENGINEERING_ENTRANCE', 'COMEDK',
     'STATE', 'KA', 'PRIVATE', 'ADMISSION', 1.0, 2, 5,
     'Computer-based test → Counselling', 'B.E. at private engineering colleges of Karnataka', 'https://www.comedk.org',
     'Entrance test for private (unaided) engineering colleges in Karnataka, open to all states.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1950', 'One attempt per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,MATHS,ENGLISH', 45, 40, 'SC,ST,OBC_NCL', TRUE, NULL, NULL, 'Class 12 with Physics, Maths, English (+ Chemistry/Biology/CS), 45% in PCM (40% SC/ST/OBC of Karnataka)');

CALL sp_seed_exam('MHT_CET', 'Maharashtra Common Entrance Test (PCM / PCB)', 'MHT CET', 'ENGINEERING_ENTRANCE', 'MH_CET_CELL',
     'STATE', 'MH', 'GOVERNMENT', 'ADMISSION', 1.0, 1, 4,
     'Computer-based test (PCM and PCB groups) → CAP rounds', 'Engineering, Pharmacy and Agriculture degrees in Maharashtra', 'https://cetcell.mahacet.org',
     'State entrance for engineering and pharmacy in Maharashtra; open to all states (state quota needs MH domicile).', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1000 (Rs 800 for reserved categories of Maharashtra)', 'One attempt per year (two attempts were tried in 2026 - verify).');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,MATHS', 45, 40, 'SC,ST,OBC_NCL,PWBD', TRUE, NULL, NULL, 'Class 12 with Physics and Maths (+ Chemistry / Biology / technical subject), 45% (40% reserved of Maharashtra) for admission');
CALL sp_seed_other(NULL, 'DOMICILE', 'MH', FALSE, 'Anyone may appear; Maharashtra state-quota seats need MH domicile');

CALL sp_seed_exam('WBJEE', 'West Bengal Joint Entrance Examination', 'WBJEE', 'ENGINEERING_ENTRANCE', 'WBJEEB',
     'STATE', 'WB', 'GOVERNMENT', 'ADMISSION', 1.0, 12, 4,
     'OMR test (Maths, Physics + Chemistry) → Counselling', 'Engineering, Pharmacy and Architecture in West Bengal', 'https://wbjeeb.nic.in',
     'State engineering entrance of West Bengal. Minimum age 17 on 31 December.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 400 for SC/ST/OBC/PwBD)', 'One attempt per year.');
CALL sp_seed_age(NULL, 17, NULL, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 12, 31, 'At least 17 years on 31 December of the year');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,MATHS,ENGLISH', 45, 40, 'SC,ST,OBC_NCL,PWBD', TRUE, NULL, NULL, 'Class 12 with Physics, Maths, English (+ Chemistry/other), 45% (40% reserved)');
CALL sp_seed_other(NULL, 'DOMICILE', 'WB', FALSE, 'State seats are mainly for West Bengal domicile candidates');

CALL sp_seed_exam('KCET', 'Karnataka Common Entrance Test', 'KCET', 'ENGINEERING_ENTRANCE', 'KEA',
     'STATE', 'KA', 'GOVERNMENT', 'ADMISSION', 1.0, 1, 4,
     'OMR test → Counselling', 'Engineering, Agriculture, Pharmacy and other professional courses in Karnataka', 'https://cetonline.karnataka.gov.in/kea',
     'State entrance of Karnataka; government seats need Karnataka eligibility (study / domicile rules).', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 250 for SC/ST/Cat-1 of Karnataka)', 'One attempt per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,MATHS', 45, 40, 'SC,ST,OBC_NCL', TRUE, NULL, NULL, 'Class 12 with Physics and Maths (+ Chemistry/Biology/CS), 45% (40% reserved of Karnataka)');
CALL sp_seed_other(NULL, 'DOMICILE', 'KA', FALSE, 'Government seats need the Karnataka eligibility clauses (7 years study etc.)');

CALL sp_seed_exam('AP_EAPCET', 'Andhra Pradesh Engineering, Agriculture and Pharmacy Common Entrance Test', 'AP EAPCET', 'ENGINEERING_ENTRANCE', 'APSCHE',
     'STATE', 'AP', 'GOVERNMENT', 'ADMISSION', 1.0, 3, 5,
     'Computer-based test → Counselling', 'Engineering, Agriculture and Pharmacy in Andhra Pradesh', 'https://cets.apsche.ap.gov.in',
     'State entrance of Andhra Pradesh. Minimum age 16 on 31 December.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 600 (Rs 500 for BC, Rs 500 for SC/ST)', 'One attempt per year.');
CALL sp_seed_age(NULL, 16, NULL, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 12, 31, 'At least 16 years on 31 December (17 for some agri courses)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,MATHS', 45, 40, 'SC,ST,OBC_NCL', TRUE, NULL, NULL, 'Intermediate (Class 12) with Maths, Physics, Chemistry; 45% (40% reserved)');
CALL sp_seed_other(NULL, 'DOMICILE', 'AP', FALSE, 'Local / non-local status decides the seat quota');

CALL sp_seed_exam('TS_EAPCET', 'Telangana Engineering, Agriculture and Pharmacy Common Entrance Test', 'TS EAPCET', 'ENGINEERING_ENTRANCE', 'TGCHE',
     'STATE', 'TS', 'GOVERNMENT', 'ADMISSION', 1.0, 2, 5,
     'Computer-based test → Counselling', 'Engineering, Agriculture and Pharmacy in Telangana', 'https://eapcet.tgche.ac.in',
     'State entrance of Telangana. Minimum age 16 on 31 December.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 900 (Rs 500 for SC/ST/PwBD)', 'One attempt per year.');
CALL sp_seed_age(NULL, 16, NULL, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 12, 31, 'At least 16 years on 31 December');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,MATHS', 45, 40, 'SC,ST,OBC_NCL', TRUE, NULL, NULL, 'Intermediate with Maths, Physics, Chemistry; 45% (40% reserved)');
CALL sp_seed_other(NULL, 'DOMICILE', 'TS', FALSE, 'Local / non-local status decides the seat quota');

CALL sp_seed_exam('KEAM', 'Kerala Engineering Architecture Medical Entrance', 'KEAM', 'ENGINEERING_ENTRANCE', 'CEE_KERALA',
     'STATE', 'KL', 'GOVERNMENT', 'ADMISSION', 1.0, 1, 4,
     'Computer-based test (Engineering, Pharmacy) → Rank list (with Class 12 marks)', 'Engineering, Pharmacy, Architecture and medical allied allotments in Kerala', 'https://cee.kerala.gov.in',
     'State entrance of Kerala; the rank list also uses Class 12 marks. Minimum age 17 on 31 December.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 875 (Rs 375 for SC)', 'One attempt per year.');
CALL sp_seed_age(NULL, 17, NULL, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 12, 31, 'At least 17 years on 31 December');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,MATHS', 45, 40, 'SC,ST,OBC_NCL', TRUE, NULL, NULL, 'Class 12 with Physics, Chemistry, Maths; 45% in PCM (lower for reserved)');
CALL sp_seed_other(NULL, 'DOMICILE', 'KL', FALSE, 'Keralite / non-Keralite status decides the quota');

CALL sp_seed_exam('GUJCET', 'Gujarat Common Entrance Test', 'GUJCET', 'ENGINEERING_ENTRANCE', 'GSEB',
     'STATE', 'GJ', 'GOVERNMENT', 'ADMISSION', 1.0, 12, 3,
     'OMR test → ACPC admission (with Class 12 marks)', 'Engineering and Pharmacy degrees in Gujarat', 'https://gujcet.gseb.org',
     'State entrance of Gujarat for science-stream Class 12 students.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 350', 'One attempt per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,MATHS|BIOLOGY', NULL, NULL, NULL, TRUE, NULL, NULL, 'Class 12 science stream (Group A or B)');

CALL sp_seed_exam('OJEE', 'Odisha Joint Entrance Examination', 'OJEE', 'ENGINEERING_ENTRANCE', 'OJEE_BOARD',
     'STATE', 'OD', 'GOVERNMENT', 'ADMISSION', 1.0, 2, 5,
     'Computer-based test → Counselling', 'B.Pharm, lateral-entry B.Tech, MCA, MBA and other courses in Odisha', 'https://ojee.nic.in',
     'State entrance of Odisha; most B.Tech seats are filled through JEE Main.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1000', 'One attempt per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,MATHS|BIOLOGY', 45, 40, 'SC,ST', TRUE, NULL, NULL, 'Class 12 science with 45% (40% SC/ST) for B.Pharm / B.Tech courses');

CALL sp_seed_exam('MET_MANIPAL', 'Manipal Entrance Test', 'MET', 'ENGINEERING_ENTRANCE', 'MAHE',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 2.0, 10, 4,
     'Online test (two phases) → Counselling', 'B.Tech at Manipal Institute of Technology (Manipal, Bengaluru) and other MAHE programmes', 'https://manipal.edu',
     'Entrance test of Manipal Academy of Higher Education.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1500', 'Up to two attempts per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,MATHS,ENGLISH', 50, NULL, NULL, TRUE, NULL, NULL, 'Class 12 with Physics, Maths, English (+ Chemistry/Biology/CS), 50% in PCM');

CALL sp_seed_exam('IISER_IAT', 'IISER Aptitude Test', 'IISER IAT', 'ENGINEERING_ENTRANCE', 'IISER',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 3, 5,
     'Computer-based aptitude test → Counselling', 'BS-MS dual degree at the 7 IISERs and IISc BS / IIT Madras BS', 'https://www.iiseradmission.in',
     'Admission test for BS-MS science programmes at IISERs. Class 12 of this year or the previous year.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2000 (Rs 1000 for SC/ST/PwBD/Kashmiri migrants)', 'Only in the Class 12 year or the next year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM', 2, NULL, 'Class 12 year or the next year');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS|CHEMISTRY|MATHS|BIOLOGY', 60, 55, 'SC,ST,PWBD', TRUE, 1, NULL, 'Class 12 science stream with 60% (55% SC/ST/PwBD), passed this year or last year');

CALL sp_seed_exam('NEST', 'National Entrance Screening Test', 'NEST', 'ENGINEERING_ENTRANCE', 'NISER',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 2, 6,
     'Computer-based test → Counselling', '5-year integrated M.Sc at NISER Bhubaneswar and UM-DAE CEBS Mumbai', 'https://www.nestexam.in',
     'Science entrance with a DOB rule: born on or after 1 August of (year - 20), 5 years relaxation for SC/ST/PwBD.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1400 (Rs 700 for SC/ST/PwBD/girls)', 'Only in the Class 12 year or the next year.');
CALL sp_seed_age_window(NULL, NULL, 20, -20, 8, 1, NULL, NULL, NULL, 'Born on or after 1 August of (year - 20)');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation');
CALL sp_seed_relax('PWBD', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation');
CALL sp_seed_attempt(NULL, NULL, NULL, 'CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM', 2, NULL, 'Class 12 year or the next year');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS|CHEMISTRY|MATHS|BIOLOGY', 60, 55, 'SC,ST,PWBD', TRUE, 1, NULL, 'Class 12 science stream with 60% (55% SC/ST/PwBD)');

-- =================== ENGINEERING PG / PSU / SCIENCE RECRUITMENT ===================

CALL sp_seed_exam('GATE', 'Graduate Aptitude Test in Engineering', 'GATE', 'ENGINEERING_PG_PSU', 'IIT',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 8, 2,
     'Computer-based test (1 or 2 papers) → M.Tech / PhD counselling or PSU interviews',
     'M.Tech / M.E. / direct PhD admission, scholarships and PSU recruitment (IOCL, NTPC, BHEL, PGCIL and others)', 'https://gate.iitr.ac.in',
     'No age limit. Students in the third year of a UG programme or later may appear. Score valid for 3 years.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2000 per paper (Rs 1000 for women, SC, ST, PwBD) in the regular period', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'In the 3rd year or higher of any UG degree (engineering, science, commerce, arts), or already graduated');

CALL sp_seed_exam('ISRO_SCIENTIST', 'ISRO Scientist / Engineer ''SC'' (ICRB)', 'ISRO Scientist SC', 'ENGINEERING_PG_PSU', 'ISRO',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 5, 8,
     'Written test → Interview', 'Scientist / Engineer SC (Electronics, Mechanical, Computer Science, Civil, Electrical)', 'https://www.isro.gov.in/Careers.html',
     'Recruitment of engineers by ISRO''s Centralised Recruitment Board (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 250 (refundable for those who appear)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, NULL, 28, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 6, 1, 'Up to 28 years on the closing date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'B.E.,B.Tech', NULL, 65, NULL, NULL, TRUE, NULL, NULL, 'B.E./B.Tech with 65% average (CGPA 6.84/10) in the relevant branch');

CALL sp_seed_exam('BARC_OCES', 'BARC OCES / DGFS (Orientation Course for Engineering Graduates and Science Postgraduates)', 'BARC OCES', 'ENGINEERING_PG_PSU', 'BARC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 2, 4,
     'Online exam or GATE score → Interview → 1-year training', 'Scientific Officer (C) in DAE units after OCES / DGFS', 'https://www.barconlineexam.in',
     'Training-cum-recruitment of the Department of Atomic Energy.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500 (exempt for women, SC, ST, PwBD)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, NULL, 26, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'General: up to 26 years on 1 August');
CALL sp_seed_relax_central(0, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'B.E.,B.Tech,B.Sc (Engg),5-year integrated M.Tech', NULL, 60, NULL, NULL, TRUE, NULL, NULL, 'OCES: engineering degree with 60%');
CALL sp_seed_qual(NULL, 'PG', 'M.Sc', 'PHYSICS|CHEMISTRY|BIOSCIENCES|GEOLOGY', 60, NULL, NULL, TRUE, NULL, NULL, 'DGFS / science: M.Sc with 60% in the relevant subject');

CALL sp_seed_exam('DRDO_CEPTAM', 'DRDO CEPTAM (Senior Technical Assistant-B and Technician-A)', 'DRDO CEPTAM', 'ENGINEERING_PG_PSU', 'DRDO',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 4, 8,
     'Tier I (CBT) → Tier II (CBT / trade test)', 'Senior Technical Assistant-B (STA-B); Technician-A (Tech-A)', 'https://www.drdo.gov.in',
     'Technical support staff recruitment of DRDO (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 100; exempt for women, SC, ST, PwBD and ex-servicemen', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 28, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 6, 1, 'Age 18-28 on the closing date');
CALL sp_seed_relax_ssc(TRUE, FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual('STA-B', 'UG', 'B.Sc', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'STA-B: B.Sc in the subject or a 3-year engineering diploma');
CALL sp_seed_qual('Tech-A', 'CLASS_10', 'ANY', 'ITI', NULL, NULL, NULL, FALSE, NULL, NULL, 'Tech-A: Class 10 + ITI in the trade');

CALL sp_seed_exam('AAI_JE', 'AAI Junior Executive (ATC, Airport Operations, Technical and others)', 'AAI Junior Executive', 'ENGINEERING_PG_PSU', 'AAI',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 3, 5,
     'Online exam (or GATE score for engineering posts) → Document verification / voice test', 'Junior Executive (Air Traffic Control, Airport Operations, Electronics, Civil, Electrical, IT)', 'https://www.aai.aero',
     'Executive recruitment of the Airports Authority of India.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1000 (exempt for women, SC, ST, PwBD, AAI apprentices)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, NULL, 27, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 4, 1, 'Up to 27 years on the closing date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'B.Sc', 'CLASS_12:PHYSICS,MATHS', NULL, NULL, NULL, FALSE, NULL, NULL, 'ATC: 3-year B.Sc with Physics and Maths');
CALL sp_seed_qual(NULL, 'UG', 'B.E.,B.Tech', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'ATC: or an engineering degree (with Physics and Maths in any semester)');

CALL sp_seed_exam('IIT_JAM', 'Joint Admission Test for Masters', 'IIT JAM', 'ENGINEERING_PG_PSU', 'IIT',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 9, 2,
     'Computer-based test (7 subject papers) → JOAPS counselling', 'M.Sc, joint M.Sc-PhD and other PG science programmes at IITs, IISc and other CFTIs', 'https://jam.iitr.ac.in',
     'Science PG entrance with no age limit; final-year UG students may appear.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2000 for one paper (Rs 1000 for women, SC, ST, PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', 'PHYSICS|CHEMISTRY|MATHS|BIOLOGY|BIOTECHNOLOGY|GEOLOGY|ECONOMICS|STATISTICS', NULL, NULL, NULL, TRUE, NULL, NULL, 'Bachelor''s degree in the relevant subject; admission needs 55% (50% SC/ST/PwBD)');

CALL sp_seed_exam('JEST', 'Joint Entrance Screening Test', 'JEST', 'ENGINEERING_PG_PSU', 'JEST_BOARD',
     'NATIONAL', NULL, 'AUTONOMOUS', 'ADMISSION', 1.0, 12, 3,
     'Online test → Institute interviews', 'PhD / Integrated PhD in Physics, Theoretical Computer Science and Neuroscience at research institutes', 'https://www.jest.org.in',
     'Screening test used by about 30 research institutes for PhD admissions.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1000 (Rs 500 for women, SC, ST)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'B.Sc,B.E.,B.Tech,M.Sc', 'PHYSICS|MATHS|COMPUTER SCIENCE|ELECTRONICS', NULL, NULL, NULL, TRUE, NULL, NULL, 'B.Sc / M.Sc / B.E. / B.Tech in Physics, Maths, CS or related (as per the programme)');

CALL sp_seed_exam('TIFR_GS', 'TIFR Graduate School Admissions', 'TIFR GS', 'ENGINEERING_PG_PSU', 'TIFR',
     'NATIONAL', NULL, 'AUTONOMOUS', 'ADMISSION', 1.0, 9, 12,
     'Written test → Interview', 'PhD, Integrated M.Sc-PhD and M.Sc in Mathematics, Physics, Chemistry, Biology, CS at TIFR, NCBS, ICTS and others', 'https://www.tifr.res.in',
     'Graduate school entrance of the Tata Institute of Fundamental Research.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1500 (men), Rs 500 (women)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'B.Sc / B.Tech / M.Sc / MBBS etc. depending on the subject and programme');

CALL sp_seed_exam('NIELIT_SCIENTIST_B', 'NIELIT Scientist B (for MeitY and associated bodies)', 'NIELIT Scientist B', 'ENGINEERING_PG_PSU', 'NIELIT',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 3, 7,
     'Written test → Interview', 'Scientist B and Scientific / Technical Assistant in MeitY, NIC, STQC, CERT-In', 'https://www.nielit.gov.in',
     'Irregular recruitment of IT scientists for the Ministry of Electronics and IT.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 800 (exempt for women, SC, ST, PwBD)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, NULL, 35, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 4, 1, 'Up to 35 years (Scientist B, recent notices)');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'B.E.,B.Tech', 'COMPUTER SCIENCE|INFORMATION TECHNOLOGY|ELECTRONICS', NULL, NULL, NULL, FALSE, NULL, NULL, 'B.E./B.Tech in CS / IT / Electronics, or M.Sc / MCA / M.E. in those fields');

CALL sp_seed_exam('CIL_MT', 'Coal India Management Trainee', 'CIL MT', 'ENGINEERING_PG_PSU', 'CIL',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 3, 4,
     'GATE score (engineering) or CBT (non-engineering) → Document verification', 'Management Trainee in Mining, Electrical, Mechanical, Civil, Finance, HR, System and other disciplines', 'https://www.coalindia.in',
     'Executive recruitment of Coal India; engineering disciplines are selected through GATE.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1180 (exempt for SC, ST, PwBD, ex-servicemen and CIL employees)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, NULL, 30, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 31, 'Up to 30 years on the cut-off date');
CALL sp_seed_relax_central(0, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'B.E.,B.Tech,B.Sc (Engg)', NULL, 60, NULL, NULL, FALSE, NULL, NULL, 'Engineering disciplines: B.E./B.Tech with 60% and a valid GATE score');
CALL sp_seed_qual(NULL, 'PROFESSIONAL', 'CA,CMA', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Finance: CA or CMA');
CALL sp_seed_other(NULL, 'REGISTRATION', 'GATE', FALSE, 'Engineering disciplines need a GATE score of the given year');

CALL sp_seed_exam('FCI_MANAGER', 'FCI Manager (General, Depot, Movement, Accounts, Technical, Civil, Electrical, Hindi)', 'FCI Manager', 'ENGINEERING_PG_PSU', 'FCI',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 8, 10,
     'Phase I → Phase II → Interview', 'Manager (Category II) in different disciplines', 'https://fci.gov.in',
     'Officer recruitment of the Food Corporation of India (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 800 (exempt for SC, ST, PwBD, women)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, NULL, 28, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Manager (General / Depot / Movement / Accounts / Technical / Civil / Electrical): up to 28; Hindi up to 35');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 60, 55, 'SC,ST,PWBD', FALSE, NULL, NULL, 'Manager (General / Depot / Movement): graduation with 60% (55% SC/ST/PwBD) or CA/CS/CMA');

CALL sp_seed_exam('FCI_AG3', 'FCI Assistant Grade III (General, Accounts, Technical, Depot, Hindi)', 'FCI AG-III', 'ENGINEERING_PG_PSU', 'FCI',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 8, 10,
     'Phase I → Phase II (+ typing for Hindi)', 'Assistant Grade III (zone-wise)', 'https://fci.gov.in',
     'Staff recruitment of the Food Corporation of India (irregular, zone-wise).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 500 (exempt for SC, ST, PwBD, women)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 27, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 18-27 (AG-III Hindi up to 28)');
CALL sp_seed_relax_ssc(TRUE, FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Graduation (B.Com for Accounts, B.Sc Agriculture / Botany etc. for Technical)');

SELECT 'Engineering exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'ENGINEERING_ENTRANCE') AS ug_entrance,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'ENGINEERING_PG_PSU')   AS pg_psu;
