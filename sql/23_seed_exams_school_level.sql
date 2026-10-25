-- ============================================================
-- AspirantOS - 23_seed_exams_school_level.sql
-- School-level admission and scholarship tests (6 exams), university entrance tests (6 exams)
-- and hotel management (NCHM JEE). Uses 05_seed_helpers.sql. Re-runnable.
-- School tests mostly use a date-of-birth window or an age range on 31 March of the admission
-- year, which makes them good test cases for the DOB_WINDOW logic.
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the latest prospectus / bulletin known to the developer (2025-26). Confirm with the official website.';

CALL sp_seed_body('RMS',      'Rashtriya Military Schools (Ministry of Defence)', 'https://www.rashtriyamilitaryschools.edu.in', 'CENTRAL_GOVT');
CALL sp_seed_body('NMMS_STATE', 'State SCERTs / Ministry of Education (NMMS)',  'https://scholarships.gov.in',  'STATE_GOVT');
CALL sp_seed_body('IAPT',     'Indian Association of Physics Teachers (with HBCSE)', 'https://www.iapt.org.in', 'AUTONOMOUS');
CALL sp_seed_body('IGNOU',    'Indira Gandhi National Open University',        'https://ignou.ac.in',          'UNIVERSITY');
CALL sp_seed_body('AMU',      'Aligarh Muslim University',                     'https://www.amucontrollerexams.com', 'UNIVERSITY');
CALL sp_seed_body('JMI',      'Jamia Millia Islamia',                          'https://admission.jmi.ac.in',  'UNIVERSITY');
CALL sp_seed_body('IIMC',     'Indian Institute of Mass Communication',        'https://iimc.gov.in',          'AUTONOMOUS');
CALL sp_seed_body('NCHMCT',   'National Council for Hotel Management and Catering Technology', 'https://nchmjee.nta.nic.in', 'AUTONOMOUS');

-- =================== SCHOOL LEVEL ===================

CALL sp_seed_exam('JNVST_6', 'Jawahar Navodaya Vidyalaya Selection Test - Class VI', 'JNVST Class 6', 'SCHOOL_LEVEL', 'NVS',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 6, 1,
     'Single selection test (mental ability, arithmetic, language)', 'Class VI admission in Jawahar Navodaya Vidyalayas (free residential schools)', 'https://navodaya.gov.in',
     'For students of Class V in the same district. Born between 1 May (year-12) and 31 July (year-10).', 'LIKELY', @src);
CALL sp_seed_exam_info('No fee', 'A student can appear only once.');
CALL sp_seed_age_window(NULL, 9, 13, -12, 5, 1, -10, 7, 31, 'Born between 1 May (year-12) and 31 July (year-10), both days included');
CALL sp_seed_attempt(NULL, NULL, 1, 'LIFETIME_TOTAL', NULL, NULL, 'Only one chance');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Studying in Class V in a government / recognised school of the same district');
CALL sp_seed_other(NULL, 'OTHER', 'STUDYING_CLASS_5', FALSE, 'Must be studying in Class V in the district where you apply; 75% seats for rural students');

CALL sp_seed_exam('JNVST_9', 'Jawahar Navodaya Vidyalaya Selection Test - Class IX (Lateral Entry)', 'JNVST Class 9', 'SCHOOL_LEVEL', 'NVS',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 9, 2,
     'Single selection test (English, Hindi, Maths, Science)', 'Class IX lateral-entry admission in Navodaya Vidyalayas', 'https://navodaya.gov.in',
     'For students of Class VIII. Born between 1 May (year-15) and 31 July (year-13).', 'LIKELY', @src);
CALL sp_seed_exam_info('No fee', 'One chance.');
CALL sp_seed_age_window(NULL, 13, 15, -15, 5, 1, -13, 7, 31, 'Born between 1 May (year-15) and 31 July (year-13)');
CALL sp_seed_attempt(NULL, NULL, 1, 'LIFETIME_TOTAL', NULL, NULL, 'Only one chance');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Studying in Class VIII in the same district');
CALL sp_seed_other(NULL, 'OTHER', 'STUDYING_CLASS_8', FALSE, 'Must be studying in Class VIII in the district where you apply');

