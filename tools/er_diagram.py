# Regenerates docs/diagrams/er-diagram.svg (hand-placed layout of the 26 tables).
# Usage: python tools/er_diagram.py docs/diagrams/er-diagram.svg
import sys
OUT = sys.argv[1]

W, COLW = 1620, 270
# group colours (header fill)
G = {"user": "#0F1B33", "asp": "#1F7A4F", "track": "#C98A0B", "exam": "#E8792B", "rule": "#5B4FA8", "admin": "#5B6478"}
PARENT_LINE = {"app_user": "#2D5BA8", "exam": "#E8792B", "exam_rule_version": "#5B4FA8"}

# name: (group, x, y, [columns])  column prefix: "PK " / "FK " / "UK "
T = {
 "remember_token": ("user", 30, 70, ["PK id", "FK user_id", "UK token_hash", "expires_at"]),
 "audit_log": ("admin", 30, 210, ["PK id", "FK user_id", "action", "entity, entity_id", "ip_address", "created_at"]),
 "notification": ("admin", 30, 390, ["PK id", "FK user_id", "title, message", "link_url", "is_read"]),
 "app_setting": ("admin", 30, 560, ["PK setting_key", "setting_value", "description"]),

 "app_user": ("user", 345, 70, ["PK id", "full_name", "UK email", "password_hash, salt", "role (ASPIRANT/ADMIN)", "status", "last_login_at"]),
 "aspirant_profile": ("asp", 345, 290, ["PK FK user_id", "dob, gender", "category", "is_pwbd, pwbd_percent", "is_ex_serviceman", "FK domicile_state_code", "marital_status, nationality"]),
 "education": ("asp", 345, 520, ["PK id", "FK user_id", "level, degree_name", "subjects", "percentage / cgpa", "passing_year, status"]),
 "work_experience": ("asp", 345, 720, ["PK id", "FK user_id", "organisation", "start_date, end_date", "is_relevant_professional"]),

 "user_exam_tracking": ("track", 660, 70, ["PK id", "FK user_id", "FK exam_id", "attempts_used_before_app", "UK (user_id, exam_id)"]),
 "attempt_log": ("track", 660, 240, ["PK id", "FK user_id", "FK exam_id", "cycle_year, sitting_no", "stage_reached", "counts_as_attempt (trigger)"]),
 "eligibility_snapshot": ("track", 660, 430, ["PK id", "FK user_id", "FK exam_id", "FK rule_version_id", "status, headline", "attempts_remaining", "last_eligible_year"]),
 "info_report": ("track", 660, 640, ["PK id", "FK user_id", "FK exam_id", "message, status", "admin_reply"]),
 "state_master": ("asp", 660, 810, ["PK code", "UK name", "type (STATE/UT)"]),

 "exam_category": ("exam", 975, 70, ["PK id", "UK code", "name", "accent_color, sort_order"]),
 "conducting_body": ("exam", 975, 210, ["PK id", "UK short_name", "full_name", "body_type"]),
 "exam": ("exam", 975, 350, ["PK id", "UK code", "name, short_name", "FK category_id", "FK body_id", "FK state_code", "scope, sector, purpose", "cycles_per_year", "data_confidence", "FK active_rule_version_id"]),
 "doc_spec": ("exam", 975, 620, ["PK id", "FK exam_id", "doc_type", "width / height px", "min_kb, max_kb", "UK (exam_id, doc_type)"]),
 "exam_event": ("exam", 975, 800, ["PK id", "FK exam_id", "cycle_year, event_type", "event_date"]),
 "exam_update_check": ("admin", 660, 940, ["PK id", "FK exam_id", "FK checked_by", "content_sha256", "changed_since_last"]),

 "exam_rule_version": ("rule", 1300, 70, ["PK id", "FK exam_id", "version_no", "status (DRAFT/ACTIVE/ARCHIVED)", "FK created_by", "UK one ACTIVE per exam"]),
 "age_rule": ("rule", 1300, 260, ["PK id", "FK rule_version_id", "min_age, max_age", "max_age_semantics", "cutoff_type / DOB window"]),
 "relaxation_rule": ("rule", 1300, 420, ["PK id", "FK rule_version_id", "relaxation_type, category", "years, stacking"]),
 "attempt_rule": ("rule", 1300, 560, ["PK id", "FK rule_version_id", "category, is_pwbd", "max_attempts", "counting_rule"]),
 "qualification_rule": ("rule", 1300, 720, ["PK id", "FK rule_version_id", "required_level", "accepted_degrees, subjects", "min_percent"]),
 "other_rule": ("rule", 1300, 880, ["PK id", "FK rule_version_id", "rule_type, rule_value", "is_blocking"]),
 "rule_change_log": ("rule", 975, 940, ["PK id", "FK exam_id", "FK rule_version_id", "FK changed_by", "column_name", "old_value -> new_value"]),
}

FKS = """age_rule exam_rule_version
aspirant_profile state_master
aspirant_profile app_user
attempt_log exam
attempt_log app_user
attempt_rule exam_rule_version
audit_log app_user
doc_spec exam
education app_user
eligibility_snapshot exam
eligibility_snapshot app_user
eligibility_snapshot exam_rule_version
exam exam_rule_version
exam conducting_body
exam exam_category
exam state_master
exam_event exam
exam_rule_version exam
exam_rule_version app_user
exam_update_check exam
exam_update_check app_user
info_report exam
info_report app_user
notification app_user
other_rule exam_rule_version
qualification_rule exam_rule_version
relaxation_rule exam_rule_version
remember_token app_user
rule_change_log exam
rule_change_log app_user
rule_change_log exam_rule_version
user_exam_tracking exam
user_exam_tracking app_user
work_experience app_user"""

