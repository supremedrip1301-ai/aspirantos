-- ============================================================
-- AspirantOS - 30_seed_doc_specs.sql
-- Photo / signature / thumb / declaration upload rules per exam (shown read-only on the
-- exam page). Run after the exam seeds (11-24) and 29_verified_sources.sql. Re-runnable:
-- INSERT ... SELECT ... ON DUPLICATE KEY UPDATE on UNIQUE (exam_id, doc_type).
-- (MySQL does not allow the "AS new" row alias with INSERT ... SELECT, so each SELECT is
--  wrapped in a derived table "src" and the update reads src.column.)
--
-- Where a value comes from an official notice read on 25-Oct-2026 the note starts with
-- "Official:". Every other exam gets a typical spec whose note says "not verified"; the exam
-- page shows the note next to the table. "Preferred" pixel sizes are stored as min = max.
-- ============================================================

USE aspirantos;

-- ---------- UPSC (all UPSC exams use the same online application rules) ----------
INSERT INTO doc_spec (exam_id, doc_type, min_kb, max_kb, allowed_formats, background_rule, notes)
SELECT * FROM (
    SELECT e.id AS exam_id, 'PHOTO' AS doc_type, 20 AS min_kb, 200 AS max_kb, 'JPG,JPEG' AS allowed_formats,
           'WHITE_OR_LIGHT' AS background_rule,
           'Official: UPSC notices 2026 - photograph 20 KB to 200 KB in .jpg (recent, front-facing)' AS notes
    FROM exam e JOIN conducting_body b ON b.id = e.body_id WHERE b.short_name = 'UPSC'
    UNION ALL
    SELECT e.id, 'SIGNATURE', 20, 100, 'JPG,JPEG', NULL,
           'Official: UPSC notices 2026 - signature 20 KB to 100 KB in .jpg'
    FROM exam e JOIN conducting_body b ON b.id = e.body_id WHERE b.short_name = 'UPSC'
) AS src
ON DUPLICATE KEY UPDATE min_kb = src.min_kb, max_kb = src.max_kb, allowed_formats = src.allowed_formats,
    background_rule = src.background_rule, notes = src.notes;

-- ---------- SSC (live photo captured by the application; scanned signature) ----------
INSERT INTO doc_spec (exam_id, doc_type, min_kb, max_kb, allowed_formats, background_rule, notes)
SELECT * FROM (
    SELECT e.id AS exam_id, 'PHOTO' AS doc_type, NULL AS min_kb, NULL AS max_kb, 'LIVE_CAPTURE' AS allowed_formats,
           'PLAIN_LIGHT' AS background_rule,
           'Official: SSC notices 2025-26 - the photograph is captured live by the application (web cam / mobile app); no cap or spectacles, full frontal view' AS notes
    FROM exam e JOIN conducting_body b ON b.id = e.body_id WHERE b.short_name = 'SSC'
    UNION ALL
    SELECT e.id, 'SIGNATURE', 10, 20, 'JPG,JPEG', NULL,
           'Official: SSC CGL 2026 notice - signature 10 KB to 20 KB, about 6.0 cm (width) x 2.0 cm (height)'
    FROM exam e JOIN conducting_body b ON b.id = e.body_id WHERE b.short_name = 'SSC'
) AS src
ON DUPLICATE KEY UPDATE min_kb = src.min_kb, max_kb = src.max_kb, allowed_formats = src.allowed_formats,
    background_rule = src.background_rule, notes = src.notes;

-- ---------- IBPS and SBI (four documents) ----------
INSERT INTO doc_spec (exam_id, doc_type, min_width_px, max_width_px, min_height_px, max_height_px,
                      min_kb, max_kb, allowed_formats, background_rule, notes)
