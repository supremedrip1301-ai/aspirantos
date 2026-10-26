# AspirantOS — Rule pack format (CSV)

A **rule pack** is a plain CSV file with the eligibility rules of one or many exams. You can use it to:

- **Back up** the rules. Use **Admin → Rule pack → Export**.
- **Change many rules at once.** Open the exported file in Excel or LibreOffice, edit it, and import it again.
- **Load updated rules from someone else.** A classmate can prepare the file for you.

**What import does:** for every exam that appears in the file, **its rows become the complete new rule version**. That version is published at once, the old version is archived, and students who track the exam get a notification. All exams in one file are applied in **one database transaction**, so either everything is applied or nothing is.

A ready-made example is `sql/sample_rule_pack.csv`. It contains the current UPSC CSE and CAT rules.

## File rules

- The first line that is not a comment is the **header**. Column names are not case-sensitive. Only `exam_code` and `rule_table` are required; missing columns count as empty.
- **One line = one rule row.** Leave the columns of other rule tables empty.
- Lines starting with `#` and empty lines are ignored.
- **Quoting:** a value that contains a comma or a quote goes inside double quotes, and a quote inside quotes is written twice (`"say ""yes"""`). Values cannot contain line breaks.
- **Yes/no columns** accept `1`/`0`, `TRUE`/`FALSE`, `YES`/`NO` or `Y`.
- The file may be saved by Excel with a byte order mark. It is removed automatically.
- **Limits:** at most 5000 rows and 1 MB per import.

## Common columns

| Column | Meaning |
|---|---|
| `exam_code` | Code of an existing exam, for example `UPSC_CSE`. |
| `rule_table` | `AGE`, `RELAXATION`, `ATTEMPT`, `QUALIFICATION` or `OTHER`. |
| `post_or_course` | Post group the row belongs to. Empty means the whole exam (AGE, QUALIFICATION, OTHER). |
| `notes` | Notes for AGE / RELAXATION / ATTEMPT rows. For QUALIFICATION and OTHER rows it is the summary text shown to students. |

## AGE

| Column | Values |
|---|---|
| `cutoff_type` | `FIXED_DATE_IN_CYCLE_YEAR`, `FIXED_DATE_IN_PREVIOUS_YEAR`, `FIXED_DATE_IN_NEXT_YEAR`, `DOB_WINDOW` or `NONE` |
| `min_age`, `max_age` | Whole years, 0–80. Empty means no limit. |
| `max_age_semantics` | `NOT_ATTAINED` (the upper age must not have been reached; the usual official wording) or `NOT_MORE_THAN` (the upper age itself is allowed) |
| `cutoff_month`, `cutoff_day` | Needed for the three `FIXED_DATE…` types, for example 8 and 1 for 1 August |
| `dob_from_offset_years`, `dob_from_month`, `dob_from_day` | `DOB_WINDOW` only: "born on or after", counted in years from the exam year (for example -25, 10, 1) |
| `dob_to_offset_years`, `dob_to_month`, `dob_to_day` | `DOB_WINDOW` only, optional: "born on or before" |

## RELAXATION

| Column | Values |
|---|---|
| `relaxation_type` | `CATEGORY`, `PWBD`, `EX_SERVICEMAN`, `JK_DOMICILE_1980_89`, `GOVT_EMPLOYEE`, `WOMEN`, `WIDOW_DIVORCED_WOMEN`, `TRANSGENDER` or `STATE_DOMICILE` |
| `category` | `GEN`, `EWS`, `OBC_NCL`, `SC` or `ST`. Required for `CATEGORY`; optional for the other types. |
| `years` | 0–40 |
| `stacking` | `ADD` (the years add up), `ADD_AFTER_SERVICE_DEDUCTION` (ex-servicemen: military service is deducted from the age) or `REPLACE_WITH_MAX` (only the largest "up to N years" counts; together with a cap, the upper age is raised to the cap) |
| `overall_max_age_cap` | 18–70, optional |
| `requires_state_domicile` | 1 = only for the state's own domicile candidates |

## ATTEMPT

| Column | Values |
|---|---|
| `category`, `is_pwbd` | Who the row is for. Empty means everybody. `is_pwbd` 1 = PwBD only, 0 = not PwBD. |
| `max_attempts` | 1–50. Empty means unlimited (within the age limit). |
| `counting_rule` | `APPEARED_IN_FIRST_STAGE`, `APPLIED`, `PER_SITTING`, `CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM`, `PER_ROLLING_12_MONTHS` or `LIFETIME_TOTAL` |
| `window_years` | Needed for `CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM` (JEE: years after Class 12) |
| `min_gap_days` | Days between two tests (rolling 12-month rules) |

## QUALIFICATION

| Column | Values |
|---|---|
| `required_level` | `NONE`, `CLASS_10`, `CLASS_12`, `DIPLOMA`, `UG`, `PG`, `PHD` or `PROFESSIONAL` |
| `accepted_degrees` | Comma list, for example `"B.E.,B.Tech"`. Empty or `ANY` means any degree. |
| `required_subjects` | `,` means all are needed, `\|` means any one is enough. A prefix such as `CLASS_12:` checks the Class 12 row. Example: `"PHYSICS,CHEMISTRY,BIOLOGY\|BIOTECHNOLOGY,ENGLISH"` |
| `min_percent_general`, `min_percent_relaxed` | 0–100. The relaxed value cannot be higher than the general one. |
| `relaxed_for` | Who gets the relaxed percentage, for example `SC,ST,OBC_NCL,PWBD` |
| `final_year_allowed` | 1 = final-year students may apply |
| `max_years_since_passing` | Optional, 0–20 |
| `min_experience_years` | Optional, 0–40 |

## OTHER

| Column | Values |
|---|---|
| `rule_type` | `NATIONALITY`, `GENDER`, `MARITAL_STATUS`, `DOMICILE`, `PHYSICAL_STANDARD`, `REGISTRATION` or `OTHER` |
| `rule_value` | Codes separated by commas, for example `UNMARRIED`, `MALE,FEMALE`, `UP` or `NO_PWBD`. Required for the first four types. |
| `is_blocking` | 1 = not meeting the condition makes the student not eligible; 0 = information only |

## Import steps

1. **Admin → Rule pack → Import.** Pick the `.csv` file or paste its text, and write what changed.
2. **Check the pack.** Every line is validated with the same rules as the rule editor. Problems are listed with their line number, and nothing is saved while there is any problem.
3. **Read the preview.** For each exam it shows the old rows (struck through) and the new rows (highlighted).
4. **Apply.** One new active version is created per exam, the students who track those exams are notified, and their results are recalculated.

**Exams with an open draft** must be published or discarded first, so that no edits are lost.

The round trip has been tested: exporting all 267 exams and importing the file again gives 1990 rows with 0 problems and 0 differences.
