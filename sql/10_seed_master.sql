-- ============================================================
-- AspirantOS - 10_seed_master.sql
-- Run after 05_seed_helpers.sql. Seeds the master data:
--   * 28 states + 8 union territories   (state_master)
--   * 25 exam categories               (exam_category)
--   * the main conducting bodies        (conducting_body; the exam seed files
--                                        11-24 add the more specific ones)
--   * application settings             (app_setting; simulation_date EMPTY)
-- Re-runnable: INSERT ... ON DUPLICATE KEY UPDATE on the natural codes.
-- ============================================================

USE aspirantos;

-- ---------- states and union territories ----------
INSERT INTO state_master (code, name, type) VALUES
('AP','Andhra Pradesh','STATE'), ('AR','Arunachal Pradesh','STATE'), ('AS','Assam','STATE'),
('BR','Bihar','STATE'), ('CG','Chhattisgarh','STATE'), ('GA','Goa','STATE'),
('GJ','Gujarat','STATE'), ('HR','Haryana','STATE'), ('HP','Himachal Pradesh','STATE'),
('JH','Jharkhand','STATE'), ('KA','Karnataka','STATE'), ('KL','Kerala','STATE'),
('MP','Madhya Pradesh','STATE'), ('MH','Maharashtra','STATE'), ('MN','Manipur','STATE'),
('ML','Meghalaya','STATE'), ('MZ','Mizoram','STATE'), ('NL','Nagaland','STATE'),
('OD','Odisha','STATE'), ('PB','Punjab','STATE'), ('RJ','Rajasthan','STATE'),
('SK','Sikkim','STATE'), ('TN','Tamil Nadu','STATE'), ('TS','Telangana','STATE'),
('TR','Tripura','STATE'), ('UP','Uttar Pradesh','STATE'), ('UK','Uttarakhand','STATE'),
('WB','West Bengal','STATE'),
('AN','Andaman and Nicobar Islands','UT'), ('CH','Chandigarh','UT'),
('DH','Dadra and Nagar Haveli and Daman and Diu','UT'), ('DL','Delhi','UT'),
('JK','Jammu and Kashmir','UT'), ('LA','Ladakh','UT'), ('LD','Lakshadweep','UT'),
('PY','Puducherry','UT')
AS new ON DUPLICATE KEY UPDATE name = new.name, type = new.type;

-- ---------- exam categories (tiles on the landing page and explorer) ----------
INSERT INTO exam_category (code, name, short_description, icon_svg_name, accent_color, sort_order) VALUES
('CIVIL_SERVICES',      'Civil Services',              'UPSC civil services and other UPSC recruitment exams',        'landmark',    '#0F1B33', 10),
('SSC',                 'SSC',                         'Staff Selection Commission exams for central government posts','pen',         '#2D5BA8', 20),
('BANKING',             'Banking',                     'Public sector bank, RBI, NABARD and other financial regulators','bank',       '#1F7A4F', 30),
('INSURANCE',           'Insurance',                   'LIC and public sector general insurance companies',          'umbrella',    '#2F8F83', 40),
('RAILWAYS',            'Railways',                    'Railway Recruitment Boards and the Railway Protection Force', 'train',       '#B93A2B', 50),
('DEFENCE',             'Defence',                     'Army, Navy, Air Force and Coast Guard officer and other entries','shield',    '#3E5C3A', 60),
('POLICE_CAPF',         'Police & CAPF',               'State police, central armed police forces and intelligence', 'badge',       '#4A4E69', 70),
('STATE_PSC',           'State PSC',                   'State public service commission civil services exams',      'map',         '#7A4E2D', 80),
('STATE_SSB',           'State Selection Boards',      'State subordinate service selection boards and CETs',       'building',    '#8C5E3C', 90),
('TEACHING',            'Teaching',                    'Teacher eligibility tests, NET/SET and teacher recruitment', 'book',        '#C98A0B', 100),
('JUDICIARY_LAW',       'Judiciary & Law',             'Law entrance tests, bar exam and judicial services',        'scale',       '#5B4FA8', 110),
('ENGINEERING_ENTRANCE','Engineering Entrance',        'Undergraduate engineering and science entrance exams',      'gear',        '#E8792B', 120),
('ENGINEERING_PG_PSU',  'Engineering PG & PSU',        'GATE, science recruitment and PSU entries',                 'cog',         '#D0652A', 130),
('MEDICAL',             'Medical',                     'NEET UG/PG, INI-CET, FMGE and medical recruitment',         'stethoscope', '#C0392B', 140),
('NURSING_PARAMEDICAL', 'Nursing & Paramedical',       'Nursing admissions and nursing officer recruitment',        'heart',       '#D35D6E', 150),
('PHARMACY',            'Pharmacy',                    'GPAT, NIPER and drug inspector exams',                     'flask',       '#9B59B6', 160),
('MANAGEMENT',          'Management',                  'MBA and integrated management entrance tests',             'briefcase',   '#16698C', 170),
('DESIGN_ARCH',         'Design & Architecture',       'Design, fashion and architecture aptitude tests',          'compass',     '#C2185B', 180),
('SCIENCE_RESEARCH',    'Science & Research',          'Research fellowships and science institute admissions',    'atom',        '#00796B', 190),
('AGRICULTURE_VET',     'Agriculture & Veterinary',    'ICAR, ASRB and agriculture university entrances',          'leaf',        '#558B2F', 200),
('PROFESSIONAL_FINANCE','Professional & Finance',      'CA, CS, CMA, CFA, FRM and NISM certifications',            'calculator',  '#455A64', 210),
('UNIVERSITY_ENTRANCE', 'University Entrance',         'CUET and university-level entrance tests',                 'university',  '#3949AB', 220),
('SCHOOL_LEVEL',        'School Level',                'Navodaya, Sainik School, scholarships and olympiads',      'school',      '#F57C00', 230),
('HOTEL_MGMT',          'Hotel Management',            'Hotel management and catering entrance tests',             'chef',        '#8D6E63', 240),
('INTERNATIONAL',       'International Tests',         'GRE, GMAT, SAT, IELTS, TOEFL and other global tests',      'globe',       '#1E88E5', 250)
AS new ON DUPLICATE KEY UPDATE name = new.name, short_description = new.short_description,
    icon_svg_name = new.icon_svg_name, accent_color = new.accent_color, sort_order = new.sort_order;