SELECT * FROM (
    SELECT e.id AS exam_id, d.doc_type, d.w AS min_width_px, d.w AS max_width_px, d.h AS min_height_px,
           d.h AS max_height_px, d.min_kb, d.max_kb, 'JPG,JPEG' AS allowed_formats, d.bg AS background_rule, d.note AS notes
    FROM exam e
    JOIN conducting_body b ON b.id = e.body_id
    JOIN (
        SELECT 'PHOTO' AS doc_type, 200 AS w, 230 AS h, 20 AS min_kb, 50 AS max_kb, 'WHITE_OR_LIGHT' AS bg,
               'Official: IBPS CRP PO/MT-XVI & CSA-XVI, SBI PO 2026 - 200 x 230 px (preferred), 20-50 KB' AS note
        UNION ALL SELECT 'SIGNATURE', 140, 60, 10, 20, NULL,
               'Official: IBPS / SBI 2026 - 140 x 60 px (preferred), 10-20 KB, black ink on white paper'
        UNION ALL SELECT 'LEFT_THUMB', 240, 240, 20, 50, NULL,
               'Official: IBPS / SBI 2026 - 240 x 240 px at 200 DPI (3 x 3 cm), 20-50 KB'
        UNION ALL SELECT 'HANDWRITTEN_DECLARATION', 800, 400, 50, 100, NULL,
               'Official: IBPS / SBI 2026 - 800 x 400 px at 200 DPI (10 x 5 cm), 50-100 KB, written in English in your own handwriting'
    ) d
    WHERE b.short_name IN ('IBPS', 'SBI')
) AS src
ON DUPLICATE KEY UPDATE min_width_px = src.min_width_px, max_width_px = src.max_width_px,
    min_height_px = src.min_height_px, max_height_px = src.max_height_px, min_kb = src.min_kb, max_kb = src.max_kb,
    allowed_formats = src.allowed_formats, background_rule = src.background_rule, notes = src.notes;

-- ---------- NTA and CBSE (official bulletins 2026-27) ----------
INSERT INTO doc_spec (exam_id, doc_type, min_kb, max_kb, allowed_formats, background_rule, notes)
SELECT * FROM (
    SELECT e.id AS exam_id, d.doc_type, d.min_kb, d.max_kb, 'JPG,JPEG' AS allowed_formats, d.bg AS background_rule, d.note AS notes
    FROM exam e
    JOIN (
        SELECT 'JEE_MAIN' AS code, 'PHOTO' AS doc_type, 10 AS min_kb, 200 AS max_kb, 'WHITE_OR_LIGHT' AS bg, 'Official: JEE (Main) 2027 bulletin - photograph 10 KB to 200 KB' AS note
        UNION ALL SELECT 'JEE_MAIN', 'SIGNATURE', 10, 100, NULL, 'Official: JEE (Main) 2027 bulletin - signature 10 KB to 100 KB'
        UNION ALL SELECT 'NEET_UG', 'PHOTO', 10, 200, 'WHITE_OR_LIGHT', 'Official: NEET (UG) 2026 bulletin - passport-size photograph 10 KB to 200 KB (a postcard-size photo is also asked)'
        UNION ALL SELECT 'NEET_UG', 'SIGNATURE', 10, 100, NULL, 'Official: NEET (UG) 2026 bulletin - signature 10 KB to 100 KB'
        UNION ALL SELECT 'NEET_UG', 'LEFT_THUMB', 10, 200, NULL, 'Official: NEET (UG) 2026 bulletin - left and right hand fingers and thumb impressions 10 KB to 200 KB'
        UNION ALL SELECT 'CUET_UG', 'PHOTO', 10, 200, 'WHITE_OR_LIGHT', 'Official: CUET (UG) 2026 bulletin - photograph 10 KB to 200 KB'
        UNION ALL SELECT 'CUET_UG', 'SIGNATURE', 10, 50, NULL, 'Official: CUET (UG) 2026 bulletin - signature 10 KB to 50 KB'
        UNION ALL SELECT 'UGC_NET', 'PHOTO', 10, 200, 'WHITE', 'Official: UGC-NET Dec 2026 bulletin - 10-200 KB, 80% face (without mask) visible including ears, white background'
        UNION ALL SELECT 'UGC_NET', 'SIGNATURE', 10, 50, NULL, 'Official: UGC-NET Dec 2026 bulletin - signature 10 KB to 50 KB'
        UNION ALL SELECT 'CSIR_NET', 'PHOTO', 10, 200, 'WHITE_OR_LIGHT', 'Official: Joint CSIR-UGC NET Dec 2026 bulletin - photograph 10 KB to 200 KB'
        UNION ALL SELECT 'CSIR_NET', 'SIGNATURE', 10, 50, NULL, 'Official: Joint CSIR-UGC NET Dec 2026 bulletin - signature 10 KB to 50 KB'
        UNION ALL SELECT 'CTET', 'PHOTO', 10, 100, 'WHITE_OR_LIGHT', 'Official: CTET September 2026 bulletin - photograph 10 KB to 100 KB'
        UNION ALL SELECT 'CTET', 'SIGNATURE', 3, 30, NULL, 'Official: CTET September 2026 bulletin - signature 3 KB to 30 KB'
    ) d ON d.code = e.code
) AS src
ON DUPLICATE KEY UPDATE min_kb = src.min_kb, max_kb = src.max_kb, allowed_formats = src.allowed_formats,
    background_rule = src.background_rule, notes = src.notes;

