# AspirantOS — DEMO SCRIPT (7 minutes)

This script works **without any ready-made student account**: the student is registered live. Every click and every expected result below was rehearsed with `tools/smoke-demo.sh` (20/20 checks, 26-Oct-2026).

## Before the presentation (10 minutes earlier)

1. `services.msc` → **MySQL84** is *Running*.
2. In Eclipse: **Servers** → start Tomcat v11.0. Open `http://localhost:8080/AspirantOS/`.
3. **Two browser windows:**
   - **Normal window** for the student.
   - **Private / incognito window** for the admin. The two windows keep separate logins, so you can switch between them without logging out.
4. **Set the simulation date** in the admin window:
   1. Log in as `admin@aspirantos.in`.
   2. Open **Settings** in the sidebar and click **Presentation date (15-Jan-2027)**.
   3. A yellow banner "Simulation date: 15-Jan-2027" now appears on every page, and the results are exactly the ones in this script.
5. In the admin window, open **Exams** → search `UPSC` → **Rules** of *UPSC CSE*, and leave this tab open.
6. Zoom the browser to 110–125 % so the room can read it. Light theme reads better on a projector.
7. The **update check** in step 6 needs internet. Without internet, skip it and show the "Update checks" table instead.

> **After a rehearsal,** put everything back:
> 1. In the rehearsal student's window: name (top right) → **My settings** → **Delete my account**.
> 2. In Workbench, run `sql/reset_after_demo.sql` as root. UPSC CSE goes back to rules version 1 and the simulation date is switched off.
> 3. Set the presentation date again before the real demo.

---

## The script

### 1. The problem — 0:00 to 0:30

> "Meet Aarav, 30, from Prayagraj. He has written UPSC Prelims four times. He is also looking at SSC CGL, bank PO and his state PSC. Every exam has a different age limit, a different cut-off date, different relaxations and a different attempt limit, and these change every year. Aarav honestly does not know how many chances he has left. **AspirantOS answers that in one line, for 267 exams.**"

Show the **landing page** (`/AspirantOS/`). If there is time, fill **"Try it now: UPSC Civil Services"**:
1. DOB `15-09-1996`, General, 4 attempts → **Check my UPSC chances**.
2. The answer appears without reloading the page: *"You have 2 UPSC attempts left, valid until 2028."*
3. Say: "This is the real engine, answering in JSON."

### 2. Register live — 0:30 to 2:30

Click **Create account** and type:

| Field | Value |
|---|---|
| Full name | Aarav Mishra |
| E-mail | aarav.demo@test.local (any new address) |
| Password / confirm | something with 8+ characters, a letter and a number (the strength bar moves) |

The **profile wizard** opens:

| Step | Type this |
|---|---|
| 1. Personal details | Full name Aarav Mishra · Date of birth **15-09-1996** · Male · Unmarried · Indian · Domicile **Uttar Pradesh** (city Prayagraj, optional) |
| 2. Category | **General** (point at the hint: OBC creamy layer counts as General) |
| 3. Education | Add education → Level **Graduation** · Degree **B.A.** · Percentage **62** · Status *Completed* · Passing year **2018** → *Save* → *Next* |
| 4. Attempts already used | Next to **UPSC CSE** type **4** → look at the review → **Save my profile** |

> Say: "The wizard keeps the values in a session JavaBean (`jsp:useBean`, scope session). Only step 4 writes to MySQL, with a PreparedStatement."

### 3. The dashboard — 2:30 to 3:15

The toast says *"Profile created (1 row affected)."* Point at:
- **The counters** counting up (eligible now / provisional / closing within a year / not eligible), worked out for all 267 exams.
- **The UPSC CSE attempt ticket:** the **ELIGIBLE** stamp, **"2 attempts left"**, **valid until 2028**, and 6 dots (4 used, 2 left).
- The alert strip and the upcoming dates.

> "This is the sentence we promised: *You have 2 UPSC attempts left, valid until 2028.*"

### 4. Why? The explanation — 3:15 to 4:00

Click **Why?** on the ticket. The UPSC page opens on **My eligibility**:
- Read two lines of the check table:
  - **Age:** *30 years … on 01-Aug-2027 … below 32*.
  - **Attempts:** 4 attempts used, 2 left (also in the facts: *used 4 · left 2*).
- Show the **year strip**: 2027 and 2028 are green.
- Show "Age limit for you: Base upper age 32 …".
- Optionally click **Print report** to show the print preview of the eligibility report, then cancel.
- Optionally open **Horizon** in the sidebar: the bars and the ticking age clock.

### 5. The admin changes a rule — 4:00 to 5:30

Switch to the **admin window** (the UPSC CSE rules tab from the preparation).

