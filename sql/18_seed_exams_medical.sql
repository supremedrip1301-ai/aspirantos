-- ============================================================
-- AspirantOS - 18_seed_exams_medical.sql
-- Medical & dental (8 exams; UPSC CMS is in 11), nursing (5 exams) and pharmacy (3 exams).
-- Uses 05_seed_helpers.sql. Re-runnable.
-- NEET UG percentages: two alternative rows - 50% (40% SC/ST/OBC) and 50% (45% General PwBD).
-- ============================================================

USE aspirantos;

SET @src = 'Seeded from the latest information bulletin / notification known to the developer (2025-26). Confirm with the current bulletin.';

CALL sp_seed_body('AIIMS',  'All India Institute of Medical Sciences, New Delhi', 'https://www.aiimsexams.ac.in', 'AUTONOMOUS');
CALL sp_seed_body('ESIC',   'Employees'' State Insurance Corporation',           'https://www.esic.gov.in',      'CENTRAL_GOVT');
CALL sp_seed_body('PGIMER', 'Postgraduate Institute of Medical Education and Research, Chandigarh', 'https://pgimer.edu.in', 'AUTONOMOUS');
CALL sp_seed_body('NIPER',  'National Institutes of Pharmaceutical Education and Research', 'https://niperhyd.ac.in', 'AUTONOMOUS');
CALL sp_seed_body('STATE_PSC_GENERIC', 'State Public Service Commissions (various)', NULL, 'STATE_GOVT');

-- =================== MEDICAL & DENTAL ===================

CALL sp_seed_exam('NEET_UG', 'National Eligibility cum Entrance Test (UG)', 'NEET UG', 'MEDICAL', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 2, 5,
     'Single pen-and-paper test → MCC / state counselling',
     'MBBS, BDS, BAMS, BUMS, BSMS, BHMS, B.V.Sc & AH and B.Sc Nursing (some institutes)', 'https://neet.nta.nic.in',
     'The only entrance for MBBS / BDS in India. Minimum age 17 by 31 December of the admission year; no upper age and no attempt limit.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 1700 (General), Rs 1600 (EWS / OBC-NCL), Rs 1000 (SC / ST / PwBD / transgender)', 'No limit on the number of attempts.');
CALL sp_seed_age(NULL, 17, NULL, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 12, 31, 'At least 17 years on 31 December of the admission year; no upper age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,BIOLOGY|BIOTECHNOLOGY,ENGLISH', 50, 40, 'SC,ST,OBC_NCL', TRUE, NULL, NULL,
     'Class 12 with Physics, Chemistry, Biology/Biotechnology and English; 50% in PCB (40% SC/ST/OBC); appearing students may apply');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,BIOLOGY|BIOTECHNOLOGY,ENGLISH', 50, 45, 'PWBD', TRUE, NULL, NULL,
     'General-PwBD: 45% in PCB');

