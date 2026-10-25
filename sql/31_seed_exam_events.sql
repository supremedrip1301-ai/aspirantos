-- ============================================================
-- AspirantOS - 31_seed_exam_events.sql
-- Exam calendar (notification, application window, exam stages, result).
-- Run after the exam seeds. Re-runnable (UNIQUE exam_id + cycle_year + event_type).
--
-- Part 1: OFFICIAL dates (is_tentative = FALSE) copied from official documents read on
--         25-26 Oct 2026: UPSC Programme of Examinations 2027 (as on 20-05-2026),
--         NTA JEE (Main) 2027 bulletin, GATE 2027 important dates (IIT Madras),
--         NTA UGC-NET December 2026 bulletin. Official dates still say "liable to alteration".
-- Part 2: TENTATIVE dates for every other exam and cycle, built from the exam's
--         typical_notification_month / typical_exam_month (15th of the month), so the
--         calendar and the "upcoming" lists are never empty. They are clearly marked tentative.
-- ============================================================

USE aspirantos;

-- ---------- Part 1: official dates ----------
INSERT INTO exam_event (exam_id, cycle_year, event_type, event_date, is_tentative, notes)
SELECT * FROM (
    SELECT e.id AS exam_id, d.cycle_year, d.event_type, d.event_date, FALSE AS is_tentative, d.notes
    FROM exam e
    JOIN (
        -- UPSC Programme of Examinations 2027 (calendar dated 20-05-2026)
        SELECT 'UPSC_CGS' AS code, 2027 AS cycle_year, 'NOTIFICATION' AS event_type, DATE('2026-09-02') AS event_date, 'UPSC calendar 2027: notification' AS notes
        UNION ALL SELECT 'UPSC_CGS', 2027, 'APPLY_END', '2026-09-22', 'UPSC calendar 2027: last date for applications'
        UNION ALL SELECT 'UPSC_CGS', 2027, 'STAGE_1',   '2027-01-10', 'UPSC calendar 2027: Combined Geo-Scientist (Preliminary)'
        UNION ALL SELECT 'UPSC_CGS', 2027, 'STAGE_2',   '2027-06-19', 'UPSC calendar 2027: Combined Geo-Scientist (Main)'
        UNION ALL SELECT 'UPSC_ESE', 2027, 'NOTIFICATION', '2026-09-16', 'UPSC calendar 2027: notification'
        UNION ALL SELECT 'UPSC_ESE', 2027, 'APPLY_END', '2026-10-06', 'UPSC calendar 2027: last date for applications'
        UNION ALL SELECT 'UPSC_ESE', 2027, 'STAGE_1',   '2027-01-31', 'UPSC calendar 2027: Engineering Services (Preliminary)'
        UNION ALL SELECT 'UPSC_ESE', 2027, 'STAGE_2',   '2027-06-18', 'UPSC calendar 2027: Engineering Services (Main)'
        UNION ALL SELECT 'UPSC_NDA', 2027, 'NOTIFICATION', '2026-12-02', 'UPSC calendar 2027: NDA & NA (I) notification'
        UNION ALL SELECT 'UPSC_NDA', 2027, 'APPLY_END', '2026-12-22', 'UPSC calendar 2027: NDA & NA (I) last date'
        UNION ALL SELECT 'UPSC_NDA', 2027, 'STAGE_1',   '2027-04-11', 'UPSC calendar 2027: NDA & NA (I) exam (NDA II: 19-09-2027, notification 12-05-2027)'
        UNION ALL SELECT 'UPSC_CDS', 2027, 'NOTIFICATION', '2026-12-02', 'UPSC calendar 2027: CDS (I) notification'
        UNION ALL SELECT 'UPSC_CDS', 2027, 'APPLY_END', '2026-12-22', 'UPSC calendar 2027: CDS (I) last date'
        UNION ALL SELECT 'UPSC_CDS', 2027, 'STAGE_1',   '2027-04-11', 'UPSC calendar 2027: CDS (I) exam (CDS II: 19-09-2027, notification 12-05-2027)'
        UNION ALL SELECT 'UPSC_CSE', 2027, 'NOTIFICATION', '2027-01-13', 'UPSC calendar 2027: CSE notification'
        UNION ALL SELECT 'UPSC_CSE', 2027, 'APPLY_END', '2027-02-02', 'UPSC calendar 2027: last date for applications'
        UNION ALL SELECT 'UPSC_CSE', 2027, 'STAGE_1',   '2027-05-23', 'UPSC calendar 2027: Civil Services (Preliminary)'
        UNION ALL SELECT 'UPSC_CSE', 2027, 'STAGE_2',   '2027-08-20', 'UPSC calendar 2027: Civil Services (Main), 5 days'
        UNION ALL SELECT 'UPSC_IFOS', 2027, 'NOTIFICATION', '2027-01-13', 'UPSC calendar 2027: IFoS through CS(P) notification'
        UNION ALL SELECT 'UPSC_IFOS', 2027, 'APPLY_END', '2027-02-02', 'UPSC calendar 2027: last date for applications'
        UNION ALL SELECT 'UPSC_IFOS', 2027, 'STAGE_1',   '2027-05-23', 'UPSC calendar 2027: through Civil Services (Preliminary)'
        UNION ALL SELECT 'UPSC_IFOS', 2027, 'STAGE_2',   '2027-11-21', 'UPSC calendar 2027: Indian Forest Service (Main), 7 days'
        UNION ALL SELECT 'UPSC_IES_ISS', 2027, 'NOTIFICATION', '2027-02-10', 'UPSC calendar 2027: notification'
        UNION ALL SELECT 'UPSC_IES_ISS', 2027, 'APPLY_END', '2027-03-02', 'UPSC calendar 2027: last date for applications'
        UNION ALL SELECT 'UPSC_IES_ISS', 2027, 'STAGE_1',   '2027-06-18', 'UPSC calendar 2027: IES/ISS examination, 3 days'
        UNION ALL SELECT 'UPSC_CAPF', 2027, 'NOTIFICATION', '2027-02-17', 'UPSC calendar 2027: notification'
        UNION ALL SELECT 'UPSC_CAPF', 2027, 'APPLY_END', '2027-03-09', 'UPSC calendar 2027: last date for applications'
        UNION ALL SELECT 'UPSC_CAPF', 2027, 'STAGE_1',   '2027-07-04', 'UPSC calendar 2027: CAPF (ACs) written exam'
        UNION ALL SELECT 'UPSC_CMS', 2027, 'NOTIFICATION', '2027-03-03', 'UPSC calendar 2027: notification'
        UNION ALL SELECT 'UPSC_CMS', 2027, 'APPLY_END', '2027-03-23', 'UPSC calendar 2027: last date for applications'
        UNION ALL SELECT 'UPSC_CMS', 2027, 'STAGE_1',   '2027-07-18', 'UPSC calendar 2027: Combined Medical Services exam'
        -- NTA JEE (Main) 2027 Information Bulletin (24-10-2026)
        UNION ALL SELECT 'JEE_MAIN', 2027, 'NOTIFICATION', '2026-10-24', 'JEE (Main) 2027 bulletin released'
        UNION ALL SELECT 'JEE_MAIN', 2027, 'APPLY_START', '2026-10-24', 'Session 1 online application opens'
        UNION ALL SELECT 'JEE_MAIN', 2027, 'APPLY_END',   '2026-11-22', 'Session 1 last date (up to 11:50 PM); late fee window 23-26 Nov 2026'
        UNION ALL SELECT 'JEE_MAIN', 2027, 'STAGE_1',     '2027-01-20', 'Session 1 exam: 20, 21, 22, 23, 24 and 28 January 2027'
        UNION ALL SELECT 'JEE_MAIN', 2027, 'STAGE_2',     '2027-04-01', 'Session 2 in April 2027 (applications 05-01-2027 to 03-02-2027); exact dates on the NTA website'
        -- GATE 2027 important dates (IIT Madras)
        UNION ALL SELECT 'GATE', 2027, 'STAGE_1', '2027-02-06', 'GATE 2027 exam days: 6, 7, 13, 14, 20 and 21 February 2027'
        UNION ALL SELECT 'GATE', 2027, 'RESULT',  '2027-03-19', 'GATE 2027 results'
        -- NTA UGC-NET December 2026 bulletin
        UNION ALL SELECT 'UGC_NET', 2026, 'STAGE_1', '2026-12-14', 'UGC-NET December 2026: 14 to 18 and 21 December 2026'
    ) d ON d.code = e.code
) AS src
ON DUPLICATE KEY UPDATE event_date = src.event_date, is_tentative = src.is_tentative, notes = src.notes;

