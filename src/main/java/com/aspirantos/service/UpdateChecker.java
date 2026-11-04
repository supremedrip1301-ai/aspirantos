package com.aspirantos.service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.aspirantos.dao.SettingDAO;
import com.aspirantos.dao.UpdateCheckDAO;
import com.aspirantos.model.Exam;
import com.aspirantos.model.UpdateCheck;
import com.aspirantos.util.PasswordUtil;

/**
 * [EXTRA] "Check for updates" - not in the lab, needed for the
 * per-exam Update button. java.net.http.HttpClient downloads the exam's watch page (or the
 * official website), the HTML is turned into plain text, a SHA-256 fingerprint is compared
 * with the last check and short snippets around words such as "age limit" are kept for the
 * admin. Every result (also a failure) is stored in exam_update_check; nothing is ever
 * changed in the rules automatically - the admin decides and edits a new rule version.
 */
public class UpdateChecker {

    private static final String USER_AGENT =
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36";
    private static final int MAX_SNIPPETS = 12;
    private static final int SNIPPETS_PER_WORD = 2;

    private UpdateCheckDAO checkDAO = new UpdateCheckDAO();

    /** Checks one exam and stores the result. Never throws: problems end up in errorMessage. */
    public UpdateCheck check(Exam exam, Integer adminId) {
        UpdateCheck c = new UpdateCheck();
        c.setExamId(exam.getId());
        c.setCheckedBy(adminId);
        String url = exam.getWatchUrl() != null ? exam.getWatchUrl() : exam.getOfficialUrl();
        c.setUrlChecked(url == null ? "(no link)" : url);

        if (url == null || !url.matches("https?://\\S+")) {
            c.setErrorMessage("This exam has no official link to check.");
            checkDAO.insertCheck(c);
            return c;
        }
        int timeout = new SettingDAO().getInt("update_check_timeout_seconds", 15);
        try {
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(timeout))
                    .followRedirects(HttpClient.Redirect.NORMAL)
                    .version(HttpClient.Version.HTTP_1_1)
                    .build();
            HttpRequest request = HttpRequest.newBuilder(URI.create(url))
                    .timeout(Duration.ofSeconds(timeout))
                    .header("User-Agent", USER_AGENT)
                    .header("Accept", "text/html,application/xhtml+xml,*/*;q=0.8")
                    .GET()
                    .build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            c.setHttpStatus(response.statusCode());
            if (response.statusCode() >= 400) {
                c.setErrorMessage("The official site answered with HTTP " + response.statusCode() + ".");
            } else {
                String text = toText(response.body());
                c.setContentSha256(PasswordUtil.sha256Hex(text));
                UpdateCheck last = checkDAO.getLastSuccessfulCheck(exam.getId());
                c.setChangedSinceLast(last == null ? null : !last.getContentSha256().equals(c.getContentSha256()));
                c.setKeywordHits(snippets(text, keywords(exam)));
            }
        } catch (java.net.http.HttpTimeoutException e) {
            c.setErrorMessage("No answer within " + timeout + " seconds.");
        } catch (java.net.ConnectException | java.nio.channels.UnresolvedAddressException e) {
            c.setErrorMessage("Could not connect - the computer may be offline or the site is down.");
        } catch (Exception e) {
            String msg = e.getMessage() == null ? e.getClass().getSimpleName() : e.getMessage();
            c.setErrorMessage("Could not read the page: " + (msg.length() > 300 ? msg.substring(0, 300) : msg));
        }
        checkDAO.insertCheck(c);
        return c;
    }

    /** HTML -> plain text: drop scripts, styles and tags, decode common entities, squeeze spaces. */
    public static String toText(String html) {
        if (html == null) {
            return "";
        }
        String s = html.length() > 3_000_000 ? html.substring(0, 3_000_000) : html;
        s = s.replaceAll("(?is)<(script|style|noscript)[^>]*>.*?</\\1>", " ");
        s = s.replaceAll("(?s)<!--.*?-->", " ");
        s = s.replaceAll("<[^>]+>", " ");
        s = s.replace("&nbsp;", " ").replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">")
             .replace("&quot;", "\"").replace("&#39;", "'");
        return s.replaceAll("\\s+", " ").trim();
    }

    /** Words worth a look: eligibility words, this year and next year, the exam's short name. */
    public static List<String> keywords(Exam exam) {
        List<String> words = new ArrayList<>();
        words.add("age limit");
        words.add("attempt");
        words.add("eligibility");
        words.add("notification");
        words.add("relaxation");
        int year = LocalDate.now().getYear();
        words.add(String.valueOf(year));
        words.add(String.valueOf(year + 1));
        if (exam.getShortName() != null) {
            words.add(exam.getShortName().toLowerCase());
        }
        return words;
    }

    /** About 200 characters around each hit, "[word] ...snippet..." separated by blank lines. */
    public static String snippets(String text, List<String> words) {
        String lower = text.toLowerCase();
        StringBuilder sb = new StringBuilder();
        int total = 0;
        for (String w : words) {
            int from = 0;
            int found = 0;
            while (found < SNIPPETS_PER_WORD && total < MAX_SNIPPETS) {
                int i = lower.indexOf(w.toLowerCase(), from);
                if (i < 0) {
                    break;
                }
                int start = Math.max(0, i - 100);
                int end = Math.min(text.length(), i + w.length() + 100);
                sb.append("[").append(w).append("] ...").append(text, start, end).append("...\n\n");
                from = end;
                found++;
                total++;
            }
        }
        return sb.length() == 0 ? null : sb.toString().trim();
    }
}
