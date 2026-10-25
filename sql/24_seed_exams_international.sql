-- ============================================================
-- AspirantOS - 24_seed_exams_international.sql
-- International tests Indian students take often (10 exams): GRE, GMAT Focus, SAT, ACT, IELTS,
-- TOEFL iBT, PTE Academic, Duolingo English Test, USMLE Step 1, PLAB 1.
-- These rarely have age limits but do have RETAKE limits:
--   PER_ROLLING_12_MONTHS (max_attempts in any 12 months, min_gap_days between attempts) and
--   LIFETIME_TOTAL (max_attempts ever). When both rows exist they apply together, and the engine
--   shows the next date a retest is allowed.
-- Uses 05_seed_helpers.sql. Re-runnable.
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the test owner''s retake policy known to the developer (2025-26). Confirm on the official website.';

CALL sp_seed_body('COLLEGE_BOARD', 'College Board (SAT)',                      'https://satsuite.collegeboard.org', 'INTERNATIONAL');
CALL sp_seed_body('ACT_INC',       'ACT, Inc.',                                'https://www.act.org',          'INTERNATIONAL');
CALL sp_seed_body('IELTS_OWNERS',  'IELTS (British Council, IDP, Cambridge)',  'https://ielts.org',            'INTERNATIONAL');
CALL sp_seed_body('PEARSON',       'Pearson (PTE Academic)',                   'https://www.pearsonpte.com',   'INTERNATIONAL');
CALL sp_seed_body('DUOLINGO',      'Duolingo (Duolingo English Test)',         'https://englishtest.duolingo.com', 'INTERNATIONAL');
CALL sp_seed_body('NBME_FSMB',     'USMLE (FSMB and NBME; ECFMG for international graduates)', 'https://www.usmle.org', 'INTERNATIONAL');
CALL sp_seed_body('GMC_UK',        'General Medical Council, UK',              'https://www.gmc-uk.org',       'INTERNATIONAL');

CALL sp_seed_exam('GRE', 'GRE General Test', 'GRE', 'INTERNATIONAL', 'ETS',
     'INTERNATIONAL', NULL, 'PRIVATE', 'ADMISSION', 12.0, NULL, NULL,
     'Computer-based test (centre or at home), any time of the year', 'Master''s / PhD admissions abroad (and some Indian programmes)', 'https://www.ets.org/gre',
     'No age or education limit to register. You can take it at most 5 times in any rolling 12 months, with at least 21 days between attempts.', 'LIKELY', @src);
CALL sp_seed_exam_info('USD 220 (about Rs 22,550 in India)', 'Max 5 attempts in any continuous 12 months; 21 days between attempts.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, 5, 'PER_ROLLING_12_MONTHS', NULL, 21, 'At most 5 attempts in any rolling 12-month period, at least 21 days apart');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'No qualification needed to take the test (universities set their own)');
CALL sp_seed_other(NULL, 'OTHER', 'PASSPORT', FALSE, 'Indian test takers need a valid passport as ID');

CALL sp_seed_exam('GMAT_FOCUS', 'GMAT Focus Edition', 'GMAT', 'INTERNATIONAL', 'GMAC',
     'INTERNATIONAL', NULL, 'PRIVATE', 'ADMISSION', 12.0, NULL, NULL,
     'Computer-based test (centre or online), any time of the year', 'MBA / business master''s admissions worldwide and at ISB, IIM PGPX and other Indian programmes', 'https://www.mba.com',
     'Business-school test. At most 5 attempts in 12 months and 8 in a lifetime, with 16 days between attempts.', 'LIKELY', @src);
CALL sp_seed_exam_info('USD 275 (test centre) in India', 'Max 5 attempts in any 12 months, 8 in total; 16 days between attempts.');
CALL sp_seed_age(NULL, 13, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'Minimum age 13 (13-17 need parental consent); no upper limit');
CALL sp_seed_attempt(NULL, NULL, 5, 'PER_ROLLING_12_MONTHS', NULL, 16, 'At most 5 attempts in any rolling 12 months, at least 16 days apart');
CALL sp_seed_attempt(NULL, NULL, 8, 'LIFETIME_TOTAL', NULL, NULL, 'At most 8 attempts in total');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'No qualification needed to take the test');
CALL sp_seed_other(NULL, 'OTHER', 'PASSPORT', FALSE, 'Indian test takers need a valid passport as ID');

