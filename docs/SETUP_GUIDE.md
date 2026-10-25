# AspirantOS — Setup Guide (Step by Step, Windows)

Ye guide aapke laptop (Windows 64-bit) ke liye hai. Sab kuch **ek baar** install karna hai, phir project hamesha `http://localhost:8080/AspirantOS/` pe chalega — internet ki zaroorat nahi.

**Kya install hoga (is order me):**

| # | Software | Version | Kis kaam ka |
|---|----------|---------|-------------|
| 1 | JDK (Eclipse Temurin) | 21 LTS | Java compile + run |
| 2 | MySQL Server | 8.4 LTS | Database |
| 3 | MySQL Workbench | 8.0.x (latest) | Database ko GUI se chalana, SQL scripts run karna |
| 4 | Apache Tomcat | 11.0.x (latest, zip) | Servlet/JSP server (web container) |
| 5 | Eclipse IDE for Enterprise Java and Web Developers | latest (2026-xx) | Code dekhna, Tomcat pe Run on Server |
| 6 | Git for Windows *(optional, recommended)* | latest | Har change ka backup (version control) |

> Tip: saare tools ek hi jagah rakho bina space wale path me, jaise `D:\AIP\` (project folder `D:\AIP\AspirantOS` ke **bahar**, uske andar nahi).

**Aapke laptop pe actual paths (Anshul ka setup):**

| Cheez | Path / Value |
|-------|--------------|
| JDK 21 (JAVA_HOME) | `C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot` |
| MySQL Server 8.4.11 | service `MySQL84`, bin: `C:\Program Files\MySQL\MySQL Server 8.4\bin` (PATH me hai) |
| MySQL Workbench | 26.7.0, connection `Local MySQL84` (root@localhost:3306) |
| Tomcat 11.0.27 (CATALINA_HOME) | `D:\AIP\apache-tomcat-11.0.27-windows-x64\apache-tomcat-11.0.27` |
| Eclipse | `D:\AIP\eclipse-jee-2026-09-R-win32-x86_64\eclipse` (Eclipse 2026-09, workspace: `D:\AIP\eclipse-workspace`) |
| Project | `D:\AIP\AspirantOS` |
| College files | `D:\AIP\aip` |

```
D:\AIP\
├── aip\                                   ← college notes + worksheets
├── AspirantOS\                            ← project folder
├── apache-tomcat-11.0.27-windows-x64\
│   └── apache-tomcat-11.0.27\             ← ASLI Tomcat folder (bin, conf, lib, webapps)
├── eclipse-jee-2026-09-R-win32-x86_64\
│   └── eclipse\                           ← Eclipse IDE (eclipse.exe yahan)
└── eclipse-workspace\                     ← Eclipse workspace
```

---

## STEP 1 — JDK 21 install karo

> **Agar pehle se koi aur JDK hai (jaise Oracle JDK 26):** Settings → Apps → Installed apps → "Java(TM) SE Development Kit 26" → Uninstall. Phir naya `cmd` kholo, `java -version` likho, aur "not recognized" aana chahiye. Uske baad neeche ke steps karo.
> Agar JDK 26 kisi aur kaam ke liye rakhna hai, to dono saath reh sakte hain. Bas STEP 1 ke baad PATH me `C:\Program Files\Common Files\Oracle\Java\javapath` wali line ko Temurin JDK 21 ki line se **neeche** move karo (Move Down), aur JAVA_HOME ko JDK 21 ke folder pe set karo.

1. Browser me kholo: **https://adoptium.net/temurin/releases/?version=21**
2. Operating System = **Windows**, Architecture = **x64**, Package = **JDK**, file type **.msi** → Download.
3. `.msi` file chalao → Next.
4. **Custom Setup** screen pe ye 3 options ko "Will be installed on local hard drive" pe set karo (bahut zaroori):
   - **Add to PATH**
   - **Set JAVA_HOME variable**
   - **JavaSoft (Oracle) registry keys**
5. Install → Finish.
6. **Check karo:** Start menu → `cmd` kholo (naya window) aur likho:
   ```
   java -version
   javac -version
   echo %JAVA_HOME%
   ```
   Teeno me **21** dikhna chahiye aur JAVA_HOME me path jaisa `C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot\` aana chahiye.
   Agar `java` not recognized aaye → laptop restart karo, phir check karo.

---

## STEP 2 — Visual C++ Redistributable (MySQL ke liye zaroori)

1. Download: **https://aka.ms/vs/17/release/vc_redist.x64.exe**
2. Chalao → Install (agar "already installed" bole to Close kar do).

---

## STEP 3 — MySQL Server 8.4 LTS install karo

1. Kholo: **https://dev.mysql.com/downloads/mysql/**
2. "Select Version" me **8.4.x LTS** chuno, OS = **Microsoft Windows** → **Windows (x86, 64-bit), MSI Installer** → Download.
3. Agle page pe "**No thanks, just start my download**" pe click karo (login ki zaroorat nahi).
4. MSI chalao → **Typical** ya **Complete** → Install.
5. Install ke baad **MySQL Configurator** khulega (na khule to Start menu me "MySQL Configurator" search karo):
   - **Data Directory:** default rehne do → Next.
   - **Type and Networking:** Config Type = **Development Computer**, TCP/IP ✔, **Port = 3306**, "Open Windows Firewall port" ✔ → Next.
   - **Accounts and Roles:** **root password** set karo (example: `Root@1234`). **Ye password kahin likh lo** — baad me Workbench aur database scripts ke liye chahiye hoga.
   - **Windows Service:** "Configure MySQL Server as a Windows Service" ✔, Service name **MySQL84**, "Start the MySQL Server at System Startup" ✔, Standard System Account → Next.
   - Sample databases → skip (optional) → **Execute** → sab steps green ✔ → Finish.
6. **MySQL ko PATH me add karo** (taaki Command Prompt me `mysql` command chal sake):
   - Start menu me search: **"Edit the system environment variables"** → **Environment Variables…**
   - Neeche **System variables** me **Path** select → **Edit** → **New** → paste:
     `C:\Program Files\MySQL\MySQL Server 8.4\bin`
   - OK → OK → OK.
7. **Check karo:** naya `cmd` kholo:
   ```
   mysql --version
   mysql -u root -p
   ```
   Password daalo → `mysql>` prompt aana chahiye. `exit` likh ke bahar aa jao.

---

## STEP 4 — MySQL Workbench install karo

1. Kholo: **https://dev.mysql.com/downloads/workbench/** → Windows (x86, 64-bit) MSI → Download → "No thanks, just start my download".
2. Install → Complete → Finish.
3. Workbench kholo → Home screen pe **"Local instance MySQL84"** (ya `+` dabake naya connection: Hostname `127.0.0.1`, Port `3306`, Username `root`) → click → root password daalo → "Save password in vault" ✔.
4. Agar warning aaye *"Connection warning: incompatible/nonstandard server version"* → **Continue Anyway** dabao. Workbench 8.0 MySQL 8.4 ke saath sahi chalta hai, ye sirf warning hai.

> **Naya Workbench 26.x (2026):** Download page ab "MySQL Workbench 26.x" deta hai. Iska look naya hai aur ye MySQL 8.4 ko fully support karta hai. Isme connection apne aap nahi banta: **Database Connections** ke saamne **`+`** dabao, phir ye bharo:
> - Caption: `Local MySQL84`
> - Host: `127.0.0.1`
> - Port: `3306`
> - User: `root`
>
> Password "Store/Save password" ke saath daalo → OK, phir connection card pe click karke kholo.
> Scripts chalane ke liye SQL editor me `.sql` file kholke Execute karo. **Sabse aasaan tarika:** MySQL ka `bin` PATH me hai, isliye `RUN_ALL.sql` ek hi `mysql` command se saare scripts chala deta hai (STEP 9 tab sirf backup tarika hai).

---

## STEP 5 — Apache Tomcat 11 (zip) install karo

1. Kholo: **https://tomcat.apache.org/download-11.cgi**
2. "Binary Distributions" → **Core** → **64-bit Windows zip** download karo. (Installer `.exe` / service wala version **mat** lo — Eclipse khud Tomcat start/stop karega.)
3. Zip ko `D:\AIP\` me extract karo. Aapke laptop pe Tomcat 11.0.27 yahan hai: `D:\AIP\apache-tomcat-11.0.27-windows-x64\apache-tomcat-11.0.27` (isi folder ke andar `bin`, `conf`, `lib`, `webapps` hain — yahi Tomcat ka asli folder hai).
4. *(Recommended)* `CATALINA_HOME` variable banao (command-line build aur testing ke liye):
   - "Edit the system environment variables" → Environment Variables → System variables → **New**
   - Variable name: `CATALINA_HOME`, Variable value: `D:\AIP\apache-tomcat-11.0.27-windows-x64\apache-tomcat-11.0.27` → OK.
5. **Test (optional):** `cmd` me:
   ```
   cd /d D:\AIP\apache-tomcat-11.0.27-windows-x64\apache-tomcat-11.0.27\bin
   startup.bat
   ```
   Browser me `http://localhost:8080` → Tomcat ka page dikhega. Phir **band karo**: `shutdown.bat`.
   *(Ye zaroori hai — agar ye Tomcat chalta reh gaya to Eclipse wala Tomcat port 8080 pe start nahi hoga.)*