-- ---------- main conducting bodies ----------
INSERT INTO conducting_body (short_name, full_name, website, body_type) VALUES
('UPSC',   'Union Public Service Commission',               'https://upsc.gov.in',          'CENTRAL_GOVT'),
('SSC',    'Staff Selection Commission',                    'https://ssc.gov.in',           'CENTRAL_GOVT'),
('IBPS',   'Institute of Banking Personnel Selection',      'https://www.ibps.in',          'AUTONOMOUS'),
('SBI',    'State Bank of India',                           'https://sbi.co.in/web/careers','PSU'),
('RBI',    'Reserve Bank of India',                         'https://opportunities.rbi.org.in','CENTRAL_GOVT'),
('NTA',    'National Testing Agency',                       'https://nta.ac.in',            'AUTONOMOUS'),
('RRB',    'Railway Recruitment Boards',                    'https://indianrailways.gov.in','CENTRAL_GOVT'),
('NBEMS',  'National Board of Examinations in Medical Sciences','https://natboard.edu.in',  'AUTONOMOUS'),
('IIT',    'Indian Institutes of Technology (organising institute)','https://www.iitsystem.ac.in','AUTONOMOUS'),
('IIM',    'Indian Institutes of Management (CAT convening IIM)','https://iimcat.ac.in',     'AUTONOMOUS'),
('CBSE',   'Central Board of Secondary Education',          'https://ctet.nic.in',          'CENTRAL_GOVT'),
('ARMY',   'Indian Army',                                   'https://joinindianarmy.nic.in','CENTRAL_GOVT'),
('NAVY',   'Indian Navy',                                   'https://www.joinindiannavy.gov.in','CENTRAL_GOVT'),
('IAF',    'Indian Air Force',                              'https://afcat.cdac.in',        'CENTRAL_GOVT'),
('ICG',    'Indian Coast Guard',                            'https://joinindiancoastguard.cdac.in','CENTRAL_GOVT'),
('GMAC',   'Graduate Management Admission Council',         'https://www.mba.com',          'INTERNATIONAL'),
('ETS',    'Educational Testing Service',                   'https://www.ets.org',          'INTERNATIONAL'),
('ICAI',   'Institute of Chartered Accountants of India',   'https://www.icai.org',         'AUTONOMOUS'),
('ICSI',   'Institute of Company Secretaries of India',     'https://www.icsi.edu',         'AUTONOMOUS'),
('ICMAI',  'Institute of Cost Accountants of India',        'https://icmai.in',             'AUTONOMOUS')
AS new ON DUPLICATE KEY UPDATE full_name = new.full_name, website = new.website, body_type = new.body_type;

-- ---------- application settings ----------
-- simulation_date stays EMPTY (= use the real date). The admin may set it on demo day.
INSERT INTO app_setting (setting_key, setting_value, description) VALUES
('simulation_date', '', 'If set (YYYY-MM-DD) the eligibility engine uses this date as today; empty = real date'),
('update_check_timeout_seconds', '15', 'Timeout for fetching an official exam page in Check for updates'),
('upcoming_cycles_to_plan', '15', 'How many future exam cycles the eligibility horizon looks at')
AS new ON DUPLICATE KEY UPDATE description = new.description;
-- (setting_value is not overwritten on re-run, so an admin's change survives)

SELECT 'Master data ready' AS status,
       (SELECT COUNT(*) FROM state_master)    AS states_and_uts,
       (SELECT COUNT(*) FROM exam_category)   AS categories,
       (SELECT COUNT(*) FROM conducting_body) AS bodies;