-- Other NTA exams (CMAT, JIPMAT, AIAPGET, ICAR, AISSEE, NCHM JEE ...) follow the usual NTA format.
INSERT INTO doc_spec (exam_id, doc_type, min_kb, max_kb, allowed_formats, background_rule, notes)
SELECT e.id, d.doc_type, d.min_kb, d.max_kb, 'JPG,JPEG', d.bg, d.note
FROM exam e
JOIN conducting_body b ON b.id = e.body_id AND b.short_name = 'NTA'
JOIN (
    SELECT 'PHOTO' AS doc_type, 10 AS min_kb, 200 AS max_kb, 'WHITE_OR_LIGHT' AS bg, 'Typical NTA format (10-200 KB) - not verified for this exam' AS note
    UNION ALL SELECT 'SIGNATURE', 10, 50, NULL, 'Typical NTA format (10-50 KB) - not verified for this exam'
) d
WHERE NOT EXISTS (SELECT 1 FROM doc_spec s WHERE s.exam_id = e.id AND s.doc_type = d.doc_type);

-- ---------- every other exam: a typical spec, clearly marked as not verified ----------
INSERT INTO doc_spec (exam_id, doc_type, min_kb, max_kb, allowed_formats, background_rule, notes)
SELECT e.id, 'PHOTO', 20, 50, 'JPG,JPEG', 'WHITE_OR_LIGHT',
       'Typical values (recent passport-size colour photo, 20-50 KB) - not verified; check the notification of this exam'
FROM exam e
WHERE NOT EXISTS (SELECT 1 FROM doc_spec s WHERE s.exam_id = e.id AND s.doc_type = 'PHOTO');

INSERT INTO doc_spec (exam_id, doc_type, min_kb, max_kb, allowed_formats, notes)
SELECT e.id, 'SIGNATURE', 10, 20, 'JPG,JPEG',
       'Typical values (black ink on white paper, 10-20 KB) - not verified; check the notification of this exam'
FROM exam e
WHERE NOT EXISTS (SELECT 1 FROM doc_spec s WHERE s.exam_id = e.id AND s.doc_type = 'SIGNATURE');

SELECT 'Document specs ready' AS status,
       (SELECT COUNT(*) FROM doc_spec) AS doc_specs,
       (SELECT COUNT(*) FROM doc_spec WHERE notes LIKE 'Official:%') AS from_official_notices,
       (SELECT COUNT(*) FROM exam e WHERE NOT EXISTS (SELECT 1 FROM doc_spec s WHERE s.exam_id = e.id AND s.doc_type = 'PHOTO')) AS exams_without_photo_spec;