---

## STEP 6 — Eclipse IDE install aur setup

### 6.1 Install
1. Kholo: **https://www.eclipse.org/downloads/packages/**
2. **"Eclipse IDE for Enterprise Java and Web Developers"** → Windows x86_64 → zip download karo.
3. Zip ko `D:\AIP\` me extract karo → `D:\AIP\eclipse-jee-2026-09-R-win32-x86_64\eclipse\eclipse.exe` chalao.
4. Workspace puchega → `D:\AIP\eclipse-workspace` likho → Launch.
   *(Note: project folder `D:\AIP\AspirantOS` workspace ke bahar rahega — ye bilkul theek hai, Eclipse use import karega.)*

### 6.2 JDK 21 ko Eclipse me jodo
1. **Window → Preferences → Java → Installed JREs → Add… → Standard VM → Next**
2. **JRE home** → Directory… → `C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot` → Finish.
3. List me **jdk-21** ke aage tick ✔ karo (default) → Apply.
4. **Java → Compiler** → Compiler compliance level = **21** → Apply.

### 6.3 Encoding UTF-8 (Hindi/₹ jaise characters sahi dikhne ke liye)
1. **General → Workspace** → Text file encoding = **Other: UTF-8** → Apply.
2. **Web → JSP Files** → Encoding = **ISO 10646/Unicode (UTF-8)** → Apply.
3. **Web → HTML Files** aur **Web → CSS Files** me bhi UTF-8 → **Apply and Close**.

### 6.4 Tomcat 11 ko Eclipse me add karo
1. **Window → Preferences → Server → Runtime Environments → Add…**
2. **Apache → Apache Tomcat v11.0** → Next.
3. Tomcat installation directory → Browse → `D:\AIP\apache-tomcat-11.0.27-windows-x64\apache-tomcat-11.0.27`
4. JRE → **jdk-21** select karo → Finish → Apply and Close.
5. **Window → Show View → Other… → Server → Servers** → Open.
6. Servers tab me link "No servers are available. Click this link to create a new server…" → **Tomcat v11.0 Server** → Next → Finish.
7. Servers tab me **"Tomcat v11.0 Server at localhost"** pe double-click → right side **Timeouts → Start = 120** → Ctrl+S.

---

## STEP 7 — Git (optional but recommended)

1. **https://git-scm.com/download/win** → 64-bit installer → sab default → Install.
2. Check: `git --version`.
   *(Git se har change ka backup rehta hai — koi file kharab hui to purana version wapas mil jayega.)*

---

## STEP 8 — Project ka code laana

1. Project folder `D:\AIP\AspirantOS` me hona chahiye. Naye computer pe GitHub se le lo:
   `git clone https://github.com/supremedrip1301-ai/aspirantos.git D:\AIP\AspirantOS`
