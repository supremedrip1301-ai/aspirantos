-- ============================================================
-- AspirantOS - 22_seed_exams_professional_finance.sql
-- Professional & finance certifications (12 exams): CA Foundation / Intermediate / Final,
-- CSEET, CS Executive, CS Professional, CMA Foundation / Intermediate / Final, CFA, FRM, NISM.
-- These have registration rules instead of age limits. Uses 05_seed_helpers.sql. Re-runnable.
-- CFA: LIFETIME_TOTAL and PER_ROLLING_12_MONTHS rows apply together (6 attempts per level for
-- life, at most 2 in 12 months, 6 months between attempts of the same level).
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the institute''s regulations known to the developer (2025-26). Confirm with the official website.';

CALL sp_seed_body('CFA_INSTITUTE', 'CFA Institute',                                'https://www.cfainstitute.org', 'INTERNATIONAL');
CALL sp_seed_body('GARP',          'Global Association of Risk Professionals',     'https://www.garp.org',         'INTERNATIONAL');
CALL sp_seed_body('NISM',          'National Institute of Securities Markets',     'https://www.nism.ac.in',       'AUTONOMOUS');

-- ---------- Chartered Accountancy ----------
CALL sp_seed_exam('CA_FOUNDATION', 'CA Foundation Examination', 'CA Foundation', 'PROFESSIONAL_FINANCE', 'ICAI',
     'NATIONAL', NULL, 'AUTONOMOUS', 'CERTIFICATION', 3.0, NULL, 1,
     '4 papers (January, May, September sessions)', 'First level of the Chartered Accountancy course', 'https://www.icai.org',
     'Entry level of CA. Register after Class 10; appear after passing (or appearing in) Class 12. Registration is valid for 4 years.', 'LIKELY', @src);
CALL sp_seed_exam_info('Registration Rs 9000; exam Rs 1500 per sitting', 'No limit on attempts while the registration is valid (4 years, renewable).');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'Registration valid for 4 years; three sittings a year');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Class 12 passed or appearing (provisional admission after Class 10)');
CALL sp_seed_other(NULL, 'REGISTRATION', 'ICAI_FOUNDATION', FALSE, 'Register with ICAI at least 4 months before the exam');

CALL sp_seed_exam('CA_INTERMEDIATE', 'CA Intermediate Examination', 'CA Intermediate', 'PROFESSIONAL_FINANCE', 'ICAI',
     'NATIONAL', NULL, 'AUTONOMOUS', 'CERTIFICATION', 3.0, NULL, 1,
     '2 groups, 6 papers (January, May, September sessions)', 'Second level of the CA course', 'https://www.icai.org',
     'Open after CA Foundation, or directly for graduates (commerce 55%, others 60%) and CS/CMA Intermediate passed.', 'LIKELY', @src);
CALL sp_seed_exam_info('Registration about Rs 18000; exam Rs 1500 per group', 'No limit on attempts while the registration is valid.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit; 8 months of study after registration');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, 55, NULL, NULL, TRUE, NULL, NULL, 'Direct entry: graduation with 55% (commerce) / 60% (others); or CA Foundation passed');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Or Class 12 + CA Foundation passed');
CALL sp_seed_other(NULL, 'REGISTRATION', 'CA_FOUNDATION_PASSED', FALSE, 'Foundation route: you must have passed CA Foundation');

CALL sp_seed_exam('CA_FINAL', 'CA Final Examination', 'CA Final', 'PROFESSIONAL_FINANCE', 'ICAI',
     'NATIONAL', NULL, 'AUTONOMOUS', 'CERTIFICATION', 3.0, NULL, 5,
     '2 groups, 6 papers (January, May, September sessions)', 'Membership of ICAI as a Chartered Accountant', 'https://www.icai.org',
     'Final level of CA, after both Intermediate groups, the self-paced modules and the last months of articleship.', 'LIKELY', @src);
