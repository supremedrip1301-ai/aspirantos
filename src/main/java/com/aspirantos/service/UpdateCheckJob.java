package com.aspirantos.service;

import java.time.LocalDateTime;
import java.util.List;

import com.aspirantos.dao.ExamDAO;
import com.aspirantos.model.Exam;
import com.aspirantos.model.UpdateCheck;

/**
 * [EXTRA] "Check all exams" runs in one background Thread started from update-check-action.jsp
 * (CHANGE 005: no listener, no scheduler). The admin page polls update-check-progress.jsp,
 * which reads the static progress fields below. Only one job can run at a time.
 */
public class UpdateCheckJob implements Runnable {

    private static Thread worker;
    private static volatile boolean stopRequested;
    private static volatile int total;
    private static volatile int done;
    private static volatile int changed;
    private static volatile int failed;
    private static volatile String current = "";
    private static volatile LocalDateTime startedAt;
    private static volatile LocalDateTime finishedAt;

    private final int adminId;

    private UpdateCheckJob(int adminId) {
        this.adminId = adminId;
    }

    /** Starts the job; false when one is already running. */
    public static synchronized boolean start(int adminId) {
        if (isRunning()) {
            return false;
        }
        stopRequested = false;
        total = 0;
        done = 0;
        changed = 0;
        failed = 0;
        current = "";
        startedAt = LocalDateTime.now();
        finishedAt = null;
        worker = new Thread(new UpdateCheckJob(adminId), "aspirantos-update-check");
        worker.setDaemon(true);   // never keeps Tomcat from shutting down
        worker.start();
        return true;
    }

    public static void stop() {
        stopRequested = true;
    }

    public static boolean isRunning() {
        return worker != null && worker.isAlive();
    }

    @Override
    public void run() {
        List<Exam> exams = new ExamDAO().getAllExams();
        total = exams.size();
        UpdateChecker checker = new UpdateChecker();
        for (Exam exam : exams) {
            if (stopRequested) {
                break;
            }
            current = exam.getShortName();
            UpdateCheck c = checker.check(exam, adminId);
            if (c.getErrorMessage() != null) {
                failed++;
            } else if (Boolean.TRUE.equals(c.getChangedSinceLast())) {
                changed++;
            }
            done++;
            try {
                Thread.sleep(300);   // be polite to the official websites
            } catch (InterruptedException e) {
                break;
            }
        }
        current = "";
        finishedAt = LocalDateTime.now();
    }

    /** Progress as JSON text for update-check-progress.jsp (numbers and a short name only). */
    public static String progressJson() {
        String name = current == null ? "" : current.replace("\\", "").replace("\"", "'");
        return "{\"running\":" + isRunning()
                + ",\"total\":" + total
                + ",\"done\":" + done
                + ",\"changed\":" + changed
                + ",\"failed\":" + failed
                + ",\"stopped\":" + stopRequested
                + ",\"current\":\"" + name + "\""
                + ",\"startedAt\":\"" + (startedAt == null ? "" : startedAt.toString()) + "\""
                + ",\"finishedAt\":\"" + (finishedAt == null ? "" : finishedAt.toString()) + "\"}";
    }
}