2. Folder me ye cheezein honi chahiye: `src\`, `sql\`, `docs\`, `tools\`, `.project`, `.classpath`, `.settings\`, `README.md`.
3. Database scripts chalao (STEP 9), phir Eclipse me import karo (STEP 10).

---

## STEP 9 — Database scripts chalana

`sql\` folder me numbered scripts hain (`00_…`, `01_…`, `02_…` …).

> Sabse aasaan: Command Prompt me `cd D:\AIP\AspirantOS\sql` phir `mysql -u root -p --default-character-set=utf8mb4 < RUN_ALL.sql` (root password maangega). Ye saari files sahi order me chala deta hai. Workbench se karna ho to neeche wale steps.
> Scripts **root** se hi chalao — MySQL functions aur triggers sirf root (SUPER) bana sakta hai. Website khud `aspirant_app` user se connect karti hai.

1. Workbench → **Local instance MySQL84** (root) kholo.
2. **File → Open SQL Script…** → `D:\AIP\AspirantOS\sql\00_create_database_and_user.sql` → **⚡ (Execute)** button.
3. Isi tarah **number ke order me** har file kholo aur ⚡ dabao: `01_schema` → `02_views` → `03_functions_procedures` → `04_triggers` → `05_seed_helpers` → `10_seed_master` → `11_…` se `24_…` → `29_verified_sources` → `30_…` → `31_…` → `40_seed_admin`. (Aakhir me `98_integrity_checks` chala ke dekh lo — saari PROBLEM lines 0 honi chahiye. `99_reset_all` aur `reset_after_demo` normal order me **nahi** chalane.)
4. Left side **Schemas** panel me refresh (🔄) → `aspirantos` database me tables dikhenge.
5. Koi error aaye (red ✖ Output panel me) → us error ka text dhyan se padho (zyada tar script ka order galat hota hai) aur wahi script dobara chalao.

---

## STEP 10 — Eclipse me project laana (Import)

Is project me database ke liye **sirf JDBC** aur pages ke liye **sirf JSP** use hoga (koi Servlet class nahi, Hibernate/ODBC/Maven nahi). Ye bilkul lab Experiment 4 (StudentCRUD) jaisa normal **Dynamic Web Project** hai.

Project ki Eclipse files (`.project`, `.classpath`, `.settings\`) **pehle se bani hui hain** — StudentCRUD jaisi hi (Tomcat v11.0, Java 21, Dynamic web module 6.1). Connector/J jar bhi `WEB-INF\lib` me pehle se hai. Aapko sirf import karna hai:

1. Eclipse kholo (workspace `D:\AIP\eclipse-workspace`).
2. **File → Import… → General → Existing Projects into Workspace → Next**
3. **Select root directory:** `D:\AIP\AspirantOS` → list me **AspirantOS** ✔ dikhega.
4. **"Copy projects into workspace" ka tick mat lagao** (project apni jagah `D:\AIP\AspirantOS` me hi rahega) → **Finish**.
5. Project Explorer me **AspirantOS** aa jayega. Koi red ✖ dikhe to project pe right-click → **Refresh (F5)**.

> Agar Eclipse bole *"Target runtime Apache Tomcat v11.0 is not defined"*: project pe right-click → **Properties → Targeted Runtimes** → **Apache Tomcat v11.0** ✔ → Apply. (StudentCRUD me ye runtime pehle se bana hua hai, isliye normally ye error nahi aata.)

## STEP 11 — Run karna

1. Jab bhi project ki files badlein: Eclipse me project pe click → **F5 (Refresh)**.
2. Project pe right-click → **Run As → Run on Server** → Tomcat v11.0 → Finish.
3. Browser me kholo: **http://localhost:8080/AspirantOS/**
4. Login:
   - **Admin (sirf yahi ek account pehle se bana hai):** `admin@aspirantos.in` / `Admin@123`. Isme website ki saari powers hain (exams, rules, update, users, settings). Pehli baar login karke Settings se password badal lena.
   - **Students:** koi dummy account nahi hai. **Register** page se naya student account banao, profile wizard bharo, phir dashboard pe eligibility dikhegi.

> Code badalne ke baad: Servers tab → server pe right-click → **Restart**, aur browser me **Ctrl+F5**.

---

## Common Problems & Solutions

| Problem | Solution |
|---------|----------|
| `'java' is not recognized` | JDK install me "Add to PATH" tick nahi tha → JDK reinstall karo ya PATH me `...\jdk-21...\bin` add karo; restart. |
| Eclipse: *Port 8080 required by Tomcat is already in use* | Koi aur Tomcat chal raha hai → `D:\AIP\apache-tomcat-11.0.27-windows-x64\apache-tomcat-11.0.27\bin\shutdown.bat` chalao, ya Servers tab → server double-click → Ports me HTTP/1.1 ko `8081` kar do. |
| *Server Tomcat v11.0 failed to start in 45 seconds* | Server double-click → Timeouts → Start = 120. |
| `ClassNotFoundException: com.mysql.cj.jdbc.Driver` | `src/main/webapp/WEB-INF/lib` me `mysql-connector-j-….jar` hona chahiye → project F5 Refresh → server pe right-click → Clean… → Restart. |
| `Access denied for user 'aspirant_app'@'localhost'` | `00_create_database_and_user.sql` root se dobara chalao. |
| `Public Key Retrieval is not allowed` | DB URL me `allowPublicKeyRetrieval=true&useSSL=false` hona chahiye (`src/main/java/com/aspirantos/util/DBConnection.java`). |
| `Communications link failure` | MySQL service band hai → Start → `services.msc` → **MySQL84** → Start. |
| `Unsupported class file major version` | Eclipse/Tomcat JDK 21 pe nahi chal rahe → STEP 6.2 & 6.4 me JRE = jdk-21 check karo. |
| `jakarta.servlet cannot be resolved` | Project → Properties → **Targeted Runtimes** → Apache Tomcat v11.0 ✔ → Apply and Close. |
| Page 404 on `localhost:8080/AspirantOS/` | Server pe project add hua hai? Servers tab me server expand karo — AspirantOS dikhna chahiye. Nahi to right-click → Add and Remove… |
| Hindi/₹ ulta-pulta dikhe | STEP 6.3 encoding UTF-8 set karo. |
| Workbench: *incompatible server version* | Continue Anyway — normal hai. |

---

## Demo day se pehle checklist

- [ ] `services.msc` me **MySQL84** Running hai.
- [ ] Eclipse me server Start hai, `http://localhost:8080/AspirantOS/` khulta hai.
- [ ] Admin → Settings me **simulation date = 15-Jan-2027** set hai (optional — taaki demo line "2 UPSC attempts left, valid until 2028" hi aaye).
- [ ] Ek student **Register** karke check kiya, ye details daal ke: General, DOB 15-09-1996, B.A. 2018 (62 %), Uttar Pradesh, UPSC CSE me 4 attempts used → dashboard pe **"You have 2 UPSC attempts left, valid until 2028."** (Baaki sample details `docs\DEMO_SCRIPT.md` me.)
- [ ] `docs\DEMO_SCRIPT.md` aur `docs\VIVA_GUIDE.md` ek baar padh liya.
- [ ] Rehearsal ke baad sab pehle jaisa kiya: rehearsal waale student se login → Settings → **Delete my account**, phir Workbench me root se `sqleset_after_demo.sql` chalaya (UPSC rules wapas version 1, simulation date off). Demo se pehle simulation date dobara set karna.
- [ ] Laptop charger + internet off hone pe bhi sab chalta hai (fonts local hain).