1. **Check for updates** (needs internet). The app downloads upsc.gov.in, compares it with the last check and highlights lines with keywords. Say: "The admin decides; nothing changes on its own."
2. Click **Update rules (copy the active version into a draft)**. Draft v2 appears. Say: "That was a stored procedure with an OUT parameter, called through CallableStatement."
3. In **Attempt rules**, click **Edit** on *General: 6 attempts*. Change **Max attempts** to **7** and the notes to *General: 7 attempts* → **Save attempt rule**.
4. The **diff** shows ~~6 attempts~~ → **7 attempts**.
5. **What changed?** type *General candidates now get 7 attempts* · From cycle **2027** → **Save draft details**.
6. Click **Publish v2** and confirm. The message says **"Version 2 of UPSC CSE is now active … 1 student was notified."**

### 6. The student sees it — 5:30 to 6:00

Switch to the **student window** and refresh (F5):
- The **bell** shows 1. Open it to see *"UPSC CSE rules updated"*.
- The **Dashboard** ticket now says **3 attempts left** and still *valid until 2028*.

> "A trigger cleared the cached result, the engine recalculated it with version 2, and the history tab of the exam keeps both versions."

### 7. Map it to the syllabus — 6:00 to 6:45

In the admin window:
- **Dashboard → System information:** driver name and version from `DatabaseMetaData` (MySQL Connector/J, a Type 4 driver).
- **DB Explorer** (sidebar, Tools): choose `exam_rule_version`:
  - **First / Previous / Next / Last** move a **scrollable ResultSet**;
  - the column list comes from **ResultSetMetaData**;
  - in the `app_setting` table, editing a value writes it back through an **updatable ResultSet**.
- Open **How it works** (account menu, or `/about`):
  - the 3-tier diagram and the request flow;
  - the **ER diagram**;
  - say that this page is mapped in web.xml with `<jsp-file>` and reads its own `<init-param>`s with `config`.

### 8. Closing — 6:45 to 7:00

> "AspirantOS turns pages of notifications into one honest sentence for every aspirant: how many chances are left, and until when. It is built only with what we learned: JSP, JDBC and MySQL, used properly with versioned rules, procedures, triggers, transactions and a tested engine. Thank you."

---

## More sample students (if the examiners want to try)

Register them the same way. The results below are for the simulation date **15-Jan-2027** (worked out by the app on 26-Oct-2026).

| Sample | Type in the wizard | What it shows |
|---|---|---|
| **OBC-NCL + PwBD** | Neha Verma · DOB 01-03-1990 · Female · Married · Madhya Pradesh · OBC-NCL · PwBD *Locomotor* 60 % · B.Tech 2012 (71 %) | Counters 137 / 0 / 8 / 115. **UPSC CSE: Eligible, "You have 9 UPSC attempts left, valid until 2034."** Age limit "Base upper age 32 + OBC-NCL 3 + PwBD 10 = 45". SSC CGL and IBPS PO: unlimited attempts within age, until 2032 (30 + 3 + 10 = 43). |
| **SC** | Rahul Kumar · DOB 20-06-1993 · Male · Bihar · SC · B.Sc 2015 (58 %) | Counters 125 / 0 / 24 / 128. **UPSC CSE: Eligible, unlimited attempts within age, until 2029** (32 + SC 5 = 37). SSC CGL until 2027 (30 + 5 = 35), SBI PO until 2028. |
| **Class-12 PCB student** | Ishita Rao · DOB 10-05-2008 · Female · Karnataka · General · Class 12, status *Appearing*, expected result 31-05-2027, subjects Physics, Chemistry, Biology, English | Counters 12 / 63 / 8 / 22. **NEET UG: Provisional, "you must pass by 31-May-2027"**. **JEE Main: Not eligible — MATHS is required in your Class 12.** UPSC CSE: Not yet, eligible from 2030 after graduation. |
| **EWS ex-serviceman** | Vikram Singh · DOB 02-11-1984 · Male · Married · Haryana · EWS · Ex-serviceman, 15 years of service, released 30-06-2022 · B.A. 2006 (55 %) | Counters 93 / 0 / 5 / 162. **SSC CGL: Eligible until 2032** — "Base upper age 30 + Ex-serviceman 3 = 33 (compared with your age after deducting 15 years of military service)". IBPS PO and UPSC CSE: Not eligible, age limit crossed. |

Counters are in the order *eligible now / provisional / closing within a year / not eligible*.

---

## If something goes wrong

| Problem | What to do |
|---|---|
| The ticket shows a different number | The simulation date is not set: admin → Settings → **Presentation date (15-Jan-2027)**. Or the rules were changed in a rehearsal: run `sql/reset_after_demo.sql`. |
| "This e-mail is already registered" | Use another address (aarav2@test.local) or delete the old rehearsal account from its Settings page. |
| Check for updates says it could not connect | There is no internet. Say "it needs the official site", and show the table of earlier checks. |
| A page shows the error card | Admin login shows the technical details. Usually MySQL has stopped: `services.msc` → MySQL84 → Start. |
| The admin and student windows log each other out | They share cookies. Use a private window for the admin. |