CALL sp_seed_exam('AISSEE', 'All India Sainik Schools Entrance Examination', 'AISSEE', 'SCHOOL_LEVEL', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 12, 4,
     'Pen-and-paper test → Medical → Counselling', 'Class VI and Class IX admission in Sainik Schools (girls in Class VI)', 'https://exams.nta.ac.in/AISSEE',
     'Admission to Sainik Schools that prepare students for NDA. Age is counted on 31 March of the admission year.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 800 (Rs 650 for SC/ST)', 'One attempt per year within the age range.');
CALL sp_seed_age('Class VI', 10, 12, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 3, 31, 'Class VI: 10-12 years on 31 March of the admission year (boys and girls)');
CALL sp_seed_age('Class IX', 13, 15, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 3, 31, 'Class IX: 13-15 years on 31 March');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'One sitting per year');
CALL sp_seed_qual('Class VI', 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Class VI: no exam-pass requirement (studying in Class V)');
CALL sp_seed_qual('Class IX', 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Class IX: passing Class VIII from a recognised school');

CALL sp_seed_exam('RMS_CET', 'Rashtriya Military Schools Common Entrance Test', 'RMS CET', 'SCHOOL_LEVEL', 'RMS',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 9, 12,
     'Written test → Interview → Medical', 'Class VI and Class IX admission in the 5 Rashtriya Military Schools', 'https://www.rashtriyamilitaryschools.edu.in',
     'Military boarding schools (CBSE). 70% seats for wards of defence personnel.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 500 (Rs 350 for SC/ST)', 'One attempt per year within the age range.');
CALL sp_seed_age('Class VI', 10, 12, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 3, 31, 'Class VI: 10-12 years on 31 March of the admission year');
CALL sp_seed_age('Class IX', 13, 15, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 3, 31, 'Class IX: 13-15 years on 31 March');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'One sitting per year');
CALL sp_seed_qual('Class VI', 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Class VI: studying in / passed Class V');
CALL sp_seed_qual('Class IX', 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Class IX: studying in / passed Class VIII');

CALL sp_seed_exam('NMMS', 'National Means-cum-Merit Scholarship Examination', 'NMMS', 'SCHOOL_LEVEL', 'NMMS_STATE',
     'NATIONAL', NULL, 'GOVERNMENT', 'SCHOLARSHIP', 1.0, 9, 12,
     'MAT + SAT (state-level test)', 'Rs 12,000 per year scholarship for Classes IX-XII', 'https://scholarships.gov.in',
     'For Class VIII students of government / aided schools whose family income is below Rs 3.5 lakh a year.', 'LIKELY', @src);
CALL sp_seed_exam_info('Varies by state (usually free or nominal)', 'One chance (while in Class VIII).');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age rule - class-based');
CALL sp_seed_attempt(NULL, NULL, 1, 'LIFETIME_TOTAL', NULL, NULL, 'Only while studying in Class VIII');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Studying in Class VIII with 55% in Class VII (50% SC/ST)');
CALL sp_seed_other(NULL, 'OTHER', 'STUDYING_CLASS_8', FALSE, 'Must be in Class VIII of a government / government-aided / local body school');
CALL sp_seed_other(NULL, 'OTHER', 'FAMILY_INCOME_BELOW_3_5_LAKH', FALSE, 'Parental income must not exceed Rs 3.5 lakh per year');

CALL sp_seed_exam('NSE_OLYMPIADS', 'National Standard Examinations (NSEP, NSEC, NSEB, NSEA, NSEJS) - Olympiad Stage 1', 'Science Olympiads (NSE)', 'SCHOOL_LEVEL', 'IAPT',
     'NATIONAL', NULL, 'AUTONOMOUS', 'SCHOLARSHIP', 1.0, 8, 11,
     'NSE (Stage 1) → INO (Stage 2) → OCSC camp → International Olympiad', 'Stage 1 of the Indian Olympiad programme in Physics, Chemistry, Biology, Astronomy and Junior Science', 'https://www.iapt.org.in',
     'Olympiad selection for school students; NSEJS is for Class 10 and below, the others for Class 12 and below.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('About Rs 250 per subject (through the school / centre)', 'One sitting per year while in school.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'Class-based; the international olympiads also have a birth-date limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'Once a year while in school');
CALL sp_seed_qual('NSEJS (Junior Science)', 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Studying in Class 10 or below');
CALL sp_seed_qual('NSEP / NSEC / NSEB / NSEA', 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Studying in Class 12 or below (not yet finished school)');
CALL sp_seed_other(NULL, 'OTHER', 'STILL_IN_SCHOOL', FALSE, 'Only for students who have not yet finished Class 12');

-- =================== UNIVERSITY ENTRANCE ===================

CALL sp_seed_exam('CUET_UG', 'Common University Entrance Test (UG)', 'CUET UG', 'UNIVERSITY_ENTRANCE', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 2, 5,
     'Computer-based test (languages, domain subjects, general test)', 'UG admission in central universities (DU, BHU, JNU, AMU and others) and 250+ universities; ICAR UG seats', 'https://cuet.nta.nic.in',
     'No age limit. Students passing or appearing in Class 12 may apply; universities set their own subject rules.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1000 for up to 3 subjects (General); lower for OBC/EWS/SC/ST/PwBD', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Class 12 passed or appearing (the university decides the minimum marks)');

CALL sp_seed_exam('CUET_PG', 'Common University Entrance Test (PG)', 'CUET PG', 'UNIVERSITY_ENTRANCE', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 12, 3,
     'Computer-based test (subject papers)', 'PG admission in central and other universities; also used by IIMC and others', 'https://exams.nta.ac.in/CUET-PG',
     'PG entrance for central universities; final-year UG students may apply.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1400 for 2 papers (General); lower for OBC/EWS/SC/ST/PwBD', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Bachelor''s degree passed or final year (the university decides the subject and marks)');

CALL sp_seed_exam('IGNOU_ENTRANCE', 'IGNOU Entrance Tests (B.Ed / B.Sc Nursing PB / PhD)', 'IGNOU Entrance', 'UNIVERSITY_ENTRANCE', 'IGNOU',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 9, 12,
     'Entrance test → Merit list', 'B.Ed, Post-Basic B.Sc Nursing, PhD and other entrance-based IGNOU programmes', 'https://ignou.ac.in',
     'Open-university entrance tests. OPENMAT (MBA) was replaced by direct / other modes - check the current prospectus.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('About Rs 1000 per test', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('B.Ed', 'UG', 'ANY', NULL, 50, 45, 'SC,ST,OBC_NCL,PWBD', FALSE, NULL, NULL, 'B.Ed: graduation / PG with 50% (45% reserved) and trained in-service teachers or NCTE-recognised training');
CALL sp_seed_qual('PhD', 'PG', 'ANY', NULL, 55, 50, 'SC,ST,OBC_NCL,PWBD', FALSE, NULL, NULL, 'PhD: Master''s degree with 55% (50% reserved)');

CALL sp_seed_exam('AMU_ENTRANCE', 'Aligarh Muslim University Admission Tests', 'AMU Entrance', 'UNIVERSITY_ENTRANCE', 'AMU',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 2, 5,
     'Course-wise admission tests (some courses use CUET)', 'B.Tech, B.Arch, BA LLB, B.Com, B.Sc, MBA, school classes and other AMU programmes', 'https://www.amucontrollerexams.com',
     'AMU''s own admission tests for many programmes (others are through CUET / NEET / JEE).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('About Rs 500-1100 per test', 'One attempt per year per course.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No general age limit (some courses have one)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('UG courses', 'CLASS_12', 'ANY', NULL, 50, NULL, NULL, TRUE, NULL, NULL, 'UG courses: Class 12 with the required subjects and about 50%');
CALL sp_seed_qual('PG courses', 'UG', 'ANY', NULL, 50, NULL, NULL, TRUE, NULL, NULL, 'PG courses: graduation with the required subjects and about 50%');

CALL sp_seed_exam('JMI_ENTRANCE', 'Jamia Millia Islamia Entrance Tests', 'JMI Entrance', 'UNIVERSITY_ENTRANCE', 'JMI',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 3, 5,
     'Course-wise entrance tests (some courses use CUET)', 'B.Arch, BA LLB, MBA, MA Mass Communication, B.Ed and other JMI programmes', 'https://admission.jmi.ac.in',
     'Jamia''s own entrance tests for many programmes; others are through CUET.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('About Rs 600-1000 per test', 'One attempt per year per course.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No general age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual('UG courses', 'CLASS_12', 'ANY', NULL, 50, NULL, NULL, TRUE, NULL, NULL, 'UG courses: Class 12 with about 50%');
CALL sp_seed_qual('PG courses', 'UG', 'ANY', NULL, 50, NULL, NULL, TRUE, NULL, NULL, 'PG courses: graduation with about 50%');

CALL sp_seed_exam('IIMC_ENTRANCE', 'IIMC PG Diploma Admission', 'IIMC Admission', 'UNIVERSITY_ENTRANCE', 'IIMC',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 3, 6,
     'CUET PG score → Group discussion / interview', 'PG Diploma in Journalism, Advertising & PR, Radio & TV Journalism, Digital Media', 'https://iimc.gov.in',
     'Media school of the Government of India; admissions now use the CUET PG score.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Through CUET PG', 'One attempt per year.');
CALL sp_seed_age(NULL, NULL, 25, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Up to 25 years on 1 August (relaxation for reserved categories)');
CALL sp_seed_relax_central(0, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation in any discipline (final-year allowed)');
CALL sp_seed_other(NULL, 'REGISTRATION', 'CUET_PG', FALSE, 'You must appear in CUET PG with the IIMC paper');

-- =================== HOTEL MANAGEMENT ===================

CALL sp_seed_exam('NCHM_JEE', 'NCHM Joint Entrance Examination', 'NCHM JEE', 'HOTEL_MGMT', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 2, 4,
     'Computer-based test → Counselling', 'B.Sc Hospitality & Hotel Administration at IHMs (central, state, private)', 'https://nchmjee.nta.nic.in',
     'Hotel management entrance for Institutes of Hotel Management. Upper age 25 (28 for SC/ST/PwBD).', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1000 (General / OBC), Rs 700 (EWS), Rs 450 (SC / ST / PwBD)', 'One attempt per year within the age limit.');
CALL sp_seed_age(NULL, NULL, 25, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'General / OBC: up to 25 years on 1 July');
CALL sp_seed_relax('CATEGORY', 'SC', 3, 'REPLACE_WITH_MAX', NULL, FALSE, 'SC/ST: up to 28');
CALL sp_seed_relax('CATEGORY', 'ST', 3, 'REPLACE_WITH_MAX', NULL, FALSE, 'SC/ST: up to 28');
CALL sp_seed_relax('PWBD', NULL, 3, 'REPLACE_WITH_MAX', NULL, FALSE, 'PwBD: up to 28');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'ENGLISH', NULL, NULL, NULL, TRUE, NULL, NULL, 'Class 12 in any stream with English as a subject; appearing students may apply');

SELECT 'School, university and hotel management exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'SCHOOL_LEVEL')        AS school,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'UNIVERSITY_ENTRANCE') AS university,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'HOTEL_MGMT')          AS hotel;
