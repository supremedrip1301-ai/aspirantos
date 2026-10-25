# AspirantOS — DECISIONS LOG

Decisions already taken. Future sessions must follow these instead of re-deciding. Add new entries at the bottom with a date.

| # | Date | Decision | Reason |
|---|------|----------|--------|
| D1 | 2026-10-13 | JDK 21 LTS (Temurin), compile with `--release 21` | Tomcat 11 needs Java 17+; 21 is LTS and works with Eclipse and Hibernate 6.6 |
| D2 | 2026-10-13 | Apache Tomcat 11.0.x, `jakarta.*` packages (JSP only — see D16) | Matches the college lab worksheets (Tomcat 11, jakarta.servlet) |
| D3 | 2026-10-13 | MySQL 8.4 LTS + Workbench 8.0; DB `aspirantos`; app user `aspirant_app` / `Aspirant@123` | College notes use MySQL; root password stays out of the code |
| D4 | 2026-10-13 | ~~Hibernate ORM 6.6.x Final~~ **Superseded by D14** | Jakarta-based; still accepts the college HQL style (`createQuery(hql)` + `executeUpdate()`) |
| D5 | 2026-10-13 | ~~Maven `war` project in the Dynamic Web Project layout, imported into Eclipse as an existing Maven project; Maven Wrapper for CLI builds~~ **Superseded by D14** | Hibernate needs ~15 jars; Maven is built into Eclipse; layout identical to Worksheet 1 |
| D6 | 2026-10-13 | ~~JDBC for user-side data, Hibernate for exam master data and rules~~ **Superseded by D14** | Shows both syllabus technologies clearly |
| D7 | 2026-10-13 | ~~ODBC shown via Tech Stack page + Excel DSN demo, not used by the Java code~~ **Superseded by D14** | JDBC-ODBC bridge was removed in JDK 8 |
| D8 | 2026-10-13 | No CSS/JS frameworks, no CDN at runtime, fonts bundled locally | Works offline on demo day; looks original |
| D9 | 2026-10-13 | Exam rule updates = check official page (hash + keywords) + versioned manual edit + CSV rule pack | Auto-parsing hundreds of government PDFs is not reliable; this is honest and demoable |
| D10 | 2026-10-13 | ~~`app_setting.simulation_date` = 2027-01-15 in demo seed~~ **Superseded by D11** | — |
| D11 | 2026-10-15 | CHANGE 001: only the admin account is seeded; no demo students; simulation date empty by default | User's decision |
| D12 | 2026-10-15 | CHANGE 002: no Photo Studio, What-If, Recommender, Compare, Certificate Vault, Form-Fill Companion, public Tech Stack page or syllabus boxes; syllabus topics shown inside kept pages | User's decision |
| D13 | 2026-10-18 | Fresh rebuild on a new laptop; D11 and D12 applied from the start | Original folder lost |
| D14 | 2026-10-18 | CHANGE 003: JDBC is the only database technology; no Hibernate, no ODBC demo, no Maven; classic Dynamic Web Project with Connector/J + JSTL jars in WEB-INF/lib | User's choice — matches lab Experiment 4 |
| D15 | 2026-10-18 | CHANGE 004: all code follows the lab Experiment 4/5 patterns in COLLEGE_CODE_REFERENCE PART B; DBConnection uses constants like Experiment 4 | Easy to explain in the viva; looks like college code |
| D16 | 2026-10-21 | CHANGE 005: JSP only (JSP Model 1: view JSP + action JSP + DAO), no Servlet classes/filters/listeners; classic Dynamic Web Project, no Maven | Many pages/forms → JSP keeps HTML readable; JSP becomes a servlet internally; Exp 3–5 used JSP pages; Exp 4 used a Dynamic Web Project |
| D17 | 2026-10-25 | MySQL Connector/J **26.7.0** (`mysql-connector-j-26.7.0.jar`, copied from the user's own download in `D:\AIP\mysql-connector-j-26.7.0`, same jar as the StudentCRUD lab project) | Already on the laptop and used in the lab; Type 4 driver |
| D18 | 2026-10-25 | `tools/build.*` write only `build/cli/` and `build/AspirantOS.war`; `build/classes` is left to Eclipse | A Dynamic Web Project compiles into `build/classes`; the script must never delete it |
| D19 | 2026-10-25 | `about.jsp` lives in `WEB-INF/` and is reachable only through the `/about` `<jsp-file>` mapping | Then `config.getInitParameter(...)` always has its values (a direct `.jsp` URL would bypass the mapping and return null) |
| D20 | 2026-10-25 | One `error.jsp` (webapp root) handles 404, 500 and `java.lang.Throwable`; details only in the console | Simple, matches CHANGE 005; no stack traces for users |
