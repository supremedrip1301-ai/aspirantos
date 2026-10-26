<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.*, java.time.LocalDate, com.aspirantos.model.*, com.aspirantos.dao.*, com.aspirantos.engine.*, com.aspirantos.service.EligibilityService, com.aspirantos.util.HtmlUtil, com.aspirantos.util.DateUtil" %>
<%--
    Eligibility Horizon (signature visual): an SVG chart drawn on the server - one bar per tracked
    exam and per exam that is closing soon, from the first to the last year the student can sit it,
    coloured by status, with one dot per attempt left and a line for "today".
    Below it the age clock: the exact age now (ticking) and on each tracked exam's next cut-off date.
--%>
<%@ include file="/WEB-INF/jspf/auth-check.jspf" %>
<%@ include file="/WEB-INF/jspf/aspirant-only.jspf" %>
<%!
    // declaration: x position (in SVG units) of the start of a year on the chart
    private double x(double year, int fromYear, int toYear, double left, double width) {
        return left + (year - fromYear) * width / (toYear - fromYear + 1);
    }

    private String fill(String status) {
        switch (status) {
            case "ELIGIBLE": return "bar-eligible";
            case "PROVISIONAL": return "bar-provisional";
            case "NOT_YET": return "bar-not-yet";
            default: return "bar-closed";
        }
    }
%>
<%
    int userId = currentUser.getId();
    Profile myProfile = new ProfileDAO().getProfile(userId);
    if (myProfile == null) {
        session.setAttribute("error", "Fill in your profile first - the horizon is drawn from it.");
        response.sendRedirect("profile-step1.jsp");
        return;
    }
    EligibilityService eligibility = new EligibilityService();
    LocalDate today = eligibility.getToday();
    ExamDAO examDAO = new ExamDAO();
    List<Exam> allExams = examDAO.getAllExams();
    Map<Integer, Exam> byId = new HashMap<>();
    for (Exam x : allExams) {
        byId.put(x.getId(), x);
    }

    // rows: every tracked exam, then the open exams that close soonest (16 rows at most)
    Set<Integer> trackedIds = new LinkedHashSet<>();
    List<Exam> trackedExams = new ArrayList<>();
    for (Tracking t : new TrackingDAO().getTrackingByUser(userId)) {
        if (byId.containsKey(t.getExamId())) {
            trackedIds.add(t.getExamId());
            trackedExams.add(byId.get(t.getExamId()));
        }
    }
    Map<Integer, EligibilitySnapshot> snaps = new HashMap<>();
    for (EligibilitySnapshot s : eligibility.getSnapshots(userId, allExams)) {
        snaps.put(s.getExamId(), s);
    }
    List<EligibilitySnapshot> rows = new ArrayList<>();
    for (Integer id : trackedIds) {
        if (snaps.containsKey(id)) {
            rows.add(snaps.get(id));
        }
    }
    List<EligibilitySnapshot> closing = new ArrayList<>();
    for (EligibilitySnapshot s : snaps.values()) {
        if (!trackedIds.contains(s.getExamId()) && s.getLastEligibleYear() != null
                && ("ELIGIBLE".equals(s.getStatus()) || "PROVISIONAL".equals(s.getStatus()))) {
            closing.add(s);
        }
    }
    // closing soonest first (smaller last eligible year), then by name
    final Map<Integer, Exam> names = byId;
    Collections.sort(closing, new Comparator<EligibilitySnapshot>() {
        public int compare(EligibilitySnapshot a, EligibilitySnapshot b) {
            int byYear = Integer.compare(a.getLastEligibleYear(), b.getLastEligibleYear());
            return byYear != 0 ? byYear : names.get(a.getExamId()).getShortName().compareTo(names.get(b.getExamId()).getShortName());
        }
    });
    for (EligibilitySnapshot s : closing) {
        if (rows.size() >= 16) {
            break;
        }
        rows.add(s);
    }

    // year axis: this year up to the last year shown (at least 7 and at most 15 years)
    int fromYear = today.getYear();
    int toYear = fromYear + 6;
    for (EligibilitySnapshot s : rows) {
        if (s.getLastEligibleYear() != null && s.getLastEligibleYear() + 1 > toYear) {
            toYear = s.getLastEligibleYear() + 1;
        }
    }
    toYear = Math.min(toYear, fromYear + 14);
    double left = 150, width = 720, rowH = 34, top = 34;
    double height = top + rows.size() * rowH + 12;
    double todayX = x(fromYear + (today.getDayOfYear() - 1) / 365.0, fromYear, toYear, left, width);

    // age clock: full results of the tracked exams (they carry the next cut-off date)
    List<EligibilityResult> trackedResults = eligibility.getResults(userId, trackedExams);
    String pageTitle = "Eligibility horizon";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<h1>Eligibility horizon</h1>
