-- ============================================================
-- AspirantOS - 11_seed_exams_upsc.sql
-- Exams conducted by UPSC (10 exams): CSE, IFoS, ESE, CMS, CAPF AC,
-- IES/ISS, Combined Geo-Scientist, EPFO, NDA & NA, CDS.
-- Uses the helper procedures from 05_seed_helpers.sql. Re-runnable.
-- Rules = latest notifications known to the developer (2025-26 cycle);
-- data_confidence says how sure we are. Always confirm with the official notification.
-- Subjects: comma = all required, '|' = any one, 'CLASS_12:' = checked on the Class 12 row.
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the latest UPSC notification known to the developer (2025-26 cycle). Confirm with the current notification on upsc.gov.in.';
SET @nat_upsc = 'INDIAN,NEPAL,BHUTAN,TIBETAN_REFUGEE,PIO';

-- ---------- UPSC Civil Services Examination ----------
CALL sp_seed_exam('UPSC_CSE', 'Civil Services Examination', 'UPSC CSE', 'CIVIL_SERVICES', 'UPSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 1, 5,
     'Preliminary (objective) → Main (written) → Personality Test',
     'IAS, IPS, IFS, IRS and other Group A / Group B central services',
     'https://upsc.gov.in/examinations/active-exams',
     'The flagship exam for the All India Services and central Group A services. Prelims is usually held in late May, Mains in August/September and interviews from January to April.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST and PwBD candidates',
     'Appearing in at least one paper of the Preliminary examination counts as an attempt. Only applying (or being absent) does not count.');
CALL sp_seed_age(NULL, 21, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1,
     'Must have attained 21 and must not have attained 32 years on 1 August of the exam year');
CALL sp_seed_relax_central(5, 'ADD', TRUE);
CALL sp_seed_attempt('GEN',     FALSE, 6,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'General: 6 attempts');
CALL sp_seed_attempt('EWS',     FALSE, 6,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'EWS: 6 attempts');
CALL sp_seed_attempt('GEN',     TRUE,  9,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'General PwBD: 9 attempts');
CALL sp_seed_attempt('EWS',     TRUE,  9,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'EWS PwBD: 9 attempts');
CALL sp_seed_attempt('OBC_NCL', NULL,  9,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'OBC-NCL (with or without PwBD): 9 attempts');
CALL sp_seed_attempt('SC',      NULL,  NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'SC: unlimited within the age limit');
CALL sp_seed_attempt('ST',      NULL,  NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'ST: unlimited within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL,
     'Graduation in any discipline from a recognised university; final-year students may write Prelims');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_upsc, TRUE,
     'IAS, IPS and IFS need Indian citizenship; other services also accept subjects of Nepal or Bhutan, Tibetan refugees (settled before 1962) and PIO with an eligibility certificate');

-- ---------- UPSC Indian Forest Service ----------
CALL sp_seed_exam('UPSC_IFOS', 'Indian Forest Service Examination', 'UPSC IFoS', 'CIVIL_SERVICES', 'UPSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 1, 5,
     'Preliminary (common with CSE) → IFoS Main → Interview',
     'Indian Forest Service (Group A)',
     'https://upsc.gov.in/examinations/active-exams',
     'Screening is done through the Civil Services Preliminary exam; qualified candidates write a separate IFoS Main exam with science/engineering optional subjects.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 100; no fee for women, SC, ST and PwBD candidates',
     'Same attempt limits and counting as CSE; appearing in Prelims counts as an attempt.');
CALL sp_seed_age(NULL, 21, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1,
     'Must have attained 21 and must not have attained 32 years on 1 August of the exam year');
CALL sp_seed_relax_central(5, 'ADD', TRUE);
CALL sp_seed_attempt('GEN',     FALSE, 6,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, NULL);
CALL sp_seed_attempt('EWS',     FALSE, 6,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, NULL);
CALL sp_seed_attempt('GEN',     TRUE,  9,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, NULL);
CALL sp_seed_attempt('EWS',     TRUE,  9,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, NULL);
CALL sp_seed_attempt('OBC_NCL', NULL,  9,    'APPEARED_IN_FIRST_STAGE', NULL, NULL, NULL);
CALL sp_seed_attempt('SC',      NULL,  NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, NULL);
CALL sp_seed_attempt('ST',      NULL,  NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, NULL);
CALL sp_seed_qual(NULL, 'UG', 'ANY',
     'ANIMAL HUSBANDRY|BOTANY|CHEMISTRY|GEOLOGY|MATHS|PHYSICS|STATISTICS|ZOOLOGY|AGRICULTURE|FORESTRY|ENGINEERING',
     NULL, NULL, NULL, TRUE, NULL, NULL,
     'Bachelor''s degree with at least one of Animal Husbandry & Veterinary Science, Botany, Chemistry, Geology, Mathematics, Physics, Statistics, Zoology, or a degree in Agriculture, Forestry or Engineering');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_upsc, TRUE, 'Same nationality conditions as CSE');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, 'Physical standards and a walking test (25 km men / 14 km women) apply at the final stage');

