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