BW, HH, RH = 250, 24, 17

def box_h(t):
    return HH + RH * len(T[t][3]) + 6

def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

H = max(T[t][2] + box_h(t) for t in T) + 120
out = []
out.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" font-family="Manrope, Segoe UI, Arial, sans-serif">')
out.append('<title>AspirantOS - ER diagram (MySQL database aspirantos)</title>')
out.append(f'<rect width="{W}" height="{H}" fill="#F7F4EC"/>')
out.append('<text x="30" y="40" font-size="22" font-weight="700" fill="#0F1B33" font-family="Fraunces, Georgia, serif">AspirantOS — Entity Relationship Diagram</text>')
out.append('<text x="560" y="40" font-size="13" fill="#5B6478">26 tables · 34 foreign keys · database aspirantos (MySQL 8.4, InnoDB)</text>')

# relationship lines first (under the boxes)
lines = []
for ln in FKS.split("\n"):
    child, parent = ln.split()
    _, cx, cy, _ = T[child]; _, px, py, _ = T[parent]
    ch, ph = box_h(child), box_h(parent)
    cmy, pmy = cy + ch / 2, py + ph / 2
    color = PARENT_LINE.get(parent, "#8A8F9C")
    if abs(cx - px) < 5:     # same column: loop on the left side
        x1, x2 = cx, px
        y1, y2 = cmy, pmy
        bend = 40
        d = f"M{x1},{y1} C{x1-bend},{y1} {x2-bend},{y2} {x2},{y2}"
        cf_dir = -1
        p_dir = -1
    elif px > cx:            # parent to the right
        x1, y1, x2, y2 = cx + BW, cmy, px, pmy
        dx = (x2 - x1) / 2
        d = f"M{x1},{y1} C{x1+dx},{y1} {x2-dx},{y2} {x2},{y2}"
        cf_dir = 1; p_dir = -1
    else:                    # parent to the left
        x1, y1, x2, y2 = cx, cmy, px + BW, pmy
        dx = (x1 - x2) / 2
        d = f"M{x1},{y1} C{x1-dx},{y1} {x2+dx},{y2} {x2},{y2}"
        cf_dir = -1; p_dir = 1
    lines.append(f'<path d="{d}" fill="none" stroke="{color}" stroke-width="1.4" stroke-opacity="0.55"/>')
    # crow's foot (many) at the child end
    fx = x1 + cf_dir * 10
    lines.append(f'<path d="M{fx},{y1} L{x1},{y1-5} M{fx},{y1} L{x1},{y1} M{fx},{y1} L{x1},{y1+5}" stroke="{color}" stroke-width="1.4" fill="none"/>')
    # bar (one) at the parent end
    bx = x2 + p_dir * 7
    lines.append(f'<path d="M{bx},{y2-5} L{bx},{y2+5}" stroke="{color}" stroke-width="1.6"/>')
out += lines

for name, (grp, x, y, cols) in T.items():
    h = box_h(name)
    out.append(f'<g>')
    out.append(f'<rect x="{x}" y="{y}" width="{BW}" height="{h}" rx="8" fill="#FFFFFF" stroke="#E3DED2" stroke-width="1.2"/>')
    out.append(f'<path d="M{x},{y+8} a8,8 0 0 1 8,-8 h{BW-16} a8,8 0 0 1 8,8 v{HH-8} h-{BW} z" fill="{G[grp]}"/>')
    out.append(f'<text x="{x+10}" y="{y+16.5}" font-size="13" font-weight="700" fill="#FFFFFF" font-family="JetBrains Mono, Consolas, monospace">{esc(name)}</text>')
    for i, c in enumerate(cols):
        ty = y + HH + 14 + i * RH
        tag, text = "", c
        for k in ("PK FK ", "PK ", "FK ", "UK "):
            if c.startswith(k):
                tag, text = k.strip(), c[len(k):]
                break
        tx = x + 10
        if tag:
            tcol = {"PK": "#B93A2B", "FK": "#2D5BA8", "UK": "#1F7A4F", "PK FK": "#B93A2B"}[tag]
            out.append(f'<text x="{tx}" y="{ty}" font-size="9.5" font-weight="700" fill="{tcol}" font-family="JetBrains Mono, Consolas, monospace">{tag}</text>')
            tx += 22 if tag != "PK FK" else 40
        out.append(f'<text x="{tx}" y="{ty}" font-size="11.5" fill="#0F1B33">{esc(text)}</text>')
    out.append('</g>')

# legend
ly = H - 70
out.append(f'<rect x="30" y="{ly-22}" width="{W-60}" height="58" rx="8" fill="#FFFFFF" stroke="#E3DED2"/>')
lx = 46
for label, col in [("Users", G["user"]), ("Aspirant data", G["asp"]), ("Tracking & cache", G["track"]), ("Exam master", G["exam"]), ("Versioned rules", G["rule"]), ("Admin & audit", G["admin"])]:
    out.append(f'<rect x="{lx}" y="{ly-8}" width="14" height="14" rx="3" fill="{col}"/><text x="{lx+20}" y="{ly+4}" font-size="12" fill="#0F1B33">{esc(label)}</text>')
    lx += 150
out.append(f'<text x="{lx+10}" y="{ly+4}" font-size="12" fill="#5B6478">PK = primary key · FK = foreign key · UK = unique key · bar = one, crow\'s foot = many</text>')
out.append(f'<text x="46" y="{ly+26}" font-size="12" fill="#5B6478">Line colour = parent table: blue → app_user, orange → exam, purple → exam_rule_version, grey → others. Views, procedures and triggers are listed in docs/DB_DESIGN.md.</text>')
out.append('</svg>')
open(OUT, "w", encoding="utf-8").write("\n".join(out))
print("written", OUT, W, H)