<p class="muted">The years in which you can sit each exam, worked out for <span class="mono"><%= DateUtil.format(today) %></span>. Your tracked exams come first, then the open exams that close soonest.</p>
<%@ include file="/WEB-INF/jspf/flash.jspf" %>

<section class="card horizon-card">
<% if (rows.isEmpty()) { %>
    <p class="empty">Nothing to draw yet - track an exam in <a href="exams.jsp">Explore exams</a>.</p>
<% } else { %>
    <div class="horizon-scroll">
    <svg class="horizon-chart" viewBox="0 0 <%= (int) (left + width + 20) %> <%= (int) height %>" role="img"
         aria-label="Eligibility horizon: <%= rows.size() %> exams from <%= fromYear %> to <%= toYear %>">
        <%-- year grid --%>
        <% for (int y = fromYear; y <= toYear; y++) {
               double gx = x(y, fromYear, toYear, left, width); %>
        <line x1="<%= gx %>" y1="<%= top - 8 %>" x2="<%= gx %>" y2="<%= height - 6 %>" class="grid-line"/>
        <text x="<%= gx + 4 %>" y="<%= top - 14 %>" class="year-label"><%= y %></text>
        <% } %>
        <%-- one row per exam --%>
        <% for (int i = 0; i < rows.size(); i++) {
               EligibilitySnapshot s = rows.get(i);
               Exam exam = byId.get(s.getExamId());
               double y = top + i * rowH;
               boolean open = "ELIGIBLE".equals(s.getStatus()) || "PROVISIONAL".equals(s.getStatus()) || "NOT_YET".equals(s.getStatus());
               Integer first = s.getFirstEligibleYear() == null ? s.getNextCycleYear() : s.getFirstEligibleYear();
               boolean endless = s.getLastEligibleYear() == null;
               int last = endless ? toYear : Math.min(s.getLastEligibleYear(), toYear); %>
        <g class="h-row<%= trackedIds.contains(s.getExamId()) ? " tracked" : "" %>">
            <title><%= HtmlUtil.escape(exam.getShortName()) %>: <%= HtmlUtil.escape(s.getHeadline()) %></title>
            <a href="exam-detail.jsp?id=<%= exam.getId() %>#mine">
                <text x="8" y="<%= y + 21 %>" class="row-label"><%= HtmlUtil.escape(exam.getShortName().length() > 20 ? exam.getShortName().substring(0, 19) + "..." : exam.getShortName()) %></text>
            </a>
            <% if (open && first != null && first <= toYear) {
                   double bx = x(Math.max(first, fromYear), fromYear, toYear, left, width);
                   double bw = x(last + 1, fromYear, toYear, left, width) - bx - 2; %>
            <rect x="<%= bx %>" y="<%= y + 6 %>" width="<%= Math.max(bw, 6) %>" height="20" rx="6" class="h-bar <%= fill(s.getStatus()) %><%= endless ? " endless" : "" %>"/>
            <% if (s.getAttemptsRemaining() != null) {
                   int dots = Math.min(s.getAttemptsRemaining(), 9);
                   for (int d = 0; d < dots; d++) { %>
            <circle cx="<%= bx + 12 + d * 13 %>" cy="<%= y + 16 %>" r="4.5" class="h-dot"/>
            <%     }
                   if (s.getAttemptsRemaining() > 9) { %>
            <text x="<%= bx + 12 + 9 * 13 %>" y="<%= y + 20 %>" class="h-more">+<%= s.getAttemptsRemaining() - 9 %></text>
            <%     }
               } else if (!"NOT_YET".equals(s.getStatus())) { %>
            <text x="<%= bx + 10 %>" y="<%= y + 20 %>" class="h-inbar">unlimited attempts</text>
            <% } %>
            <% } else { %>
            <text x="<%= left + 6 %>" y="<%= y + 21 %>" class="h-closed"><%= "EXHAUSTED".equals(s.getStatus()) ? "attempts used up" : "not eligible" %></text>
            <% } %>
        </g>
        <% } %>
        <line x1="<%= todayX %>" y1="<%= top - 8 %>" x2="<%= todayX %>" y2="<%= height - 6 %>" class="today-line"/>
        <text x="<%= todayX + 3 %>" y="<%= height - 8 %>" class="today-label">today</text>
    </svg>
    </div>
    <p class="legend small"><span class="key bar-eligible"></span> eligible <span class="key bar-provisional"></span> provisional
        <span class="key bar-not-yet"></span> later <span class="key-dot"></span> one attempt left &middot; a faded end = no end year</p>
    <details>
        <summary>Show as a table</summary>
        <div class="table-wrap"><table>
            <thead><tr><th>Exam</th><th>Status</th><th>Years</th><th>Attempts left</th></tr></thead>
            <tbody>
            <% for (EligibilitySnapshot s : rows) { %>
            <tr><td><%= HtmlUtil.escape(byId.get(s.getExamId()).getShortName()) %></td><td><%= HtmlUtil.statusLabel(s.getStatus()) %></td>
                <td class="mono"><%= s.getFirstEligibleYear() == null ? "-" : s.getFirstEligibleYear() + " - " + (s.getLastEligibleYear() == null ? "no end" : String.valueOf(s.getLastEligibleYear())) %></td>
                <td><%= s.getAttemptsRemaining() == null ? "unlimited" : String.valueOf(s.getAttemptsRemaining()) %></td></tr>
            <% } %>
            </tbody>
        </table></div>
    </details>
<% } %>
</section>

