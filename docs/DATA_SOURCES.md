# AspirantOS — Data sources for the flagship exams (P2.16)

Verified on **25-Oct-2026** by reading the **official notification / information bulletin** of each exam (PDF downloaded from the official website and read as text).
Each exam below is marked `VERIFIED` in the database (`sql/29_verified_sources.sql`) with `last_verified_on = 2026-10-25` and the URL shown here.
Every other exam stays `LIKELY` / `NEEDS_VERIFICATION` and the website shows that badge.

How to read the tables:
- **Notice** = the latest official notice found on the verification date (the newest cycle that had published one).
- **Changed in seed** = what was wrong in the first seed and has been corrected in the `1x_seed_*.sql` file.
- Where an exam is held twice a year with different birth-date windows (NDA, CDS), the seed stores **one window that covers both sittings** ("eligible for at least one sitting in the year") and the note says so.

## UPSC

| Exam | Notice (official URL) | Rules confirmed | Changed in seed |
|---|---|---|---|
| UPSC CSE | Exam Notice 05/2026-CSE, 04-Feb-2026 — <https://www.upsc.gov.in/sites/default/files/Notif-CSP-2026-Engl-060226Rev.pdf> | Age 21, not attained 32 on 1 Aug 2026 (born 2 Aug 1994 – 1 Aug 2005); SC/ST +5, OBC +3, disabled defence personnel +3, ex-servicemen / ECO-SSCO +5, PwBD +10 (cumulative with SC/ST/OBC); attempts 6 (GL/EWS), 9 (OBC), unlimited (SC/ST), PwBD 9 for GL/EWS/OBC and unlimited for SC/ST; appearing in any one Prelims paper = attempt; graduate, final-year may write Prelims; IAS/IPS need Indian citizenship | **Removed the J&K 1980-89 domicile relaxation** (not in the 2026 notice) |
| UPSC IFoS | Notice for IFS (P) 2026 through CS(P) 2026 — <https://www.upsc.gov.in/sites/default/files/Notif-IFSP-2026-Engl-060226Rev.pdf> | Same age and attempts as CSE (6 / OBC 9 / SC-ST unlimited / PwBD GL-EWS 9); degree with at least one of Animal Husbandry & Vet. Science, Botany, Chemistry, Geology, Mathematics, Physics, Statistics, Zoology, or a degree in Agriculture, Forestry or Engineering | Removed J&K relaxation |
| UPSC ESE | Engineering Services (P) 2027 — <https://www.upsc.gov.in/sites/default/files/Notif-ESEP-2027-Engl-160926.pdf> | Age 21, not attained 30 on 1 Jan 2027 (born 2 Jan 1997 – 1 Jan 2006); Govt servants of listed departments up to 35; SC/ST +5, OBC +3, ex-servicemen +5, disabled defence +3, PwBD +10; engineering degree (or listed M.Sc); Prelims 31-Jan-2027 | Removed J&K relaxation; exam month changed to January |
| UPSC NDA | NDA & NA (I) 2026 — <https://www.upsc.gov.in/sites/default/files/Notif-NDA-NA-I-2026-Engl-101225.pdf>; NDA & NA (II) 2026 — <https://www.upsc.gov.in/sites/default/files/Notif-NDA-II-2026-Engl-200526.pdf> | NDA I 2026: unmarried male/female born 1 Jul 2007 – 1 Jul 2010; NDA II 2026: born 1 Jan 2008 – 1 Jan 2011; Army wing: Class 12; Air Force / Navy / 10+2 Cadet Entry: Class 12 with Physics, Chemistry, Maths; Class 12 appearing allowed | DOB window changed to the union of both sittings: born 1 Jul (year-19) – 1 Jan (year-15) |
| UPSC CDS | CDS (I) 2026 — <https://www.upsc.gov.in/sites/default/files/Notif-CDSE-I-2026-Engl-101225.pdf>; CDS (II) 2026 — <https://www.upsc.gov.in/sites/default/files/Notif-CDS-II-2026-Engl-200526.pdf> | CDS I 2026 IMA/INA: unmarried men born 2 Jan 2003 – 1 Jan 2008; CDS II 2026 IMA/INA: 1 Jul 2003 – 1 Jul 2008; AFA 20-24 (CPL holders up to 26); OTA men and women 19-25 (women: unmarried, issueless widows / divorcees); IMA & OTA: degree; INA: engineering degree or B.Sc with Physics (Physics & Maths at 10+2); AFA: degree with Physics & Maths at 10+2 or B.E. | Windows changed to the union of both sittings; INA also accepts B.Sc with Physics |
| UPSC CAPF AC | CAPF (ACs) 2026 — <https://www.upsc.gov.in/sites/default/files/ExamNotifi_CAPF_AC_Exam_2026_Eng_20022026.pdf> | Male and female; age 20, not attained 25 on 1 Aug 2026; SC/ST +5, OBC +3, civilian central govt servants +5 and ex-servicemen eligible for the same relaxation (total for govt service max 5, cumulative with SC/ST/OBC); bachelor's degree | Govt-employee and ex-serviceman relaxations made non-additive with each other (one combined 5-year relaxation) |