CALL sp_seed_exam('NEET_PG', 'NEET Postgraduate', 'NEET PG', 'MEDICAL', 'NBEMS',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 4, 8,
     'Computer-based test → MCC / state PG counselling', 'MD, MS, PG Diploma, DNB and DrNB (direct 6-year) courses', 'https://natboard.edu.in',
     'Entrance for postgraduate medical courses. MBBS with internship completed by the cut-off date.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 3500 (General / OBC / EWS), Rs 2500 (SC / ST / PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'MBBS', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'MBBS with a permanent / provisional registration and one-year internship completed by the cut-off date');

CALL sp_seed_exam('NEET_MDS', 'NEET MDS', 'NEET MDS', 'MEDICAL', 'NBEMS',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 2, 4,
     'Computer-based test → MCC MDS counselling', 'Master of Dental Surgery (MDS)', 'https://natboard.edu.in',
     'Entrance for postgraduate dental courses.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 3500 (General / OBC / EWS), Rs 2500 (SC / ST / PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'BDS', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'BDS with registration and one-year internship completed by the cut-off date');

CALL sp_seed_exam('NEET_SS', 'NEET Super Speciality', 'NEET SS', 'MEDICAL', 'NBEMS',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 9, 12,
     'Computer-based test → MCC SS counselling', 'DM, MCh and DrNB super-speciality courses', 'https://natboard.edu.in',
     'Entrance for super-speciality courses after MD / MS / DNB.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 4250', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'PG', 'MD,MS,DNB', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'MD / MS / DNB in the feeder speciality, completed by the cut-off date');

CALL sp_seed_exam('INI_CET', 'Institute of National Importance Combined Entrance Test', 'INI-CET', 'MEDICAL', 'AIIMS',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 2.0, 3, 5,
     'Computer-based test → INI counselling', 'MD, MS, MCh (6-yr), DM (6-yr) and MDS at AIIMS, JIPMER, PGIMER and NIMHANS', 'https://www.aiimsexams.ac.in',
     'PG medical entrance of the Institutes of National Importance; held twice a year (January and July sessions).', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 4000 (General / OBC), Rs 3200 (SC / ST / EWS)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'MBBS,BDS', NULL, 55, 50, 'SC,ST', FALSE, NULL, NULL, 'MBBS / BDS with 55% aggregate (50% SC/ST) and internship completed by the cut-off date');

CALL sp_seed_exam('FMGE', 'Foreign Medical Graduates Examination', 'FMGE', 'MEDICAL', 'NBEMS',
     'NATIONAL', NULL, 'GOVERNMENT', 'LICENSING', 2.0, 4, 6,
     'Computer-based screening test (June and December)', 'Licence to practise / register with NMC or a state medical council', 'https://natboard.edu.in',
     'Screening test for Indian citizens / OCI holders who studied medicine abroad. Will be replaced by the NMC''s NExT in future.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 7080 (including GST)', 'No limit on attempts; held twice a year.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'MBBS', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Primary medical qualification (MBBS-equivalent) from a medical college outside India');
CALL sp_seed_other(NULL, 'OTHER', 'FOREIGN_MEDICAL_DEGREE', FALSE, 'Only for medical degrees obtained outside India (not needed for Indian MBBS)');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN,PIO', TRUE, 'Indian citizens and Overseas Citizens of India');

CALL sp_seed_exam('AIAPGET', 'All India AYUSH Post Graduate Entrance Test', 'AIAPGET', 'MEDICAL', 'NTA',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 4, 7,
     'Computer-based test → AACCC counselling', 'MD / MS in Ayurveda, Unani, Siddha, Homoeopathy and Sowa-Rigpa', 'https://exams.nta.ac.in/AIAPGET',
     'PG entrance for AYUSH systems of medicine.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2700 (General), Rs 2450 (EWS / OBC), Rs 1800 (SC / ST / PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'BAMS,BUMS,BSMS,BHMS,BSRMS', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'BAMS / BUMS / BSMS / BHMS / BSRMS with internship completed by the cut-off date');

CALL sp_seed_exam('ESIC_IMO', 'ESIC Insurance Medical Officer Grade II', 'ESIC IMO', 'MEDICAL', 'ESIC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 3, 6,
     'Shortlisting through UPSC CMS rank (recent) or written exam → Interview', 'Insurance Medical Officer Grade II (Allopathy) in ESIC hospitals', 'https://www.esic.gov.in',
     'Recruitment of MBBS doctors for ESIC hospitals and dispensaries (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 500 (exempt for SC, ST, PwBD, women, ex-servicemen)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, NULL, 35, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 4, 1, 'Up to 35 years on the closing date');
CALL sp_seed_relax_central(5, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'MBBS', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'MBBS with completed internship');

-- =================== NURSING ===================

CALL sp_seed_exam('AIIMS_BSC_NURSING', 'AIIMS B.Sc Nursing (Hons) Entrance', 'AIIMS B.Sc Nursing', 'NURSING_PARAMEDICAL', 'AIIMS',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 3, 6,
     'Computer-based test → Counselling', 'B.Sc Nursing (Hons) at AIIMS institutes', 'https://www.aiimsexams.ac.in',
     'Nursing degree admission at AIIMS. Several AIIMS admit only women for this course.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 2000 (General / OBC), Rs 1600 (SC / ST / EWS)', 'One attempt per year.');
CALL sp_seed_age(NULL, 17, NULL, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 12, 31, 'At least 17 years on 31 December of the admission year');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,BIOLOGY,ENGLISH', 55, 50, 'SC,ST', TRUE, NULL, NULL, 'Class 12 with Physics, Chemistry, Biology and English; 55% aggregate (50% SC/ST)');
CALL sp_seed_other(NULL, 'GENDER', 'FEMALE', FALSE, 'Many AIIMS admit only female candidates to B.Sc Nursing (Hons) - check the bulletin for each AIIMS');

CALL sp_seed_exam('AIIMS_NORCET', 'AIIMS Nursing Officer Recruitment Common Eligibility Test', 'AIIMS NORCET', 'NURSING_PARAMEDICAL', 'AIIMS',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 2.0, 7, 9,
     'Preliminary (CBT) → Main (CBT)', 'Nursing Officer (Group B) at AIIMS institutes', 'https://www.aiimsexams.ac.in',
     'Common recruitment of nursing officers for all AIIMS, held about twice a year.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 3000 (General / OBC), Rs 2400 (SC / ST / EWS), exempt for PwBD', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 30, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 8, 1, 'Age 18-30 on the closing date');
CALL sp_seed_relax_central(0, 'ADD', FALSE);
CALL sp_seed_relax('GOVT_EMPLOYEE', NULL, 5, 'ADD', NULL, FALSE, 'Central government employees (as per rules)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'B.Sc Nursing,Post-Basic B.Sc Nursing', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'B.Sc (Hons) / B.Sc Nursing / Post-Basic B.Sc Nursing, registered as Nurse & Midwife');
CALL sp_seed_qual(NULL, 'DIPLOMA', 'GNM', NULL, NULL, NULL, NULL, FALSE, NULL, 2.0, 'Or GNM diploma + 2 years experience in a 50-bed hospital');

CALL sp_seed_exam('ESIC_STAFF_NURSE', 'ESIC Nursing Officer / Staff Nurse', 'ESIC Staff Nurse', 'NURSING_PARAMEDICAL', 'ESIC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 4, 7,
     'Computer-based test (often through UPSC / AIIMS NORCET in recent years)', 'Nursing Officer / Staff Nurse in ESIC hospitals', 'https://www.esic.gov.in',
     'Nursing recruitment for ESIC hospitals (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 500 (exempt for SC, ST, PwBD, women, ex-servicemen)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 18, 27, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 4, 1, 'Age 18-27 (some notifications up to 30 or 35)');
CALL sp_seed_relax_central(0, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'B.Sc Nursing', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'B.Sc Nursing, or GNM diploma, registered with a nursing council');
CALL sp_seed_qual(NULL, 'DIPLOMA', 'GNM', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'Or GNM diploma');

CALL sp_seed_exam('PGIMER_NURSING_OFFICER', 'PGIMER Chandigarh Nursing Officer', 'PGIMER Nursing Officer', 'NURSING_PARAMEDICAL', 'PGIMER',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, 4, 6,
     'Computer-based test', 'Nursing Officer (Group B) at PGIMER Chandigarh', 'https://pgimer.edu.in',
     'Nursing officer recruitment of PGIMER (irregular).', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 1500 (Rs 800 for SC/ST; exempt PwBD)', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 35, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 4, 1, 'Age 21-35 (varies by notice)');
CALL sp_seed_relax_central(0, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'B.Sc Nursing', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, 'B.Sc Nursing, or GNM + 2 years experience, registered as Nurse & Midwife');

CALL sp_seed_exam('MNS_BSC_NURSING', 'Military Nursing Service B.Sc Nursing Admission', 'MNS B.Sc Nursing', 'NURSING_PARAMEDICAL', 'ARMY',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 6, 8,
     'Shortlisting on NEET UG score → Psychological assessment test + interview → Medical', '4-year B.Sc Nursing at Armed Forces Medical Services colleges, then a commission in the MNS', 'https://joinindianarmy.nic.in',
     'Women-only nursing entry of the Armed Forces; selection uses the NEET UG score.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 200', 'One attempt per year.');
CALL sp_seed_age_window(NULL, 17, 25, -25, 10, 1, -17, 9, 30, 'Born between 1 Oct (year-25) and 30 Sep (year-17)');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit within the age window');
CALL sp_seed_qual(NULL, 'CLASS_12', 'ANY', 'PHYSICS,CHEMISTRY,BIOLOGY,ENGLISH', 50, NULL, NULL, TRUE, NULL, NULL, 'Class 12 with Physics, Chemistry, Biology and English, 50% aggregate; NEET UG qualified');
CALL sp_seed_other(NULL, 'GENDER', 'FEMALE', TRUE, 'Women only');
CALL sp_seed_other(NULL, 'MARITAL_STATUS', 'UNMARRIED,DIVORCED,WIDOWED', TRUE, 'Unmarried, or divorced / legally separated / widowed without encumbrance');
CALL sp_seed_other(NULL, 'REGISTRATION', 'NEET_UG', FALSE, 'You must qualify NEET UG of the same year');
CALL sp_seed_other(NULL, 'NATIONALITY', 'INDIAN', TRUE, 'Citizens of India');

-- =================== PHARMACY ===================

CALL sp_seed_exam('GPAT', 'Graduate Pharmacy Aptitude Test', 'GPAT', 'PHARMACY', 'NBEMS',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 3, 5,
     'Computer-based test', 'M.Pharm admission with AICTE scholarship; used by some recruiters', 'https://natboard.edu.in',
     'National pharmacy PG entrance. Final-year B.Pharm students may appear.', 'LIKELY', @src);
CALL sp_seed_exam_info('Rs 3500 (General / OBC / EWS), Rs 2500 (SC / ST / PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'B.Pharm', NULL, NULL, NULL, NULL, TRUE, NULL, NULL, 'B.Pharm (including lateral entry); final-year students may appear');

CALL sp_seed_exam('NIPER_JEE', 'NIPER Joint Entrance Examination', 'NIPER JEE', 'PHARMACY', 'NIPER',
     'NATIONAL', NULL, 'GOVERNMENT', 'ADMISSION', 1.0, 4, 6,
     'Computer-based test → Counselling', 'M.S. (Pharm), M.Pharm, M.Tech (Pharm), MBA (Pharm) and PhD at the 7 NIPERs', 'https://niperhyd.ac.in',
     'Common entrance for the National Institutes of Pharmaceutical Education and Research.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Rs 3000 (Rs 1500 for SC/ST/PwBD)', 'No attempt limit.');
CALL sp_seed_age(NULL, NULL, NULL, 'NOT_MORE_THAN', 'NONE', NULL, NULL, 'No age limit');
CALL sp_seed_attempt(NULL, NULL, NULL, 'PER_SITTING', NULL, NULL, 'No attempt limit');
CALL sp_seed_qual(NULL, 'UG', 'B.Pharm', NULL, 60, 55, 'SC,ST,PWBD', TRUE, NULL, NULL, 'B.Pharm with 60% (55% SC/ST/PwBD); other degrees for some programmes');

CALL sp_seed_exam('DRUG_INSPECTOR', 'Drug Inspector (State PSC / UPSC) - generic', 'Drug Inspector', 'PHARMACY', 'STATE_PSC_GENERIC',
     'NATIONAL', NULL, 'GOVERNMENT', 'RECRUITMENT', 0.5, NULL, NULL,
     'Written test → Interview (varies by state)', 'Drug Inspector / Drug Control Officer', NULL,
     'Generic entry: state PSCs and UPSC recruit drug inspectors irregularly. Age limits vary widely by state.', 'NEEDS_VERIFICATION', @src);
CALL sp_seed_exam_info('Varies by commission', 'No attempt limit within the age limit.');
CALL sp_seed_age(NULL, 21, 35, 'NOT_MORE_THAN', 'FIXED_DATE_IN_CYCLE_YEAR', 1, 1, 'Typical: 21-35 (varies by state)');
CALL sp_seed_relax_central(0, 'ADD', FALSE);
CALL sp_seed_attempt(NULL, NULL, NULL, 'APPEARED_IN_FIRST_STAGE', NULL, NULL, 'No attempt limit within the age limit');
CALL sp_seed_qual(NULL, 'UG', 'B.Pharm,B.Sc', 'PHARMACY|PHARMACEUTICAL CHEMISTRY|CLINICAL PHARMACOLOGY|MICROBIOLOGY', NULL, NULL, NULL, FALSE, NULL, NULL, 'Degree in Pharmacy / Pharmaceutical Chemistry, or Medicine with clinical pharmacology / microbiology (Drugs & Cosmetics Rules)');

SELECT 'Medical, nursing and pharmacy exams seeded' AS status,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'MEDICAL')             AS medical,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'NURSING_PARAMEDICAL') AS nursing,
       (SELECT COUNT(*) FROM exam e JOIN exam_category c ON c.id = e.category_id WHERE c.code = 'PHARMACY')            AS pharmacy;
