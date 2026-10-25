-- ============================================================
-- AspirantOS - 29_verified_sources.sql
-- Run after all exam seed files (11-24). Marks the flagship exams whose rules were checked
-- against the OFFICIAL notification / information bulletin on 25-Oct-2026 (task P2.16) as
-- VERIFIED, with the verification date and the official URL. Details: docs/DATA_SOURCES.md.
-- Uses sp_mark_verified from 05_seed_helpers.sql. Re-runnable.
-- The seed procedure never downgrades a VERIFIED exam when a seed file is run again.
-- Flagship exams NOT listed here could not be checked against an official PDF on that day
-- (see DATA_SOURCES.md) and keep LIKELY / NEEDS_VERIFICATION.
-- ============================================================

USE aspirantos;

SET @d = '2026-10-25';

-- UPSC
CALL sp_mark_verified('UPSC_CSE',  @d, 'https://www.upsc.gov.in/sites/default/files/Notif-CSP-2026-Engl-060226Rev.pdf',
     'Verified against UPSC Exam Notice 05/2026-CSE dated 04-02-2026.');
CALL sp_mark_verified('UPSC_IFOS', @d, 'https://www.upsc.gov.in/sites/default/files/Notif-IFSP-2026-Engl-060226Rev.pdf',
     'Verified against the UPSC notice for IFS (P) Examination 2026 through CS (P) 2026.');
CALL sp_mark_verified('UPSC_ESE',  @d, 'https://www.upsc.gov.in/sites/default/files/Notif-ESEP-2027-Engl-160926.pdf',
     'Verified against the UPSC notice for Engineering Services (P) Examination 2027 dated 16-09-2026.');
CALL sp_mark_verified('UPSC_NDA',  @d, 'https://www.upsc.gov.in/sites/default/files/Notif-NDA-II-2026-Engl-200526.pdf',
     'Verified against the UPSC notices for NDA & NA (I) 2026 and (II) 2026; the stored window covers both sittings.');
CALL sp_mark_verified('UPSC_CDS',  @d, 'https://www.upsc.gov.in/sites/default/files/Notif-CDS-II-2026-Engl-200526.pdf',
     'Verified against the UPSC notices for CDS (I) 2026 and CDS (II) 2026; the stored windows cover both sittings.');
CALL sp_mark_verified('UPSC_CAPF', @d, 'https://www.upsc.gov.in/sites/default/files/ExamNotifi_CAPF_AC_Exam_2026_Eng_20022026.pdf',
     'Verified against the UPSC notice for CAPF (ACs) Examination 2026 dated 20-02-2026.');

-- SSC
CALL sp_mark_verified('SSC_CGL',  @d, 'https://ssc.gov.in/api/attachment/uploads/masterData/NoticeBoards/Notice_of_adv_cgl_2026.pdf',
     'Verified against the SSC Notice of Combined Graduate Level Examination 2026 dated 21-05-2026.');
CALL sp_mark_verified('SSC_CHSL', @d, 'https://ssc.gov.in/api/attachment/uploads/masterData/NoticeBoards/Notice_of_adv_chsl_2025.pdf',
     'Verified against the SSC Notice of CHSLE 2025 (latest published; crucial date 01-01-2026).');
CALL sp_mark_verified('SSC_MTS',  @d, 'https://ssc.gov.in/api/attachment/uploads/masterData/NoticeBoards/Notice_of_adv_mts_2025.pdf',
     'Verified against the SSC Notice of MTS (NT) & Havaldar Examination 2025 (latest published; crucial date 01-08-2025).');
CALL sp_mark_verified('SSC_GD',   @d, 'https://ssc.gov.in/api/attachment/uploads/masterData/NoticeBoards/Notice_of_CTGD_2026.pdf',
     'Verified against the SSC Notice of Constable (GD) Examination 2026 dated 01-12-2025.');
CALL sp_mark_verified('SSC_CPO',  @d, 'https://ssc.gov.in/api/attachment/uploads/masterData/NoticeBoards/Notice_of_adv_capf_2025.pdf',
     'Verified against the SSC Notice of SI in Delhi Police & CAPFs Examination 2025 (latest published).');

-- Banking
CALL sp_mark_verified('IBPS_PO',        @d, 'https://www.ibps.in/wp-content/uploads/Detailed-Notification_CRP-PO-XVI_Final_V1_30.06.2026.pdf',
     'Verified against IBPS CRP PO/MT-XVI detailed notification dated 30-06-2026.');
CALL sp_mark_verified('IBPS_CLERK',     @d, 'https://www.ibps.in/wp-content/uploads/Notification_CRP_CSA_XVI-Final.pdf',
     'Verified against IBPS CRP CSA-XVI (Clerks) notification.');