## SSC

Official notices are served by the SSC portal API under `https://ssc.gov.in/api/attachment/uploads/masterData/NoticeBoards/` (the notice list itself comes from `https://ssc.gov.in/api/general-website/portal/records?contentType=notice-boards`).

| Exam | Notice (official URL) | Rules confirmed | Changed in seed |
|---|---|---|---|
| SSC CGL | Notice of CGLE 2026, 21-May-2026 — <https://ssc.gov.in/api/attachment/uploads/masterData/NoticeBoards/Notice_of_adv_cgl_2026.pdf> | Age as on 01-08-2026 in four post groups 18-27, 20-30, 18-30, 18-32; SC/ST +5, OBC +3, PwBD +10/13/15, ESM 3 years after deducting service; Group C: central govt civilian employees (3 yrs) up to 40 (SC/ST 45), widows/divorced up to 35 (SC/ST 40); graduation, final-year allowed if passed by 01-08-2026; JSO: 60% Maths in Class 12 or Statistics in degree; Statistical Investigator Gr II: degree in Statistics, Maths, Economics, Demography, Population Studies, OR, IT, CS, Computer Engg/Tech/Application, Data Science or AI | OBC caps for govt employees / widows now follow the General cap (the notice lists only General and SC/ST); added the SI Gr II subject list |
| SSC CHSL | Notice of CHSLE 2025, 23-Jun-2025 — <https://ssc.gov.in/api/attachment/uploads/masterData/NoticeBoards/Notice_of_adv_chsl_2025.pdf> | Age 18-27 as on **01-01-2026** (born 2 Jan 1999 – 1 Jan 2008) for an exam held from November 2025; same relaxation table as CGL; Class 12 (DEO in C&AG: Science with Maths); Class 12 appearing allowed if passed by the crucial date | Cut-off changed to "1 January of the year after the exam" (new cutoff type `FIXED_DATE_IN_NEXT_YEAR`) and exam month to November |
| SSC MTS | Notice of MTS (NT) & Havaldar 2025, 26-Jun-2025 — <https://ssc.gov.in/api/attachment/uploads/masterData/NoticeBoards/Notice_of_adv_mts_2025.pdf> | MTS 18-25, Havaldar & a few MTS posts 18-27, as on **01-08-2025** for a CBE held in early 2026; same relaxation table | Cut-off changed to "1 August of the year before the exam"; exam month February |
| SSC GD | Notice of Constable (GD) 2026, 01-Dec-2025 — <https://ssc.gov.in/api/attachment/uploads/masterData/NoticeBoards/Notice_of_CTGD_2026.pdf> | 18-23 as on 01-01-2026 (born 2 Jan 2003 – 1 Jan 2008); SC/ST +5, OBC +3, ESM 3 after deduction (+ 1984-riot dependants); Class 10 | Notification month December |
| SSC CPO | Notice of SI in Delhi Police & CAPFs 2025, 26-Sep-2025 — <https://ssc.gov.in/api/attachment/uploads/masterData/NoticeBoards/Notice_of_adv_capf_2025.pdf> | 20-25 as on 01-08-2025; SC/ST +5, OBC +3, ESM 3 after deduction; SI Delhi Police: widows/divorced up to 35 (SC/ST 40); Delhi Police departmental candidates up to 30/33/35; bachelor's degree, final-year allowed; male and female | Added the widow relaxation; notification September, exam November |

## Banking, insurance, railways and AFCAT