-- ---------- UPSC Engineering Services ----------
CALL sp_seed_exam('UPSC_ESE', 'Engineering Services Examination', 'UPSC ESE', 'CIVIL_SERVICES', 'UPSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 2,
     'Preliminary (objective) → Main (conventional) → Personality Test',
     'Group A engineering services in Railways, CPWD, CWC, MES, Telecom and others (Civil, Mechanical, Electrical, E&T)',
     'https://upsc.gov.in/examinations/active-exams',
     'Recruitment of engineers to central Group A services. The notification comes out around September and Prelims is held early in the next year.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 200; no fee for women, SC, ST and PwBD candidates', 'No attempt limit; eligibility ends with the age limit.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1,
     'Must have attained 21 and must not have attained 30 years on 1 January of the exam year');
CALL sp_seed_relax_central(5, 'ADD', TRUE);
CALL sp_seed_relax('GOVT_EMPLOYEE', NULL, 5, 'ADD', NULL, FALSE, 'Government servants of specified departments (up to 35 years)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'B.E.,B.Tech,AMIE', NULL, NULL, NULL, NULL, TRUE, NULL, NULL,
     'Degree in Engineering (or AMIE / equivalent); M.Sc with Wireless Communication, Electronics, Radio Physics or Radio Engineering accepted for some posts');
CALL sp_seed_qual(NULL, 'PG', 'M.Sc', 'ELECTRONICS|RADIO PHYSICS|RADIO ENGINEERING|WIRELESS COMMUNICATION', NULL, NULL, NULL, TRUE, NULL, NULL,
     'M.Sc with Electronics / Radio Physics / Radio Engineering / Wireless Communication (some E&T posts)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_upsc, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- UPSC Combined Medical Services ----------
CALL sp_seed_exam('UPSC_CMS', 'Combined Medical Services Examination', 'UPSC CMS', 'CIVIL_SERVICES', 'UPSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 4, 7,
     'Computer-based test (2 papers) → Personality Test',
     'Medical Officers in Railways, Ordnance Factories, CGHS, municipal bodies of Delhi',
     'https://upsc.gov.in/examinations/active-exams',
     'Recruitment of MBBS doctors as medical officers in central government organisations.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 200; no fee for women, SC, ST and PwBD candidates', 'No attempt limit; eligibility ends with the age limit.');
CALL sp_seed_age(NULL, NULL, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1,
     'Must be below 32 years of age on 1 August of the exam year');
CALL sp_seed_relax_central(5, 'ADD', TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'MBBS', NULL, NULL, NULL, NULL, TRUE, NULL, NULL,
     'MBBS (written and practical parts of the final MBBS); final-year students may apply but must finish the internship before appointment');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_upsc, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- UPSC CAPF Assistant Commandants ----------
CALL sp_seed_exam('UPSC_CAPF', 'Central Armed Police Forces (Assistant Commandants) Examination', 'UPSC CAPF AC', 'CIVIL_SERVICES', 'UPSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 4, 8,
     'Written (2 papers) → Physical Standards / Efficiency & Medical Tests → Interview',
     'Assistant Commandant (Group A) in BSF, CRPF, CISF, ITBP and SSB',
     'https://upsc.gov.in/examinations/active-exams',
     'Direct entry officers for the central armed police forces. Men and women are both eligible.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 200; no fee for women, SC and ST candidates', 'No attempt limit; eligibility ends with the age limit.');
CALL sp_seed_age(NULL, 20, 25, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1,
     'Must have attained 20 and must not have attained 25 years on 1 August of the exam year');
CALL sp_seed_relax('CATEGORY', 'OBC_NCL', 3, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'ADD', NULL, FALSE, NULL);
CALL sp_seed_relax('GOVT_EMPLOYEE', NULL, 5, 'ADD', NULL, FALSE, 'Central government civilian employees (as per the notification)');
CALL sp_seed_relax('EX_SERVICEMAN', NULL, 5, 'ADD', NULL, FALSE, 'Ex-servicemen as defined in the notification');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Bachelor''s degree from a recognised university');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Only citizens of India');
CALL sp_seed_other(NULL, 'OTHER', 'NO_PWBD', TRUE, 'Posts need full physical and medical fitness; PwBD candidates are not eligible');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, 'Height, chest and physical efficiency tests (100 m, 800 m, long jump, shot put)');

