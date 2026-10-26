package com.aspirantos.engine;

import java.util.ArrayList;
import java.util.List;

/**
 * Result of RelaxationResolver: how many years are added to the upper age, which
 * relaxations were applied and which were skipped (with the reason).
 *
 * Arithmetic (D31): effective upper age = base + (sum of ADD rows)
 *                                        + (largest REPLACE_WITH_MAX row without a cap);
 * a REPLACE_WITH_MAX row with a cap raises the upper age to that cap (D29).
 */
public class RelaxationOutcome {

    private int addYears;                 // ADD and ADD_AFTER_SERVICE_DEDUCTION rows
    private int replaceYears;             // largest REPLACE_WITH_MAX row without a cap
    private String replaceLabel;
    private Integer raisedTo;             // REPLACE_WITH_MAX with overall_max_age_cap
    private String raisedLabel;
    private Integer hardCap;              // cap written on an ADD row (e.g. ex-servicemen: actual age below 50)
    private double serviceDeductionYears; // ADD_AFTER_SERVICE_DEDUCTION: military service subtracted from the age
    private boolean domicileSkipped;      // a reserved-category relaxation was refused for a non-domicile
    private List<String> applied = new ArrayList<>();   // "OBC-NCL 3", "PwBD 10"
    private List<String> notes = new ArrayList<>();     // skipped relaxations with the reason

    /** Upper age after all relaxations. */
    public int effectiveMax(int baseMax) {
        int value = baseMax + addYears + replaceYears;
        if (raisedTo != null && raisedTo > value) {
            value = raisedTo;
        }
        return value;
    }

    /** Years that move the "born on or after" date of a DOB window earlier. */
    public int totalYears() {
        return addYears + replaceYears;
    }

    /** "Base upper age 32 + OBC-NCL 3 + PwBD 10 = 45" */
    public String breakdown(Integer baseMax) {
        if (baseMax == null) {
            return "No upper age limit, so no relaxation is needed.";
        }
        StringBuilder sb = new StringBuilder("Base upper age " + baseMax);
        if (applied.isEmpty() && replaceLabel == null) {
            sb.append(", no relaxation applies to you");
        } else {
            for (String a : applied) {
                sb.append(" + ").append(a);
            }
            if (replaceLabel != null) {
                sb.append(" + ").append(replaceLabel);
            }
            sb.append(" = ").append(baseMax + addYears + replaceYears);
        }
        if (raisedTo != null && raisedTo > baseMax + addYears + replaceYears) {
            sb.append("; ").append(raisedLabel).append(" raises it to ").append(raisedTo);
        }
        if (serviceDeductionYears > 0) {
            sb.append(" (compared with your age after deducting ")
              .append(formatYears(serviceDeductionYears)).append(" of military service)");
        }
        if (hardCap != null) {
            sb.append("; actual age must stay below ").append(hardCap);
        }
        sb.append(".");
        return sb.toString();
    }

    static String formatYears(double years) {
        if (years == Math.floor(years)) {
            return (int) years + (years == 1 ? " year" : " years");
        }
        return years + " years";
    }

    public int getAddYears() {
        return addYears;
    }

    public void setAddYears(int addYears) {
        this.addYears = addYears;
    }

    public int getReplaceYears() {
        return replaceYears;
    }

    public void setReplaceYears(int replaceYears) {
        this.replaceYears = replaceYears;
    }

    public String getReplaceLabel() {
        return replaceLabel;
    }

    public void setReplaceLabel(String replaceLabel) {
        this.replaceLabel = replaceLabel;
    }

    public Integer getRaisedTo() {
        return raisedTo;
    }

    public void setRaisedTo(Integer raisedTo) {
        this.raisedTo = raisedTo;
    }

    public String getRaisedLabel() {
        return raisedLabel;
    }

    public void setRaisedLabel(String raisedLabel) {
        this.raisedLabel = raisedLabel;
    }

    public Integer getHardCap() {
        return hardCap;
    }

    public void setHardCap(Integer hardCap) {
        this.hardCap = hardCap;
    }

    public double getServiceDeductionYears() {
        return serviceDeductionYears;
    }

    public void setServiceDeductionYears(double serviceDeductionYears) {
        this.serviceDeductionYears = serviceDeductionYears;
    }

    public boolean isDomicileSkipped() {
        return domicileSkipped;
    }

    public void setDomicileSkipped(boolean domicileSkipped) {
        this.domicileSkipped = domicileSkipped;
    }

    public List<String> getApplied() {
        return applied;
    }

    public List<String> getNotes() {
        return notes;
    }
}