| Exam | Notice (official URL) | Rules confirmed | Changed in seed |
|---|---|---|---|
| IBPS PO | CRP PO/MT-XVI, 30-Jun-2026 — <https://www.ibps.in/wp-content/uploads/Detailed-Notification_CRP-PO-XVI_Final_V1_30.06.2026.pdf> | Age 20-30 as on **01-07-2026** (born 2 Jul 1996 – 1 Jul 2006); SC/ST +5, OBC-NCL +3, PwBD +10, ex-servicemen / ECO / SSCO (5 yrs service) +5; graduation in any discipline held on the day of registration; no attempt limit | Cut-off changed from 1 Aug to 1 Jul; J&K relaxation removed |
| IBPS Clerk | CRP CSA-XVI — <https://www.ibps.in/wp-content/uploads/Notification_CRP_CSA_XVI-Final.pdf> | Age 20-28 as on 01-08-2026 (born 2 Aug 1998 – 1 Aug 2006); SC/ST +5, OBC +3, PwBD +10; ex-servicemen: service + 3 years, max 50; widows / divorced / judicially separated women not remarried: up to 35 (General/EWS), 38 (OBC), 40 (SC/ST); graduation | ESM cap 50 added; widow caps 35/38/40 (OBC 38); J&K relaxation removed |
| IBPS RRB PO / Clerk | CRP RRBs-XV (revised) — <https://www.ibps.in/wp-content/uploads/CRP-RRBs-XV-notification_Revised.pdf> | As on 01-09-2026: Office Assistant 18-28 (born 2 Sep 1998 – 1 Sep 2008); Officer Scale I above 18, below 30 (born 2 Sep 1996 – 1 Sep 2008); Scale II 21-32; Scale III 21-40; SC/ST +5, OBC +3, PwBD +10; ESM: Office Assistant service + 3 years (max 50), officers 5 years; widows (Office Assistant only) up to 35/38/40; Scale III needs 5 years officer experience | Office Assistant widow caps 35/38/40; officers' ESM 5 years; NOT_ATTAINED semantics |
| SBI PO | Advt. CRPD/PO/2026-27/09, 18-Jun-2026 — <https://sbi.bank.in/documents/77530/57941/18062026_1_Detailed_Adv.2026.pdf/1f1a9532-8a2f-6e59-08a0-616d62a497b1> | 21-30 as on 01-04-2026 (born 2 Apr 1996 – 1 Apr 2005); OBC +3, SC/ST +5, PwBD 10/13/15, ESM 5; **no cumulative relaxation**; graduation by 30-09-2026 (final year may apply); **number of chances: UR/EWS 6, UR-PwBD/EWS-PwBD/OBC/OBC-PwBD 9, SC/ST no restriction** | **Attempt limits changed from 4/7 to 6/9**; cut-off 1 April kept |
| SBI Clerk (Junior Associates) | JA 2026 detailed advertisement — <https://sbi.bank.in/webfiles/uploads/files_2627/08/JA_2026_Detailed_Advt_Eng.pdf> | 20-28 as on 01-04-2026 (born 2 Apr 1998 – 1 Apr 2006); OBC +3, SC/ST +5, PwBD 10/13/15; ESM service + 3 (max 50); widows +7 subject to 35/38/40; graduation (final year may apply provisionally) | Widow caps 35/38/40; ESM cap 50 |