CALL sp_seed_exam_info('Exam Rs 1800 per group', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'CA Intermediate (both groups) passed, ICITSS / AICITSS done and articleship completed as required');
CALL sp_seed_other(NULL, 'REGISTRATION', 'CA_INTER_PASSED', FALSE, 'You must have passed both groups of CA Intermediate and completed the required articleship');

-- ---------- Company Secretary ----------
CALL sp_seed_exam('CSEET', 'CS Executive Entrance Test', 'CSEET', 'PROFESSIONAL_FINANCE', 'ICSI',
     'NATIONAL', NULL, 'AUTONOMOUS', 'CERTIFICATION', 4.0, NULL, 1,
     'Remote proctored test (January, May, July, November)', 'Entry to the Company Secretary course', 'https://www.icsi.edu',
     'Entry test of the CS course; Class 12 passed or appearing. Some graduates are exempt.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1000', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Class 12 passed or appearing');

CALL sp_seed_exam('CS_EXECUTIVE', 'CS Executive Programme Examination', 'CS Executive', 'PROFESSIONAL_FINANCE', 'ICSI',
     'NATIONAL', NULL, 'AUTONOMOUS', 'CERTIFICATION', 2.0, NULL, 6,
     '2 groups (June and December sessions)', 'Second level of the Company Secretary course', 'https://www.icsi.edu',
     'After CSEET (or exemption for graduates / PG / CA / CMA).', 'LIKELY', @src);
CALL sp_seed_exam_info('Registration about Rs 12000; exam Rs 1200 per module', 'No limit on attempts while the registration is valid (5 years).');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit; registration valid for 5 years');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Class 12 + CSEET passed (graduates / PG with 50%+, CA / CMA final are exempt from CSEET)');
CALL sp_seed_other(NULL, 'REGISTRATION', 'CSEET_PASSED', FALSE, 'You need a CSEET pass or exemption');

CALL sp_seed_exam('CS_PROFESSIONAL', 'CS Professional Programme Examination', 'CS Professional', 'PROFESSIONAL_FINANCE', 'ICSI',
     'NATIONAL', NULL, 'AUTONOMOUS', 'CERTIFICATION', 2.0, NULL, 6,
     '2 groups (June and December sessions)', 'Membership of ICSI as a Company Secretary (after training)', 'https://www.icsi.edu',
     'Final level of the CS course, after the Executive programme.', 'LIKELY', @src);
CALL sp_seed_exam_info('Exam Rs 1200 per module', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'CS Executive (both groups) passed');
CALL sp_seed_other(NULL, 'REGISTRATION', 'CS_EXECUTIVE_PASSED', FALSE, 'You must have passed both groups of CS Executive');

-- ---------- Cost & Management Accountancy ----------
CALL sp_seed_exam('CMA_FOUNDATION', 'CMA Foundation Examination', 'CMA Foundation', 'PROFESSIONAL_FINANCE', 'ICMAI',
     'NATIONAL', NULL, 'AUTONOMOUS', 'CERTIFICATION', 2.0, NULL, 6,
     '4 papers (June and December sessions)', 'Entry level of the Cost & Management Accountancy course', 'https://icmai.in',
     'Entry level of CMA after Class 12.', 'LIKELY', @src);
CALL sp_seed_exam_info('Course fee about Rs 6000; exam Rs 1200', 'No attempt limit while the registration is valid.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Class 12 passed (registration after Class 10)');

CALL sp_seed_exam('CMA_INTERMEDIATE', 'CMA Intermediate Examination', 'CMA Intermediate', 'PROFESSIONAL_FINANCE', 'ICMAI',
     'NATIONAL', NULL, 'AUTONOMOUS', 'CERTIFICATION', 2.0, NULL, 6,
     '2 groups (June and December sessions)', 'Second level of the CMA course', 'https://icmai.in',
     'After CMA Foundation, or directly for graduates, CA / CS Intermediate passed.', 'LIKELY', @src);
CALL sp_seed_exam_info('Course fee about Rs 23000; exam Rs 1400 per group', 'No attempt limit while the registration is valid.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Direct entry: any graduate; or CMA Foundation passed after Class 12');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Or Class 12 + CMA Foundation passed');

