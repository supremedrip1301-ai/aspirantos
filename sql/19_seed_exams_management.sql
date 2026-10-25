-- ============================================================
-- AspirantOS - 19_seed_exams_management.sql
-- Management entrance tests (20 exams): CAT, XAT, SNAP, NMAT, MAT, CMAT, MICAT, IBSAT, ATMA,
-- IPMAT Indore, IPMAT Rohtak, JIPMAT, NPAT, Symbiosis SET, MAH MBA CET, KMAT, TANCET MBA,
-- AP ICET, TS ICET, OJEE MBA. (GMAT is in 24_seed_exams_international.sql.)
-- Uses 05_seed_helpers.sql. Re-runnable.
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the latest bulletin known to the developer (2025-26 admissions). Confirm with the official website.';

CALL sp_seed_body('XLRI',        'XLRI - Xavier School of Management (XAMI)',        'https://xatonline.in',          'PRIVATE');
CALL sp_seed_body('SIU',         'Symbiosis International (Deemed University)',      'https://www.snaptest.org',      'PRIVATE');
CALL sp_seed_body('AIMA',        'All India Management Association',                 'https://mat.aima.in',           'AUTONOMOUS');
CALL sp_seed_body('MICA',        'MICA, Ahmedabad',                                  'https://www.mica.ac.in',        'PRIVATE');
CALL sp_seed_body('IBS',         'ICFAI Business School (IFHE)',                     'https://www.ibsindia.org',      'PRIVATE');
CALL sp_seed_body('AIMS_ATMA',   'Association of Indian Management Schools',         'https://www.atmaaims.com',      'AUTONOMOUS');
CALL sp_seed_body('IIM_INDORE',  'Indian Institute of Management Indore',            'https://www.iimidr.ac.in',      'AUTONOMOUS');
CALL sp_seed_body('IIM_ROHTAK',  'Indian Institute of Management Rohtak',            'https://www.iimrohtak.ac.in',   'AUTONOMOUS');
CALL sp_seed_body('NMIMS',       'SVKM''s NMIMS (Deemed University)',                'https://www.npat.in',           'PRIVATE');
CALL sp_seed_body('KMAT_KA',     'Karnataka Private Post-Graduate Colleges Association (KMAT)', 'https://kmatindia.com', 'PRIVATE');
CALL sp_seed_body('ANNA_UNIV',   'Anna University, Chennai (TANCET)',                'https://tancet.annauniv.edu',   'UNIVERSITY');