-- ---------- UPSC Indian Economic Service / Indian Statistical Service ----------
CALL sp_seed_exam('UPSC_IES_ISS', 'Indian Economic Service / Indian Statistical Service Examination', 'UPSC IES/ISS', 'CIVIL_SERVICES', 'UPSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 2, 6,
     'Written (descriptive papers) → Interview',
     'Indian Economic Service (IES); Indian Statistical Service (ISS)',
     'https://upsc.gov.in/examinations/active-exams',
     'Group A services for economists (IES) and statisticians (ISS) of the Government of India.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 200; no fee for women, SC, ST and PwBD candidates', 'No attempt limit; eligibility ends with the age limit.');
CALL sp_seed_age(NULL, 21, 30, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1,
     'Must have attained 21 and must not have attained 30 years on 1 August of the exam year');
CALL sp_seed_relax_central(5, 'ADD', TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual('IES', 'PG', 'M.A.,M.Sc', 'ECONOMICS|APPLIED ECONOMICS|BUSINESS ECONOMICS|ECONOMETRICS',
     NULL, NULL, NULL, TRUE, NULL, NULL, 'IES: Post-graduate degree in Economics / Applied Economics / Business Economics / Econometrics');
CALL sp_seed_qual('ISS', 'UG', 'ANY', 'STATISTICS|MATHEMATICAL STATISTICS|APPLIED STATISTICS',
     NULL, NULL, NULL, TRUE, NULL, NULL, 'ISS: Bachelor''s degree with Statistics / Mathematical Statistics / Applied Statistics as a subject');
CALL sp_seed_qual('ISS', 'PG', 'ANY', 'STATISTICS|MATHEMATICAL STATISTICS|APPLIED STATISTICS',
     NULL, NULL, NULL, TRUE, NULL, NULL, 'ISS: or a Master''s degree in Statistics / Mathematical Statistics / Applied Statistics');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_upsc, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- UPSC Combined Geo-Scientist ----------
CALL sp_seed_exam('UPSC_CGS', 'Combined Geo-Scientist Examination', 'UPSC Geo-Scientist', 'CIVIL_SERVICES', 'UPSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 1.0, 9, 2,
     'Preliminary → Main → Personality Test',
     'Geologist, Geophysicist, Chemist (GSI) and Scientist B (Central Ground Water Board)',
     'https://upsc.gov.in/examinations/active-exams',
     'Recruitment of geologists, geophysicists, chemists and hydrogeologists for GSI and CGWB.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 200; no fee for women, SC, ST and PwBD candidates', 'No attempt limit; eligibility ends with the age limit.');
CALL sp_seed_age(NULL, 21, 32, 'NOT_ATTAINED', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1,
     'Must have attained 21 and must not have attained 32 years on 1 January of the exam year');
CALL sp_seed_relax_central(5, 'ADD', TRUE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'PG', 'M.Sc,M.Tech,M.Sc (Tech)',
     'GEOLOGY|APPLIED GEOLOGY|GEOPHYSICS|APPLIED GEOPHYSICS|CHEMISTRY|HYDROGEOLOGY|MARINE GEOLOGY|GEOCHEMISTRY',
     NULL, NULL, NULL, TRUE, NULL, NULL, 'Master''s degree in Geology / Applied Geology / Geophysics / Chemistry / Hydrogeology or related subjects, as per the post');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_upsc, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- UPSC EPFO (EO/AO and APFC) ----------
CALL sp_seed_exam('UPSC_EPFO', 'EPFO Enforcement Officer / Accounts Officer and APFC Recruitment', 'UPSC EPFO', 'CIVIL_SERVICES', 'UPSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 2, 7,
     'Recruitment Test (objective) → Interview',
     'Enforcement Officer / Accounts Officer; Assistant Provident Fund Commissioner (APFC)',
     'https://upsc.gov.in/recruitment/recruitment-test',
     'Irregular recruitment for the Employees'' Provident Fund Organisation. Age is counted on the closing date of the online application.',
     'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 25; no fee for women, SC, ST and PwBD candidates', 'No attempt limit.');
CALL sp_seed_age('EO/AO', NULL, 30, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 3, 1,
     'Not more than 30 years on the closing date of the application (approximated as 1 March)');
CALL sp_seed_age('APFC', NULL, 35, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 3, 1,
     'Not more than 35 years on the closing date of the application (approximated as 1 March)');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Bachelor''s degree from a recognised university');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_upsc, TRUE, 'Indian citizens and the categories listed in the notification');

-- ---------- UPSC NDA & NA ----------
CALL sp_seed_exam('UPSC_NDA', 'National Defence Academy & Naval Academy Examination', 'UPSC NDA', 'DEFENCE', 'UPSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 2.0, 12, 4,
     'Written (Maths + General Ability) → SSB Interview → Medical',
     'Army, Navy and Air Force wings of NDA; 10+2 Cadet Entry Scheme of the Indian Naval Academy',
     'https://upsc.gov.in/examinations/active-exams',
     'Held twice a year (NDA I in April, NDA II in September). Age is checked as a date-of-birth window; unmarried men and women can apply.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 100; no fee for SC, ST, sons of JCOs/NCOs/ORs and women', 'No attempt limit; you can try in every sitting while your date of birth is inside the window.');
CALL sp_seed_age_window(NULL, 16, 19, -19, 1, 1, -16, 1, 1,
     'NDA I: born not earlier than 1 Jan (year-19) and not later than 1 Jan (year-16). NDA II uses the same window shifted to 1 July.');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit; two sittings every year');
CALL sp_seed_qual('Army Wing', 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL,
     'Army Wing: Class 12 pass (any stream); students appearing in Class 12 may apply');
CALL sp_seed_qual('Air Force / Naval Wing', 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,MATHS', NULL, NULL, NULL, TRUE, NULL, NULL,
     'Air Force, Navy and Naval Academy: Class 12 with Physics, Chemistry and Mathematics');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED', TRUE, 'Only unmarried candidates; they must stay unmarried until training is complete');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_upsc, TRUE, 'Indian citizens and the categories listed in the notification');
CALL sp_seed_other(NULL, 'PHYSICAL_STANDARD', NULL, FALSE, 'Physical and medical standards of the Services apply (height, weight, eyesight)');

-- ---------- UPSC CDS ----------
CALL sp_seed_exam('UPSC_CDS', 'Combined Defence Services Examination', 'UPSC CDS', 'DEFENCE', 'UPSC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 2.0, 12, 4,
     'Written → SSB Interview → Medical',
     'Indian Military Academy (IMA), Indian Naval Academy (INA), Air Force Academy (AFA), Officers'' Training Academy (OTA, men and women)',
     'https://upsc.gov.in/examinations/active-exams',
     'Graduate entry for officers, held twice a year. Each academy has its own date-of-birth window and degree requirement.',
     'LIKELY', @src);
CALL sp_seed_exam_info('Rs 200; no fee for women, SC, ST and sons of JCOs/NCOs/ORs', 'No attempt limit; two sittings every year.');
CALL sp_seed_age_window('IMA', 19, 24, -23, 1, 2, -18, 1, 1, 'IMA: born not earlier than 2 Jan (year-23) and not later than 1 Jan (year-18)');
CALL sp_seed_age_window('INA', 19, 24, -23, 1, 2, -18, 1, 1, 'INA: born not earlier than 2 Jan (year-23) and not later than 1 Jan (year-18)');
CALL sp_seed_age_window('AFA', 20, 24, -23, 1, 2, -19, 1, 1, 'AFA: born not earlier than 2 Jan (year-23) and not later than 1 Jan (year-19); up to 26 for DGCA commercial pilot licence holders');
CALL sp_seed_age_window('OTA', 19, 25, -24, 1, 2, -18, 1, 1, 'OTA (men and women): born not earlier than 2 Jan (year-24) and not later than 1 Jan (year-18)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit; two sittings every year');
CALL sp_seed_qual('IMA', 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'IMA: degree from a recognised university');
CALL sp_seed_qual('INA', 'UG', 'B.E.,B.Tech', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'INA: degree in Engineering');
CALL sp_seed_qual('AFA', 'UG', 'ANY', 'CLASS_12:PHYSICS,MATHS', NULL, NULL, NULL, TRUE, NULL, NULL,
     'AFA: degree with Physics and Mathematics at Class 12, or a degree in Engineering');
CALL sp_seed_qual('AFA', 'UG', 'B.E.,B.Tech', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'AFA: or a degree in Engineering');
CALL sp_seed_qual('OTA', 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'OTA: degree from a recognised university');
CALL sp_seed_other('IMA', 'GENDER', 'MALE', TRUE, 'IMA: men only (check the latest notification)');
CALL sp_seed_other('INA', 'GENDER', 'MALE', TRUE, 'INA: men only (check the latest notification)');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED', TRUE, 'Only unmarried candidates (OTA women: unmarried, or as allowed in the notification)');
CALL sp_seed_other(NULL, 'NATIONALITY', @nat_upsc, TRUE, 'Indian citizens and the categories listed in the notification');

SELECT 'UPSC exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN conducting_body b ON b.id = e.body_id WHERE b.short_name = 'UPSC') AS upsc_exams;