CALL sp_seed_exam('CMA_FINAL', 'CMA Final Examination', 'CMA Final', 'PROFESSIONAL_FINANCE', 'ICMAI',
     'NATIONAL', NULL, 'AUTONOMOUS', 'CERTIFICATION', 2.0, NULL, 6,
     '2 groups (June and December sessions)', 'Membership of ICMAI as a Cost Accountant (after practical training)', 'https://icmai.in',
     'Final level of CMA after both Intermediate groups and part of the practical training.', 'LIKELY', @src);
CALL sp_seed_exam_info('Course fee about Rs 25000; exam Rs 1600 per group', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'CMA Intermediate (both groups) passed and practical training as required');
CALL sp_seed_other(NULL, 'REGISTRATION', 'CMA_INTER_PASSED', FALSE, 'You must have passed both groups of CMA Intermediate');

-- ---------- CFA, FRM, NISM ----------
CALL sp_seed_exam('CFA', 'Chartered Financial Analyst (CFA) Program - Levels I, II, III', 'CFA', 'PROFESSIONAL_FINANCE', 'CFA_INSTITUTE',
     'INTERNATIONAL', NULL, 'PRIVATE', 'CERTIFICATION', 4.0, NULL, 2,
     'Level I → Level II → Level III (computer-based windows during the year)', 'CFA charter (with 4000 hours of relevant work experience)', 'https://www.cfainstitute.org',
     'Global investment-management credential. Each level allows at most 6 attempts in total and at most 2 in 12 months.', 'LIKELY', @src);
CALL sp_seed_exam_info('One-time enrolment USD 350 + exam USD 940-1290 per level', 'Maximum 6 attempts per level; no more than 2 in any 12 months; 6 months between attempts of the same level.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit (a valid passport is needed)');
CALL sp_seed_attempt(NULL, NULL, 6, 'LIFETIME_TOTAL', NULL, NULL, 'At most 6 attempts per level (lifetime)');
CALL sp_seed_attempt(NULL, NULL, 2, 'PER_ROLLING_12_MONTHS', NULL, 180, 'At most 2 attempts in 12 months, at least 6 months apart');
CALL sp_seed_qual(NULL, 'UG', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Level I: bachelor''s degree, or within 23 months of graduation (final-year students), or 4000 hours of work / education');
CALL sp_seed_other(NULL, 'OTHER', 'PASSPORT', FALSE, 'An international travel passport is required to register');

CALL sp_seed_exam('FRM', 'Financial Risk Manager (FRM) - Part I and Part II', 'FRM', 'PROFESSIONAL_FINANCE', 'GARP',
     'INTERNATIONAL', NULL, 'PRIVATE', 'CERTIFICATION', 3.0, NULL, 5,
     'Part I → Part II (May, August, November windows)', 'FRM certification (with 2 years of relevant work experience)', 'https://www.garp.org',
     'Risk-management certification of GARP. No education requirement; Part II must be passed within 4 years of Part I.', 'LIKELY', @src);
CALL sp_seed_exam_info('Enrolment USD 400 + exam USD 600-800 per part', 'No attempt limit; Part II within 4 years of passing Part I.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'No minimum education requirement');

CALL sp_seed_exam('NISM_CERT', 'NISM Certification Examinations (generic)', 'NISM Certifications', 'PROFESSIONAL_FINANCE', 'NISM',
     'NATIONAL', NULL, 'AUTONOMOUS', 'CERTIFICATION', 12.0, NULL, NULL,
     'Online test on demand at test centres', 'SEBI-mandated certifications: Mutual Fund Distributors, Equity Derivatives, Investment Adviser, Research Analyst and others', 'https://www.nism.ac.in',
     'Mandatory certifications for many securities-market jobs; tests can be booked any time.', 'LIKELY', @src);
CALL sp_seed_exam_info('About Rs 1500-3000 per module', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'No minimum qualification for most modules (Investment Adviser / Research Analyst need a degree for registration with SEBI)');

SELECT 'Professional and finance exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'PROFESSIONAL_FINANCE') AS professional_exams;