<section class="card age-clock" id="age-clock" data-dob="<%= myProfile.getDob() %>" data-today="<%= today %>">
    <h2>Age clock</h2>
    <p class="clock-now"><span class="mono" id="clock-text"><%= AgeCalculator.describeAge(myProfile.getDob(), today) %></span></p>
    <p class="small muted" id="clock-birthday"></p>
    <% if (!trackedResults.isEmpty()) { %>
    <div class="table-wrap"><table>
        <thead><tr><th>Tracked exam</th><th>Age is counted on</th><th>Your age then</th><th>Upper age for you</th></tr></thead>
        <tbody>
        <% for (EligibilityResult r : trackedResults) {
               Exam exam = byId.get(r.getExamId()); %>
        <tr>
            <td><a href="exam-detail.jsp?id=<%= r.getExamId() %>#mine"><%= HtmlUtil.escape(exam.getShortName()) %></a></td>
            <td class="mono"><%= r.getNextCutoffDate() == null ? "-" : DateUtil.format(r.getNextCutoffDate()) %></td>
            <td class="mono"><%= r.getNextCutoffDate() == null ? (r.getDobWindow() != null ? HtmlUtil.escape(r.getDobWindow()) : "no age limit") : AgeCalculator.describeAge(myProfile.getDob(), r.getNextCutoffDate()) %></td>
            <td class="small"><%= HtmlUtil.escape(r.getRelaxationBreakdown()) %><%= r.getDaysUntilAgeLimitCrossed() != null && r.getDaysUntilAgeLimitCrossed() > 0 ? " Limit reached in " + r.getDaysUntilAgeLimitCrossed() + " days." : "" %></td>
        </tr>
        <% } %>
        </tbody>
    </table></div>
    <% } else { %>
    <p class="empty">Track exams to see your age on their cut-off dates.</p>
    <% } %>
</section>
<script src="<%= ctx %>/assets/js/horizon.js"></script>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