CALL sp_seed_exam('CAT', 'Common Admission Test', 'CAT', 'MANAGEMENT', 'IIM',
     'NATIONAL', NULL, 'AUTONOMOUS', 'ADMISSION', 1.0, 8, 11,
     'Computer-based test → WAT / GD / PI by each IIM', 'MBA / PGP at the 21 IIMs and 1000+ other B-schools', 'https://iimcat.ac.in',
     'No age limit and no attempt limit. Graduation with 50% (45% SC/ST/PwBD); final-year students may apply.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2600 (Rs 1300 for SC, ST, PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, 45, 'SC,ST,PWBD', TRUE, NULL, NULL, 'Bachelor''s degree with 50% (45% SC/ST/PwBD) or equivalent CGPA; final-year students may apply');

CALL sp_seed_exam('XAT', 'Xavier Aptitude Test', 'XAT', 'MANAGEMENT', 'XLRI',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 1.0, 7, 1,
     'Computer-based test → GD / PI', 'PGDM / MBA at XLRI and 250+ other B-schools', 'https://xatonline.in',
     'National MBA entrance of XLRI, held in early January. No age limit.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2200', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Bachelor''s degree of at least 3 years in any discipline; final-year students may apply');

CALL sp_seed_exam('SNAP', 'Symbiosis National Aptitude Test', 'SNAP', 'MANAGEMENT', 'SIU',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 1.0, 8, 12,
     'Computer-based test (up to 3 attempts in December; best score counts) → GE-PIWAT', 'MBA at 16 Symbiosis institutes', 'https://www.snaptest.org',
     'MBA entrance of Symbiosis; candidates may take up to three test dates in the same cycle.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2250 per attempt', 'Up to 3 test dates per cycle; the best score is used.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, 3, 'PER_ROLLING_12_MONTHS', NULL, NULL, 'Up to 3 attempts in one SNAP cycle');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, 45, 'SC,ST', TRUE, NULL, NULL, 'Graduation with 50% (45% SC/ST); final-year students may apply');

CALL sp_seed_exam('NMAT', 'NMAT by GMAC', 'NMAT', 'MANAGEMENT', 'GMAC',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 1.0, 8, 11,
     'Computer-based test (Oct-Dec window, up to 3 attempts) → GD / PI', 'MBA at NMIMS and other B-schools in India, Morocco, Nigeria, Philippines, South Africa', 'https://www.mba.com/exams/nmat',
     'You may take NMAT up to three times in one testing window (one initial + two retakes).', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 3000 + GST (retake Rs 1300 + GST)', 'Maximum 3 attempts in a testing window (counted here as a rolling 12 months).');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, 3, 'PER_ROLLING_12_MONTHS', NULL, 15, 'Up to 3 attempts per testing window; about 15 days between attempts');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, NULL, NULL, TRUE, NULL, NULL, 'Graduation with 50% in any discipline; final-year students may apply');

CALL sp_seed_exam('MAT', 'Management Aptitude Test', 'MAT', 'MANAGEMENT', 'AIMA',
     'NATIONAL', NULL, 'AUTONOMOUS', 'ADMISSION', 4.0, 1, 2,
     'Paper-based / CBT / remote proctored test (four times a year)', 'MBA / PGDM at 600+ B-schools', 'https://mat.aima.in',
     'Held four times a year (February, May, September, December).', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2200 (one mode)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation in any discipline; final-year students may apply');

CALL sp_seed_exam('CMAT', 'Common Management Admission Test', 'CMAT', 'MANAGEMENT', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 11, 1,
     'Computer-based test', 'MBA / PGDM at AICTE-approved institutes', 'https://cmat.nta.nic.in',
     'National MBA entrance by NTA for AICTE-approved institutes.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2500 (General male), Rs 1250 (female, SC, ST, PwBD, EWS, OBC-NCL)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation in any discipline; final-year students may apply');

CALL sp_seed_exam('MICAT', 'MICA Admission Test', 'MICAT', 'MANAGEMENT', 'MICA',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 2.0, 9, 12,
     'Computer-based test (December and January) → GE / PI', 'PGDM-Communications at MICA', 'https://www.mica.ac.in',
     'Entrance for MICA''s strategic marketing and communication programme; held twice. Requires a CAT / XAT / GMAT score too.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2950 (one attempt), Rs 4500 (two)', 'Up to two attempts per cycle.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'Two attempts per cycle');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Graduation in any discipline; final-year students may apply');
CALL sp_seed_other(NULL, 'REGISTRATION', 'CAT_XAT_GMAT_CMAT', FALSE, 'You also need a valid CAT / XAT / GMAT / CMAT score');

CALL sp_seed_exam('IBSAT', 'ICFAI Business School Aptitude Test', 'IBSAT', 'MANAGEMENT', 'IBS',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 1.0, 7, 12,
     'Online test → GD / PI', 'MBA / PGPM at the 9 IBS campuses', 'https://www.ibsindia.org',
     'MBA entrance of ICFAI Business Schools.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1800', 'Up to two attempts per cycle.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, NULL, NULL, TRUE, NULL, NULL, 'Graduation with 50% in any discipline; final-year students may apply');

CALL sp_seed_exam('ATMA', 'AIMS Test for Management Admissions', 'ATMA', 'MANAGEMENT', 'AIMS_ATMA',
     'NATIONAL', NULL, 'AUTONOMOUS', 'ADMISSION', 4.0, 1, 2,
     'Computer-based / remote test (several times a year)', 'MBA, PGDM, MCA at participating institutes', 'https://www.atmaaims.com',
     'National management test held several times a year.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 2000', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, 45, 'SC,ST', TRUE, NULL, NULL, 'Graduation with 50% (45% SC/ST); final-year students may apply');

CALL sp_seed_exam('IPMAT_INDORE', 'IPMAT (Integrated Programme in Management Aptitude Test) - IIM Indore', 'IPMAT Indore', 'MANAGEMENT', 'IIM_INDORE',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 2, 5,
     'Computer-based test → Personal interview', '5-year Integrated Programme in Management (IPM) at IIM Indore (also IIM Ranchi and others)', 'https://www.iimidr.ac.in',
     'After-Class-12 management entrance with an age rule: born on or after 1 August of (year - 20), 5 years relaxation for SC/ST/PwBD.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 4130 (Rs 2065 for SC, ST, PwBD)', 'Only in the Class 12 year or the two previous years.');
CALL sp_seed_age_window(NULL, NULL, 20, -20, 8, 1, NULL, NULL, NULL, 'Born on or after 1 August of (year - 20)');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation');
CALL sp_seed_relax('PWBD', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation');
CALL sp_seed_attempt(NULL, NULL, NULL, 'CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM', 3, NULL, 'Class 12 year and the next two years');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, 60, 55, 'SC,ST,PWBD', TRUE, 2, NULL, 'Class 12 / equivalent with 60% (55% SC/ST/PwBD), passed in the last two years or appearing');

CALL sp_seed_exam('IPMAT_ROHTAK', 'IPMAT - IIM Rohtak', 'IPMAT Rohtak', 'MANAGEMENT', 'IIM_ROHTAK',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 3, 5,
     'Computer-based test → Personal interview', '5-year Integrated Programme in Management at IIM Rohtak', 'https://www.iimrohtak.ac.in',
     'IIM Rohtak''s own IPM entrance; born on or after 1 July of (year - 20), 5 years relaxation for SC/ST/PwBD.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 4130 (Rs 2065 for SC, ST, PwBD)', 'Only in the Class 12 year or the two previous years.');
CALL sp_seed_age_window(NULL, NULL, 20, -20, 7, 1, NULL, NULL, NULL, 'Born on or after 1 July of (year - 20)');
CALL sp_seed_relax('CATEGORY', 'SC', 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation');
CALL sp_seed_relax('CATEGORY', 'ST', 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation');
CALL sp_seed_relax('PWBD', NULL, 5, 'REPLACE_WITH_MAX', NULL, FALSE, '5 years relaxation');
CALL sp_seed_attempt(NULL, NULL, NULL, 'CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM', 3, NULL, 'Class 12 year and the next two years');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, 60, 55, 'SC,ST,PWBD', TRUE, 2, NULL, 'Class 12 with 60% (55% SC/ST/PwBD) in Class 10 and Class 12');

CALL sp_seed_exam('JIPMAT', 'Joint Integrated Programme in Management Admission Test', 'JIPMAT', 'MANAGEMENT', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 3, 4,
     'Computer-based test', '5-year Integrated Programme in Management at IIM Bodh Gaya and IIM Jammu', 'https://jipmat.nta.ac.in',
     'NTA-conducted IPM entrance for IIM Bodh Gaya and IIM Jammu.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2000 (General), Rs 1000 (female, SC, ST, PwBD, EWS, OBC-NCL)', 'Only in the Class 12 year or the two previous years.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM', 3, NULL, 'Class 12 year and the next two years');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, 2, NULL, 'Class 12 passed in the last two years or appearing this year');

CALL sp_seed_exam('NPAT', 'NMIMS Programs After Twelfth', 'NPAT', 'MANAGEMENT', 'NMIMS',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 1.0, 12, 4,
     'Computer-based test (up to 2 attempts) → Merit list', 'BBA, B.Com (Hons), B.Sc Finance and other UG programmes at NMIMS', 'https://www.npat.in',
     'UG entrance of NMIMS for business and economics programmes.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1800', 'Up to two attempts; the better score is used.');
CALL sp_seed_age(NULL, NULL, 25, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 7, 1, 'Up to 25 years on 1 July');
CALL sp_seed_attempt(NULL, NULL, 2, 'PER_ROLLING_12_MONTHS', NULL, NULL, 'Up to 2 attempts per cycle');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, 50, NULL, NULL, TRUE, NULL, NULL, 'Class 12 with 50% aggregate');

CALL sp_seed_exam('SYMBIOSIS_SET', 'Symbiosis Entrance Test (UG)', 'Symbiosis SET', 'MANAGEMENT', 'SIU',
     'NATIONAL', NULL, 'PRIVATE', 'ADMISSION', 1.0, 12, 5,
     'Computer-based test (up to 2 attempts) → Personal interaction', 'BBA, BBA-IT, BCA, B.Sc Economics, Liberal Arts and other UG programmes at Symbiosis', 'https://www.set-test.org',
     'Undergraduate entrance of Symbiosis International.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 2250 per attempt', 'Up to two attempts; the best score counts.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, 2, 'PER_ROLLING_12_MONTHS', NULL, NULL, 'Up to 2 attempts per cycle');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, 50, 45, 'SC,ST', TRUE, NULL, NULL, 'Class 12 with 50% (45% SC/ST)');

CALL sp_seed_exam('MAH_MBA_CET', 'MAH MBA / MMS CET', 'MAH MBA CET', 'MANAGEMENT', 'MH_CET_CELL',
     'STATE', 'MH', 'GOVERNMENT', 'ADMISSION', 1.0, 1, 4,
     'Computer-based test → CAP rounds', 'MBA / MMS at government and private institutes of Maharashtra (JBIMS, SIMSREE, PUMBA and others)', 'https://cetcell.mahacet.org',
     'State MBA entrance of Maharashtra; all-India candidates may apply for the all-India quota.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1200 (Rs 1000 for reserved categories of Maharashtra)', 'One attempt per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, 45, 'SC,ST,OBC_NCL,PWBD', TRUE, NULL, NULL, 'Graduation with 50% (45% for reserved categories of Maharashtra); final-year students may apply');
CALL sp_seed_other(NULL, 'DOMICILE', 'MH', FALSE, 'Maharashtra state-quota seats need MH domicile; 15% all-India seats are open');

CALL sp_seed_exam('KMAT', 'Karnataka Management Aptitude Test', 'KMAT', 'MANAGEMENT', 'KMAT_KA',
     'STATE', 'KA', 'PRIVATE', 'ADMISSION', 1.0, 9, 11,
     'Computer-based test', 'MBA / PGDM / MCA at private colleges of Karnataka', 'https://kmatindia.com',
     'Entrance for private management colleges in Karnataka.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1000', 'One attempt per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, 45, 'SC,ST,OBC_NCL', TRUE, NULL, NULL, 'Graduation with 50% (45% for SC/ST/Cat-1 of Karnataka)');

CALL sp_seed_exam('TANCET_MBA', 'Tamil Nadu Common Entrance Test (MBA)', 'TANCET MBA', 'MANAGEMENT', 'ANNA_UNIV',
     'STATE', 'TN', 'GOVERNMENT', 'ADMISSION', 1.0, 1, 3,
     'Paper-based test', 'MBA at Anna University, government and self-financing colleges of Tamil Nadu', 'https://tancet.annauniv.edu',
     'State MBA entrance of Tamil Nadu.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1000 (Rs 500 for SC/ST/SCA of Tamil Nadu)', 'One attempt per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, 45, 'SC,ST', TRUE, NULL, NULL, 'A 3-year bachelor''s degree with 50% (45% reserved)');

CALL sp_seed_exam('AP_ICET', 'Andhra Pradesh Integrated Common Entrance Test', 'AP ICET', 'MANAGEMENT', 'APSCHE',
     'STATE', 'AP', 'GOVERNMENT', 'ADMISSION', 1.0, 3, 5,
     'Computer-based test → Counselling', 'MBA and MCA in Andhra Pradesh', 'https://cets.apsche.ap.gov.in',
     'State MBA / MCA entrance of Andhra Pradesh.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 650 (Rs 550 for BC, Rs 500 for SC/ST)', 'One attempt per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, 45, 'SC,ST,OBC_NCL', TRUE, NULL, NULL, 'Bachelor''s degree of 3 years with 50% (45% reserved); MCA needs Maths at Class 12 or graduation');
CALL sp_seed_other(NULL, 'DOMICILE', 'AP', FALSE, 'Local / non-local status decides the seat quota');

CALL sp_seed_exam('TS_ICET', 'Telangana Integrated Common Entrance Test', 'TS ICET', 'MANAGEMENT', 'TGCHE',
     'STATE', 'TS', 'GOVERNMENT', 'ADMISSION', 1.0, 3, 6,
     'Computer-based test → Counselling', 'MBA and MCA in Telangana', 'https://icet.tgche.ac.in',
     'State MBA / MCA entrance of Telangana.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 750 (Rs 550 for SC/ST/PwBD)', 'One attempt per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, 45, 'SC,ST,OBC_NCL', TRUE, NULL, NULL, 'Bachelor''s degree of 3 years with 50% (45% reserved)');
CALL sp_seed_other(NULL, 'DOMICILE', 'TS', FALSE, 'Local / non-local status decides the seat quota');

CALL sp_seed_exam('OJEE_MBA', 'OJEE (MBA / MCA)', 'OJEE MBA', 'MANAGEMENT', 'OJEE_BOARD',
     'STATE', 'OD', 'GOVERNMENT', 'ADMISSION', 1.0, 2, 5,
     'Computer-based test → Counselling', 'MBA / MCA in Odisha', 'https://ojee.nic.in',
     'Odisha state entrance for MBA and MCA programmes.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1000', 'One attempt per year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 50, 45, 'SC,ST', TRUE, NULL, NULL, 'Graduation with 50% (45% SC/ST)');

SELECT 'Management exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'MANAGEMENT') AS management_exams;
