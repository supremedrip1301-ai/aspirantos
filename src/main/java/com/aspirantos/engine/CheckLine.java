package com.aspirantos.engine;

/**
 * One line of the eligibility explanation, e.g.
 * PASS | Age | "You will be 30 years 10 months 17 days on 01-Aug-2027 ...".
 * The exam detail page prints these lines in order.
 */
public class CheckLine {

    public static final String PASS = "PASS";
    public static final String FAIL = "FAIL";
    public static final String WARN = "WARN";
    public static final String INFO = "INFO";

    private String name;          // Age, Relaxation, Attempts, Qualification, Subjects, ...
    private String result;        // PASS / FAIL / WARN / INFO
    private String explanation;   // plain English a student can read aloud

    public CheckLine() {
    }

    public CheckLine(String name, String result, String explanation) {
        this.name = name;
        this.result = result;
        this.explanation = explanation;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getExplanation() {
        return explanation;
    }

    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }

    public boolean isFail() {
        return FAIL.equals(result);
    }

    /** Stored in eligibility_snapshot.details_text, one line per check: RESULT|Name|Explanation */
    public String toStorageText() {
        return result + "|" + name + "|" + explanation.replace("\n", " ");
    }

    /** Reads back a line written by toStorageText(); null for a broken line. */
    public static CheckLine fromStorageText(String line) {
        String[] parts = line.split("\\|", 3);
        if (parts.length < 3) {
            return null;
        }
        return new CheckLine(parts[1], parts[0], parts[2]);
    }

    @Override
    public String toString() {
        return result + " | " + name + " | " + explanation;
    }
}
