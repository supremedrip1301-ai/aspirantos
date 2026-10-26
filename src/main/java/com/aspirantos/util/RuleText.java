package com.aspirantos.util;

import com.aspirantos.engine.QualificationChecker;
import com.aspirantos.engine.RelaxationResolver;
import com.aspirantos.model.AgeRule;
import com.aspirantos.model.AttemptRule;
import com.aspirantos.model.DocSpec;
import com.aspirantos.model.OtherRule;
import com.aspirantos.model.QualificationRule;
import com.aspirantos.model.RelaxationRule;

/**
 * Turns rule rows into short sentences for the "Rules" tab of the exam page
 * (and later the admin rule editor), e.g. "21 to below 32 years on 1 August of the exam year".
 */
public class RuleText {

    public static String age(AgeRule r) {
        if (r == null || "NONE".equals(r.getCutoffType())) {
            return r != null && r.getMinAge() != null ? "At least " + r.getMinAge() + " years, no upper age limit" : "No age limit";
        }
        if ("DOB_WINDOW".equals(r.getCutoffType())) {
            String from = r.getDobFromOffsetYears() == null ? null
                    : "born on or after " + r.getDobFromDay() + " " + DateUtil.monthName(r.getDobFromMonth())
                      + " (year " + signed(r.getDobFromOffsetYears()) + ")";
            String to = r.getDobToOffsetYears() == null ? null
                    : "born on or before " + r.getDobToDay() + " " + DateUtil.monthName(r.getDobToMonth())
                      + " (year " + signed(r.getDobToOffsetYears()) + ")";
            if (from != null && to != null) {
                return "Date of birth window: " + from + " and " + to;
            }
            return "Date of birth window: " + (from != null ? from : to);
        }
        StringBuilder sb = new StringBuilder();
        if (r.getMinAge() != null && r.getMaxAge() != null) {
            sb.append(r.getMinAge()).append(" to ");
            sb.append("NOT_ATTAINED".equals(r.getMaxAgeSemantics()) ? "below " + r.getMaxAge() : r.getMaxAge() + " (inclusive)");
            sb.append(" years");
        } else if (r.getMinAge() != null) {
            sb.append("At least ").append(r.getMinAge()).append(" years, no upper limit");
        } else if (r.getMaxAge() != null) {
            sb.append("NOT_ATTAINED".equals(r.getMaxAgeSemantics()) ? "Below " + r.getMaxAge() : "At most " + r.getMaxAge())
              .append(" years");
        }
        sb.append(" on ").append(r.getCutoffDay()).append(" ").append(DateUtil.monthName(r.getCutoffMonth()));
        if ("FIXED_DATE_IN_PREVIOUS_YEAR".equals(r.getCutoffType())) {
            sb.append(" of the year before the exam");
        } else if ("FIXED_DATE_IN_NEXT_YEAR".equals(r.getCutoffType())) {
            sb.append(" of the year after the exam year");
        } else {
            sb.append(" of the exam year");
        }
        return sb.toString();
    }

    public static String relaxation(RelaxationRule r) {
        String who = "CATEGORY".equals(r.getRelaxationType())
                ? RelaxationResolver.categoryLabel(r.getCategory())
                : RelaxationResolver.typeLabel(r.getRelaxationType())
                  + (r.getCategory() == null ? "" : " (" + RelaxationResolver.categoryLabel(r.getCategory()) + ")");
        String what;
        if ("REPLACE_WITH_MAX".equals(r.getStacking()) && r.getOverallMaxAgeCap() != null) {
            what = "upper age raised to " + r.getOverallMaxAgeCap();
        } else if ("REPLACE_WITH_MAX".equals(r.getStacking())) {
            what = "up to " + r.getYears() + " years (only the largest such relaxation counts)";
        } else if ("ADD_AFTER_SERVICE_DEDUCTION".equals(r.getStacking())) {
            what = "+" + r.getYears() + " years after deducting military service"
                   + (r.getOverallMaxAgeCap() != null ? ", actual age below " + r.getOverallMaxAgeCap() : "");
        } else {
            what = "+" + r.getYears() + " years" + (r.getOverallMaxAgeCap() != null ? ", at most " + r.getOverallMaxAgeCap() : "");
        }
        return who + ": " + what + (r.isRequiresStateDomicile() ? " (state domicile only)" : "");
    }

    public static String attemptWho(AttemptRule r) {
        String who = r.getCategory() == null ? "All categories" : RelaxationResolver.categoryLabel(r.getCategory());
        if (r.getPwbd() != null) {
            who += r.getPwbd() ? ", PwBD" : ", not PwBD";
        }
        return who;
    }