**Not verified this time (official PDF could not be fetched automatically, or the new cycle is not yet notified) — these stay `LIKELY`:**
- **RBI Grade B** — the current RBI vacancies page no longer lists the 2026 Grade B notice, and the site blocks scripted downloads. Secondary sources agree: 21-30, General/EWS 6 attempts.
- **NABARD Grade A**, **LIC AAO** — the 2026-27 notices were not published by 25-Oct-2026 (LIC's last was the 32nd batch, Aug 2025).
- **RRB NTPC (CEN 06/2026 graduate, CEN 07/2026 under-graduate)** and **RRB Group D** — notices are on <https://rrb.indianrailways.gov.in>, but the site's firewall rejects scripted downloads. Secondary sources: graduate 18-33 and under-graduate 18-30 as on 01-01-2027.
- **AFCAT** — AFCAT 01/2027 is due in November 2026; the previous notice is no longer on afcat.cdac.in.

## Entrance tests

| Exam | Notice (official URL) | Rules confirmed | Changed in seed |
|---|---|---|---|
| JEE Main | NTA Information Bulletin JEE (Main) **2027**, 24-Oct-2026 — <https://cdnbbsr.s3waas.gov.in/s3f8e59f4b2fe7c5705bf878bbd494ccdf/uploads/2026/10/202610241890224107.pdf> | No age limit; Class 12 passed in 2025 or 2026 or appearing in 2027 (3 consecutive years); Session 1 January 2027, Session 2 April 2027 | — (seed already matched) |
| JEE Advanced | Information Brochure 2026 — <https://jeeadv.ac.in/documents/IBEnglish_2026.pdf> | Born on or after 1 Oct 2001 (SC/ST/PwD 1 Oct 1996); maximum two attempts in two consecutive years; Class 12 first appeared in 2025 or 2026; top 2,50,000 of JEE Main Paper 1 | — |
| NEET UG | NTA Information Bulletin NEET (UG) 2026 — <https://cdnbbsr.s3waas.gov.in/s37bc1ec1d9c3426357e69acd5bf320061/uploads/2026/02/202602231394640855.pdf> | At least 17 on 31-Dec-2026 (born on or before 31-12-2009); **no upper age limit** (NMC); Class 12 with Physics, Chemistry, Biology/Biotechnology and English (also as additional subjects); qualifying percentile 50 (40 SC/ST/OBC, 45 General-PwBD) | **Removed the Class-12 percentage condition** (the bulletin sets none for appearing) |
| GATE | GATE 2027 eligibility page, IIT Madras — <https://gate2027.iitm.ac.in/eligibility_criteria> | 3rd or higher year of any UG degree, or completed degree in Engg/Tech/Arch/Science/Commerce/Arts/Humanities; no age limit | Official URL updated to the 2027 organising institute |
| CAT | CAT 2026 eligibility, 26-Jul-2026 — <https://cdn.digialm.com/per/g06/pub/32842/EForms/image/CAT2026/CAT_2026_Eligibility_26-07-26.pdf> | Bachelor's with 50% (45% SC/ST/PwBD); final year allowed; or CA / CS / ICWA (CMA) / FIAI with the same percentage | Added the professional-degree alternative |
| CLAT UG | CLAT 2027 UG eligibility — <https://consortiumofnlus.ac.in/clat-2027/ug-eligibility.html> | No upper age limit; Class 12 with 45% (40% SC/ST/PwD); appearing in March/April 2027 allowed | PwD added to the 40% relaxation |
| CUET UG | NTA Information Bulletin CUET (UG) 2026 — <https://cdnbbsr.s3waas.gov.in/s3d1a21da7bca4abff8b0b61b87597de73/uploads/2026/01/202601031633478370.pdf> | No age limit; Class 12 passed or appearing in 2026 | — |
| IPMAT Indore | IIM Indore Admission Procedure IPM 2026-31 (domestic) — <https://iimidr.ac.in/wp-content/uploads/2026/01/AdmissionProcedure_IPM-2026-31_-Domestic-Applicants.pdf> | Born on or after 1 Aug 2006 (SC/ST/PwD 1 Aug 2001); Class 12 passed in 2024, 2025 or appearing in 2026; Class 10 passed | **Removed the 60% / 55% condition** (not in the 2026-31 procedure) |

## Teaching

| Exam | Notice (official URL) | Rules confirmed | Changed in seed |
|---|---|---|---|
| UGC NET | NTA Information Bulletin UGC-NET December 2026 — <https://cdnbbsr.s3waas.gov.in/s301eee509ee2f68dc6014898c309e86bf/uploads/2026/10/202610161905649093.pdf> | JRF: not more than 30 on the 1st day of the month in which the exam ends; up to 5 years relaxation (not cumulative) for OBC-NCL/SC/ST/PwD/third gender/women; Assistant Professor and PhD admission: no upper age; Master's 55% (50% reserved), final year allowed; 4-year UG with 75% for JRF/PhD | JRF cut-off changed to 1 December (December cycle) |
| CSIR NET | NTA Information Bulletin Joint CSIR-UGC NET December 2026 — <https://cdnbbsr.s3waas.gov.in/s3efdf562ce2fb0ad460fd8e9d33e57f57/uploads/2026/10/202610071407707951.pdf> | JRF not more than 30 as on 1 Dec 2026; total relaxation never more than 5 years; Assistant Professor no upper age; M.Sc or equivalent 55% (50% OBC-NCL/SC/ST/PwD/third gender) | JRF cut-off changed to 1 December |
| CTET | CTET September 2026 Information Bulletin — <https://cdnbbsr.s3waas.gov.in/s3443dec3062d0286986e21dc0631734c9/uploads/2026/05/202605111250310617.pdf> | Qualifications as notified by NCTE; 5% relaxation in qualifying marks for SC/ST/OBC/differently-abled; no age limit; Paper I (Classes I-V) and Paper II (VI-VIII) | Notification May, exam September |

**Also not verified this time (stay `LIKELY`):** **NEET PG** (natboard.edu.in blocks scripted access), **XAT 2027** (the bulletin PDF has no machine-readable eligibility text), **UPPSC PCS 2026**, **BPSC 72nd CCE** (secondary sources agree with the seed: 37 / 40 / 42 on 1-Aug-2026), **RPSC RAS**, **MPSC Rajyaseva** (official advertisements could not be fetched automatically).

## Summary

- **28 of the 40 flagship exams are VERIFIED** (UPSC 6, SSC 5, banking 6, entrance 8, teaching 3).
- **12 stay LIKELY**: RBI Grade B, NABARD Grade A, LIC AAO, RRB NTPC, RRB Group D, AFCAT, NEET PG, XAT, UPPSC PCS, BPSC CCE, RPSC RAS, MPSC Rajyaseva. They can be verified later from the admin "Check for updates" page (Phase 8), or by downloading the PDF by hand and updating the rules as a new version.
- Corrections that affect many exams (decisions D35-D38): the upper age limit is "not attained" (the official birth-date ranges show it); J&K 1980-89 relaxation removed from UPSC and bank exams; SSC caps for govt employees / widows no longer have a separate OBC value; bank clerical exams use 35/38/40 widow caps and an ESM maximum of 50.