CALL sp_seed_exam('SAT', 'SAT (Digital)', 'SAT', 'INTERNATIONAL', 'COLLEGE_BOARD',
     'INTERNATIONAL', NULL, 'PRIVATE', 'ADMISSION', 5.0, NULL, NULL,
     'Digital adaptive test (several international dates a year)', 'Undergraduate admissions in the USA and many universities worldwide (and some Indian private universities)', 'https://satsuite.collegeboard.org',
     'Undergraduate admission test; no limit on attempts.', 'LIKELY', @src);
CALL sp_seed_exam_info('USD 68 + international fee USD 43', 'No limit on attempts.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit (mostly taken in Classes 11-12)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'No qualification needed');

CALL sp_seed_exam('ACT', 'ACT', 'ACT', 'INTERNATIONAL', 'ACT_INC',
     'INTERNATIONAL', NULL, 'PRIVATE', 'ADMISSION', 6.0, NULL, NULL,
     'Computer-based test (international dates)', 'Undergraduate admissions in the USA', 'https://www.act.org',
     'US college admission test; you may take it up to 12 times in total.', 'LIKELY', @src);
CALL sp_seed_exam_info('About USD 200 internationally', 'Maximum 12 attempts in total.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, 12, 'LIFETIME_TOTAL', NULL, NULL, 'At most 12 attempts in total');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'No qualification needed');

CALL sp_seed_exam('IELTS_ACADEMIC', 'IELTS Academic', 'IELTS', 'INTERNATIONAL', 'IELTS_OWNERS',
     'INTERNATIONAL', NULL, 'PRIVATE', 'CERTIFICATION', 12.0, NULL, NULL,
     'Listening, Reading, Writing (same day) + Speaking (paper or computer)', 'English proficiency for study, work and migration (UK, Australia, Canada, NZ and more)', 'https://ielts.org',
     'No limit on attempts; results valid for 2 years. Recommended for 16 years and above.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 18,000 in India', 'No limit on attempts.');
CALL sp_seed_age(NULL, 16, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'Recommended minimum age 16; no upper limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit; One Skill Retake available within 60 days');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'No qualification needed');
CALL sp_seed_other(NULL, 'OTHER', 'PASSPORT', FALSE, 'A valid passport is required as ID in India');

CALL sp_seed_exam('TOEFL_IBT', 'TOEFL iBT', 'TOEFL iBT', 'INTERNATIONAL', 'ETS',
     'INTERNATIONAL', NULL, 'PRIVATE', 'CERTIFICATION', 12.0, NULL, NULL,
     'Computer-based test (centre or Home Edition)', 'English proficiency for universities in the USA and worldwide', 'https://www.ets.org/toefl',
     'No limit on attempts; you can retest after a short gap. Scores valid for 2 years.', 'LIKELY', @src);
CALL sp_seed_exam_info('About USD 195-205 in India', 'No limit on attempts; at least 3 days between attempts (check the current policy).');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_ROLLING_12_MONTHS', NULL, 3, 'No maximum; at least 3 days between attempts');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'No qualification needed');
CALL sp_seed_other(NULL, 'OTHER', 'PASSPORT', FALSE, 'A valid passport is required as ID in India');

CALL sp_seed_exam('PTE_ACADEMIC', 'PTE Academic', 'PTE Academic', 'INTERNATIONAL', 'PEARSON',
     'INTERNATIONAL', NULL, 'PRIVATE', 'CERTIFICATION', 12.0, NULL, NULL,
     'Computer-based test (single session)', 'English proficiency for study and migration (Australia, UK, NZ, Canada)', 'https://www.pearsonpte.com',
     'Computer-scored English test; results usually within 2 days. Minimum age 16 (with consent below 18).', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 18,000 in India', 'No limit on attempts.');
CALL sp_seed_age(NULL, 16, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'Minimum age 16 (parental consent for 16-17)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'No qualification needed');
CALL sp_seed_other(NULL, 'OTHER', 'PASSPORT', FALSE, 'A valid passport is required as ID');

CALL sp_seed_exam('DUOLINGO_ENGLISH', 'Duolingo English Test', 'Duolingo English Test', 'INTERNATIONAL', 'DUOLINGO',
     'INTERNATIONAL', NULL, 'PRIVATE', 'CERTIFICATION', 12.0, NULL, NULL,
     'Online adaptive test taken at home (about 1 hour)', 'English proficiency accepted by 5000+ universities', 'https://englishtest.duolingo.com',
     'At-home English test. At most 3 attempts in any 30 days.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('USD 65', 'At most 3 attempts in any 30-day period.');
CALL sp_seed_age(NULL, 13, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'Minimum age 13');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'At most 3 attempts in any 30 days (not modelled as a hard limit)');
CALL sp_seed_qual(NULL, 'NONE', 'ANY', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'No qualification needed');

CALL sp_seed_exam('USMLE_STEP1', 'United States Medical Licensing Examination - Step 1', 'USMLE Step 1', 'INTERNATIONAL', 'NBME_FSMB',
     'INTERNATIONAL', NULL, 'PRIVATE', 'LICENSING', 12.0, NULL, NULL,
     'Computer-based test (Prometric centres in India)', 'First step towards a US medical licence / residency (pass/fail)', 'https://www.usmle.org',
     'Informational entry for Indian medical students. At most 4 attempts per Step and at most 3 attempts in 12 months.', 'LIKELY', @src);
CALL sp_seed_exam_info('About USD 1000 + international surcharge (via ECFMG)', 'Max 4 attempts per Step; max 3 attempts in 12 months; the 4th at least 12 months after the 1st and 6 months after the 3rd.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, 4, 'LIFETIME_TOTAL', NULL, NULL, 'At most 4 attempts in total');
CALL sp_seed_attempt(NULL, NULL, 3, 'PER_ROLLING_12_MONTHS', NULL, NULL, 'At most 3 attempts in any 12 months');
CALL sp_seed_qual(NULL, 'UG', 'MBBS', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'Enrolled in or graduated from a medical school listed in the World Directory (MBBS students may take it)');

CALL sp_seed_exam('PLAB_1', 'Professional and Linguistic Assessments Board - Part 1', 'PLAB 1', 'INTERNATIONAL', 'GMC_UK',
     'INTERNATIONAL', NULL, 'PRIVATE', 'LICENSING', 4.0, NULL, NULL,
     'Written test (180 questions), held in India and other countries', 'First step to GMC registration to practise as a doctor in the UK', 'https://www.gmc-uk.org',
     'For international medical graduates; needs an accepted English test (IELTS / OET) first. At most 4 attempts.', 'LIKELY', @src);
CALL sp_seed_exam_info('About GBP 268', 'Maximum 4 attempts.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, 4, 'LIFETIME_TOTAL', NULL, NULL, 'At most 4 attempts');
CALL sp_seed_qual(NULL, 'UG', 'MBBS', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'An acceptable primary medical qualification (MBBS) and the required English test score');
CALL sp_seed_other(NULL, 'REGISTRATION', 'IELTS_OR_OET', FALSE, 'You need IELTS Academic 7.5 (7.0 each) or OET grade B before booking');

SELECT 'International tests seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'INTERNATIONAL') AS international_tests;
