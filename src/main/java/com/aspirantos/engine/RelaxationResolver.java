package com.aspirantos.engine;

import java.util.ArrayList;
import java.util.List;

import com.aspirantos.model.Exam;
import com.aspirantos.model.Profile;
import com.aspirantos.model.RelaxationRule;

/**
 * Decides which age relaxations apply to the student (MASTER_PROMPT PART 6, step 3).
 *
 * Order: category, PwBD (benchmark 40 %+), ex-serviceman, J&K 1980-89, government
 * employee, women, widow/divorced women, transgender, state domicile.
 * For each type a category-specific row wins over the general (NULL) row (D29).
 * A row marked requires_state_domicile is given only to that state's domicile;
 * other candidates are treated as General and the reason is recorded.
 */
public class RelaxationResolver {

    private static final String[] TYPE_ORDER = {
        "CATEGORY", "PWBD", "EX_SERVICEMAN", "JK_DOMICILE_1980_89", "GOVT_EMPLOYEE",
        "WOMEN", "WIDOW_DIVORCED_WOMEN", "TRANSGENDER", "STATE_DOMICILE"
    };

    public RelaxationOutcome resolve(CandidateData candidate, Exam exam, List<RelaxationRule> rules) {
        RelaxationOutcome out = new RelaxationOutcome();
        Profile p = candidate.getProfile();
        String category = candidate.getCategory();
        boolean domicileOk = isDomicileOk(p, exam);

        // REPLACE_WITH_MAX rows without a cap: only the largest one is used (D31)
        List<String> replaceLabels = new ArrayList<>();
        List<Integer> replaceYears = new ArrayList<>();

        for (String type : TYPE_ORDER) {
            List<RelaxationRule> ofType = new ArrayList<>();
            for (RelaxationRule r : rules) {
                if (type.equals(r.getRelaxationType())) {
                    ofType.add(r);
                }
            }
            if (ofType.isEmpty()) {
                continue;
            }
            if (!"CATEGORY".equals(type) && !candidateHas(type, candidate, exam)) {
                if ("PWBD".equals(type) && p.isPwbd()) {
                    out.getNotes().add("PwBD relaxation needs a benchmark disability (40% or more); your profile says "
                            + p.getPwbdPercent() + "%.");
                }
                continue;
            }

            RelaxationRule row = pickRow(ofType, category);
            if (row == null) {
                if ("CATEGORY".equals(type) && !"GEN".equals(category)) {
                    out.getNotes().add("No age relaxation for " + categoryLabel(category) + " in this exam.");
                }
                continue;
            }
            String label = "CATEGORY".equals(type) ? categoryLabel(category) : typeLabel(type);

            if (row.isRequiresStateDomicile() && !domicileOk) {
                out.setDomicileSkipped(true);
                out.getNotes().add(label + " relaxation is only for domicile candidates of " + exam.getStateCode()
                        + "; you are treated as General for this exam.");
                continue;
            }

            if ("REPLACE_WITH_MAX".equals(row.getStacking())) {
                if (row.getOverallMaxAgeCap() != null) {
                    if (out.getRaisedTo() == null || row.getOverallMaxAgeCap() > out.getRaisedTo()) {
                        out.setRaisedTo(row.getOverallMaxAgeCap());
                        out.setRaisedLabel(label);
                    }
                } else {
                    replaceLabels.add(label + " " + row.getYears());
                    replaceYears.add(row.getYears());
                }
            } else {
                out.setAddYears(out.getAddYears() + row.getYears());
                if ("ADD_AFTER_SERVICE_DEDUCTION".equals(row.getStacking())) {
                    double service = p.getEsmServiceYears() == null ? 0 : p.getEsmServiceYears();
                    out.setServiceDeductionYears(service);
                    if (p.getEsmServiceYears() == null) {
                        out.getNotes().add("Enter your years of military service in the profile - they are deducted from your age.");
                    }
                }
                if (row.getOverallMaxAgeCap() != null
                        && (out.getHardCap() == null || row.getOverallMaxAgeCap() < out.getHardCap())) {
                    out.setHardCap(row.getOverallMaxAgeCap());
                }
                out.getApplied().add(label + " " + row.getYears());
            }
        }

        // keep the largest "up to N years" relaxation, mention the others
        int best = -1;
        for (int i = 0; i < replaceYears.size(); i++) {
            if (best == -1 || replaceYears.get(i) > replaceYears.get(best)) {
                best = i;
            }
        }
        if (best >= 0) {
            out.setReplaceYears(replaceYears.get(best));
            out.setReplaceLabel(replaceLabels.get(best));
            for (int i = 0; i < replaceLabels.size(); i++) {
                if (i != best) {
                    out.getNotes().add(replaceLabels.get(i) + " is not added - for this exam only the largest relaxation counts.");
                }
            }
        }
        return out;
    }

    /** State exams: true when the student's domicile is the exam's state (or the exam is not a state exam). */
    public static boolean isDomicileOk(Profile p, Exam exam) {
        if (!"STATE".equals(exam.getScope()) || exam.getStateCode() == null) {
            return true;
        }
        return p != null && exam.getStateCode().equals(p.getDomicileStateCode());
    }

    private boolean candidateHas(String type, CandidateData c, Exam exam) {
        Profile p = c.getProfile();
        switch (type) {
            case "PWBD":
                return c.isBenchmarkPwbd();
            case "EX_SERVICEMAN":
                return p.isExServiceman();
            case "JK_DOMICILE_1980_89":
                return p.isJkDomicile198089();
            case "GOVT_EMPLOYEE":
                return p.isGovtEmployee();
            case "WOMEN":
                return c.isFemale();
            case "WIDOW_DIVORCED_WOMEN":
                return c.isFemale() && ("WIDOWED".equals(p.getMaritalStatus()) || "DIVORCED".equals(p.getMaritalStatus()));
            case "TRANSGENDER":
                return "TRANSGENDER".equals(p.getGender());
            case "STATE_DOMICILE":
                return exam.getStateCode() != null && exam.getStateCode().equals(p.getDomicileStateCode());
            default:
                return false;
        }
    }

    /** The row for the student's category, else the general row; null when nothing fits. */
    private RelaxationRule pickRow(List<RelaxationRule> rows, String category) {
        RelaxationRule general = null;
        for (RelaxationRule r : rows) {
            if (r.getCategory() == null) {
                general = r;
            } else if (r.getCategory().equals(category)) {
                return r;
            }
        }
        return general;
    }

    public static String categoryLabel(String category) {
        if (category == null) {
            return "General";
        }
        switch (category) {
            case "GEN":
                return "General";
            case "OBC_NCL":
                return "OBC-NCL";
            default:
                return category;   // EWS, SC, ST
        }
    }

    public static String typeLabel(String type) {
        switch (type) {
            case "PWBD":
                return "PwBD";
            case "EX_SERVICEMAN":
                return "Ex-serviceman";
            case "JK_DOMICILE_1980_89":
                return "J&K domicile (1980-89)";
            case "GOVT_EMPLOYEE":
                return "Government employee";
            case "WOMEN":
                return "Women";
            case "WIDOW_DIVORCED_WOMEN":
                return "Widow / divorced woman";
            case "TRANSGENDER":
                return "Transgender";
            case "STATE_DOMICILE":
                return "State domicile";
            default:
                return type;
        }
    }
}