-- ---------- Part 2: tentative dates from the typical months ----------
-- For cycle years 2026-2028: notification on the 15th of typical_notification_month (in the
-- year before the exam when that month comes after the exam month) and the first stage on the
-- 15th of typical_exam_month. Rows that already exist (official ones) are not touched.
INSERT INTO exam_event (exam_id, cycle_year, event_type, event_date, is_tentative, notes)
SELECT e.id, y.yr, 'NOTIFICATION',
       STR_TO_DATE(CONCAT(IF(e.typical_notification_month > e.typical_exam_month, y.yr - 1, y.yr), '-',
                          e.typical_notification_month, '-15'), '%Y-%c-%d'),
       TRUE, 'Tentative - based on the usual notification month'
FROM exam e
CROSS JOIN (SELECT 2026 AS yr UNION ALL SELECT 2027 UNION ALL SELECT 2028) y
WHERE e.is_active AND e.typical_notification_month IS NOT NULL AND e.typical_exam_month IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM exam_event x WHERE x.exam_id = e.id AND x.cycle_year = y.yr AND x.event_type = 'NOTIFICATION');

INSERT INTO exam_event (exam_id, cycle_year, event_type, event_date, is_tentative, notes)
SELECT e.id, y.yr, 'STAGE_1',
       STR_TO_DATE(CONCAT(y.yr, '-', e.typical_exam_month, '-15'), '%Y-%c-%d'),
       TRUE, 'Tentative - based on the usual exam month'
FROM exam e
CROSS JOIN (SELECT 2026 AS yr UNION ALL SELECT 2027 UNION ALL SELECT 2028) y
WHERE e.is_active AND e.typical_exam_month IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM exam_event x WHERE x.exam_id = e.id AND x.cycle_year = y.yr AND x.event_type = 'STAGE_1');

SELECT 'Exam events ready' AS status,
       (SELECT COUNT(*) FROM exam_event) AS events,
       (SELECT COUNT(*) FROM exam_event WHERE is_tentative = FALSE) AS official_dates,
       (SELECT COUNT(*) FROM v_upcoming_events) AS in_next_90_days;