    public static String attemptLimit(AttemptRule r) {
        String limit = r.getMaxAttempts() == null ? "Unlimited (within age)" : r.getMaxAttempts() + " attempts";
        switch (r.getCountingRule()) {
            case "CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM":
                return limit + " in " + r.getWindowYears() + " consecutive years from the Class 12 year";
            case "PER_ROLLING_12_MONTHS":
                return limit.replace(" attempts", " tests") + " in any 12 months"
                       + (r.getMinGapDays() != null ? ", at least " + r.getMinGapDays() + " days apart" : "");
            case "LIFETIME_TOTAL":
                return limit + " in a lifetime";
            default:
                return limit;
        }
    }

    public static String countingRule(String counting) {
        switch (counting) {
            case "APPEARED_IN_FIRST_STAGE":
                return "An attempt counts when you appear in the first stage";
            case "APPLIED":
                return "Every application counts";
            case "PER_SITTING":
                return "Every sitting counts";
            case "CONSECUTIVE_YEARS_FROM_QUALIFYING_EXAM":
                return "Limited to consecutive years after Class 12";
            case "PER_ROLLING_12_MONTHS":
                return "Rolling 12-month retake limit";
            default:
                return "Lifetime limit";
        }
    }

    public static String qualification(QualificationRule q) {
        if (q.getTextSummary() != null) {
            return q.getTextSummary();
        }
        StringBuilder sb = new StringBuilder(cap(QualificationChecker.levelWords(q.getRequiredLevel())));
        if (q.getAcceptedDegrees() != null && !"ANY".equalsIgnoreCase(q.getAcceptedDegrees())) {
            sb.append(" (").append(q.getAcceptedDegrees()).append(")");
        }
        if (q.getRequiredSubjects() != null) {
            sb.append(", subjects ").append(q.getRequiredSubjects().replace(",", ", ").replace("|", " or "));
        }
        return sb.toString();
    }

    public static String marks(QualificationRule q) {
        if (q.getMinPercentGeneral() == null) {
            return "-";
        }
        String s = trim(q.getMinPercentGeneral()) + "%";
        if (q.getMinPercentRelaxed() != null) {
            s += " (" + trim(q.getMinPercentRelaxed()) + "% for " + q.getRelaxedFor().replace(",", ", ").replace("OBC_NCL", "OBC-NCL") + ")";
        }
        return s;
    }

    public static String other(OtherRule o) {
        if (o.getTextSummary() != null) {
            return o.getTextSummary();
        }
        String v = o.getRuleValue() == null ? "" : o.getRuleValue().replace("_", " ").replace(",", ", ").toLowerCase();
        switch (o.getRuleType()) {
            case "GENDER":
                return "Open to: " + v;
            case "MARITAL_STATUS":
                return "Marital status: " + v;
            case "NATIONALITY":
                return "Nationality: " + v;
            case "DOMICILE":
                return "Domicile: " + o.getRuleValue();
            case "PHYSICAL_STANDARD":
                return "Physical / medical standards apply";
            default:
                return cap(v);
        }
    }

    public static String otherType(String type) {
        return cap(type.replace('_', ' ').toLowerCase());
    }

    public static String docType(String type) {
        switch (type) {
            case "LEFT_THUMB":
                return "Left thumb impression";
            case "HANDWRITTEN_DECLARATION":
                return "Handwritten declaration";
            case "CATEGORY_CERT":
                return "Category certificate";
            case "PWBD_CERT":
                return "PwBD certificate";
            default:
                return cap(type.toLowerCase());
        }
    }

    /** "200-230 x 230-260 px" */
    public static String docSize(DocSpec d) {
        if (d.getMinWidthPx() == null && d.getMaxWidthPx() == null) {
            return "-";
        }
        return range(d.getMinWidthPx(), d.getMaxWidthPx()) + " x " + range(d.getMinHeightPx(), d.getMaxHeightPx()) + " px";
    }

    public static String docKb(DocSpec d) {
        if (d.getMinKb() == null && d.getMaxKb() == null) {
            return "-";
        }
        return range(d.getMinKb(), d.getMaxKb()) + " KB";
    }

    private static String range(Integer min, Integer max) {
        if (min != null && max != null) {
            return min.equals(max) ? String.valueOf(min) : min + "-" + max;
        }
        return min != null ? "min " + min : (max != null ? "max " + max : "?");
    }

    private static String signed(int offset) {
        return offset >= 0 ? "+" + offset : String.valueOf(offset);
    }

    private static String cap(String s) {
        return s == null || s.isEmpty() ? "" : Character.toUpperCase(s.charAt(0)) + s.substring(1);
    }

    private static String trim(double v) {
        return v == Math.floor(v) ? String.valueOf((int) v) : String.valueOf(v);
    }
}