CALL sp_mark_verified('IBPS_RRB_PO',    @d, 'https://www.ibps.in/wp-content/uploads/CRP-RRBs-XV-notification_Revised.pdf',
     'Verified against IBPS CRP RRBs-XV notification (revised).');
CALL sp_mark_verified('IBPS_RRB_CLERK', @d, 'https://www.ibps.in/wp-content/uploads/CRP-RRBs-XV-notification_Revised.pdf',
     'Verified against IBPS CRP RRBs-XV notification (revised).');
CALL sp_mark_verified('SBI_PO',         @d, 'https://sbi.bank.in/documents/77530/57941/18062026_1_Detailed_Adv.2026.pdf/1f1a9532-8a2f-6e59-08a0-616d62a497b1',
     'Verified against SBI advertisement CRPD/PO/2026-27/09 dated 18-06-2026 (number of chances 6 / 9 / no restriction).');
CALL sp_mark_verified('SBI_CLERK',      @d, 'https://sbi.bank.in/webfiles/uploads/files_2627/08/JA_2026_Detailed_Advt_Eng.pdf',
     'Verified against the SBI Junior Associates 2026 detailed advertisement.');

-- Entrance tests
CALL sp_mark_verified('JEE_MAIN',     @d, 'https://cdnbbsr.s3waas.gov.in/s3f8e59f4b2fe7c5705bf878bbd494ccdf/uploads/2026/10/202610241890224107.pdf',
     'Verified against the NTA Information Bulletin JEE (Main) 2027 dated 24-10-2026.');
CALL sp_mark_verified('JEE_ADVANCED', @d, 'https://jeeadv.ac.in/documents/IBEnglish_2026.pdf',
     'Verified against the JEE (Advanced) 2026 Information Brochure.');
CALL sp_mark_verified('NEET_UG',      @d, 'https://cdnbbsr.s3waas.gov.in/s37bc1ec1d9c3426357e69acd5bf320061/uploads/2026/02/202602231394640855.pdf',
     'Verified against the NTA Information Bulletin NEET (UG) 2026.');
CALL sp_mark_verified('GATE',         @d, 'https://gate2027.iitm.ac.in/eligibility_criteria',
     'Verified against the GATE 2027 eligibility page of IIT Madras (organising institute).');
CALL sp_mark_verified('CAT',          @d, 'https://cdn.digialm.com/per/g06/pub/32842/EForms/image/CAT2026/CAT_2026_Eligibility_26-07-26.pdf',
     'Verified against the CAT 2026 eligibility document dated 26-07-2026.');
CALL sp_mark_verified('CLAT_UG',      @d, 'https://consortiumofnlus.ac.in/clat-2027/ug-eligibility.html',
     'Verified against the CLAT 2027 UG eligibility page of the Consortium of NLUs.');
CALL sp_mark_verified('CUET_UG',      @d, 'https://cdnbbsr.s3waas.gov.in/s3d1a21da7bca4abff8b0b61b87597de73/uploads/2026/01/202601031633478370.pdf',
     'Verified against the NTA Information Bulletin CUET (UG) 2026.');
CALL sp_mark_verified('IPMAT_INDORE', @d, 'https://iimidr.ac.in/wp-content/uploads/2026/01/AdmissionProcedure_IPM-2026-31_-Domestic-Applicants.pdf',
     'Verified against the IIM Indore admission procedure IPM 2026-31 (domestic applicants).');

-- Teaching
CALL sp_mark_verified('UGC_NET',  @d, 'https://cdnbbsr.s3waas.gov.in/s301eee509ee2f68dc6014898c309e86bf/uploads/2026/10/202610161905649093.pdf',
     'Verified against the NTA Information Bulletin UGC-NET December 2026.');
CALL sp_mark_verified('CSIR_NET', @d, 'https://cdnbbsr.s3waas.gov.in/s3efdf562ce2fb0ad460fd8e9d33e57f57/uploads/2026/10/202610071407707951.pdf',
     'Verified against the NTA Information Bulletin Joint CSIR-UGC NET December 2026.');
CALL sp_mark_verified('CTET',     @d, 'https://cdnbbsr.s3waas.gov.in/s3443dec3062d0286986e21dc0631734c9/uploads/2026/05/202605111250310617.pdf',
     'Verified against the CBSE CTET September 2026 Information Bulletin (qualifications as notified by NCTE).');

SELECT 'Flagship verification applied' AS status,
       (SELECT COUNT(*) FROM exam WHERE data_confidence = 'VERIFIED') AS verified_exams;
