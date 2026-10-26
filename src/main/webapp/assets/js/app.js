/* AspirantOS shared script (vanilla JavaScript, no libraries).
   - data-confirm        : ask before a delete / dangerous action (like onclick="return confirm(...)" in the lab)
   - data-strength-meter : password strength bar on register / settings
   - data-reveal         : show extra fields when a check box / radio is chosen (PwBD details ...)
   - data-validate       : client-side checks with alert(), like validateForm() in Experiment 5.
                           The server checks everything again - this only saves a round trip.
   - [EXTRA] toasts, the account menu in the header and data-print buttons (Phase 10). */
(function () {
    "use strict";

    // ------------------------------------------------------------ confirm before acting
    document.addEventListener("click", function (event) {
        var target = event.target.closest("[data-confirm]");
        if (target && !window.confirm(target.getAttribute("data-confirm"))) {
            event.preventDefault();
        }
    });

    // ------------------------------------------------------------ password strength
    function strengthOf(pw) {
        var score = 0;
        if (pw.length >= 8) { score++; }
        if (pw.length >= 12) { score++; }
        if (/[A-Za-z]/.test(pw) && /\d/.test(pw)) { score++; }
        if (/[a-z]/.test(pw) && /[A-Z]/.test(pw)) { score++; }
        if (/[^A-Za-z0-9]/.test(pw)) { score++; }
        return score;
    }
    document.querySelectorAll("[data-strength-meter]").forEach(function (input) {
        var box = document.getElementById(input.getAttribute("data-strength-meter"));
        if (!box) { return; }
        var bar = box.querySelector(".strength-bar");
        var text = box.querySelector(".strength-text");
        var hint = text.textContent;
        input.addEventListener("input", function () {
            var pw = input.value;
            var s = strengthOf(pw);
            var ok = pw.length >= 8 && /[A-Za-z]/.test(pw) && /\d/.test(pw);
            var words = ["Too short", "Weak", "Fair", "Good", "Strong", "Very strong"];
            var colours = ["var(--brick)", "var(--brick)", "var(--amber)", "var(--amber)", "var(--green)", "var(--green)"];
            bar.style.setProperty("--strength", (pw.length === 0 ? 0 : Math.max(10, s * 20)) + "%");
            bar.style.setProperty("--strength-colour", ok ? colours[s] : "var(--brick)");
            text.textContent = pw.length === 0 ? hint : (ok ? words[s] : "Needs 8+ characters with a letter and a number");
        });
    });

    // ------------------------------------------------------------ show / hide extra fields
    function updateReveals() {
        document.querySelectorAll("[data-reveal]").forEach(function (control) {
            var box = document.getElementById(control.getAttribute("data-reveal"));
            if (box) { box.hidden = !control.checked; }
        });
        document.querySelectorAll(".completed-only").forEach(function (box) {
            var appearing = document.querySelector("input[name='status'][value='APPEARING']");
            box.hidden = appearing ? appearing.checked : false;
        });
    }
    document.addEventListener("change", function (event) {
        if (event.target.matches("input[type='checkbox'], input[type='radio']")) { updateReveals(); }
    });
    updateReveals();

    // ------------------------------------------------------------ form checks with alert()
    var nameRegex = /^[A-Za-z .']{3,100}$/;
    var emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;

    function val(form, name) {
        var field = form.elements[name];
        return field ? String(field.value || "").trim() : "";
    }
    function checked(form, name) {
        var field = form.elements[name];
        return !!(field && field.checked);
    }
    function radioValue(form, name) {
        var picked = form.querySelector("input[name='" + name + "']:checked");
        return picked ? picked.value : "";
    }
    function number(form, name) {
        var v = val(form, name);
        return v === "" ? null : Number(v);
    }
    function passwordOk(pw) {
        return pw.length >= 8 && /[A-Za-z]/.test(pw) && /\d/.test(pw);
    }

    var checks = {
        login: function (f) {
            if (!emailRegex.test(val(f, "email"))) { return ["email", "Please enter a valid e-mail address."]; }
            if (val(f, "password") === "") { return ["password", "Please enter your password."]; }
            return null;
        },
        register: function (f) {
            if (!nameRegex.test(val(f, "fullName"))) { return ["fullName", "Name: letters, spaces, dots and apostrophes only, at least 3 characters."]; }
            if (!emailRegex.test(val(f, "email"))) { return ["email", "Please enter a valid e-mail address."]; }
            if (val(f, "phone") !== "" && !/^\d{10}$/.test(val(f, "phone"))) { return ["phone", "Mobile number must have exactly 10 digits."]; }
            if (!passwordOk(f.elements.password.value)) { return ["password", "Password must have at least 8 characters with a letter and a number."]; }
            if (f.elements.password.value !== f.elements.confirmPassword.value) { return ["confirmPassword", "The two passwords do not match."]; }
            return null;
        },
        step1: function (f) {
            if (!nameRegex.test(val(f, "fullName"))) { return ["fullName", "Please enter your full name (letters only)."]; }
            if (val(f, "phone") !== "" && !/^\d{10}$/.test(val(f, "phone"))) { return ["phone", "Mobile number must have exactly 10 digits."]; }
            if (val(f, "dob") === "") { return ["dob", "Please enter your date of birth."]; }
            if (val(f, "gender") === "") { return ["gender", "Please choose your gender."]; }
            if (val(f, "maritalStatus") === "") { return ["maritalStatus", "Please choose your marital status."]; }
            if (val(f, "domicileStateCode") === "") { return ["domicileStateCode", "Please choose your domicile state."]; }
            if (val(f, "pincode") !== "" && !/^[1-9]\d{5}$/.test(val(f, "pincode"))) { return ["pincode", "PIN code must have 6 digits and cannot start with 0."]; }
            return null;
        },
        step2: function (f) {
            if (radioValue(f, "category") === "") { return [null, "Please choose your category."]; }
            if (checked(f, "pwbd")) {
                if (val(f, "pwbdType") === "") { return ["pwbdType", "Please choose the type of disability."]; }
                var pct = number(f, "pwbdPercent");
                if (pct === null || pct < 1 || pct > 100 || pct % 1 !== 0) { return ["pwbdPercent", "Disability percentage must be a whole number from 1 to 100."]; }
            }
            if (checked(f, "exServiceman")) {
                var years = number(f, "esmServiceYears");
                if (years === null || years < 0.5 || years > 40) { return ["esmServiceYears", "Military service must be between 0.5 and 40 years."]; }
            }
            return null;
        },
        education: function (f) {
            var level = val(f, "level");
            if (level === "") { return ["level", "Please choose the level of education."]; }
            if (["DIPLOMA", "UG", "PG", "PHD", "PROFESSIONAL"].indexOf(level) >= 0 && val(f, "degreeName") === "") {
                return ["degreeName", "Please enter the degree or course name (for example B.A. or B.Tech)."];
            }
            var pct = number(f, "percentage");
            if (pct !== null && (pct < 0 || pct > 100)) { return ["percentage", "Percentage must be between 0 and 100."]; }
            if (radioValue(f, "status") === "APPEARING") {
                if (val(f, "expectedCompletionDate") === "") { return ["expectedCompletionDate", "Please enter the expected result date."]; }
            } else {
                var year = number(f, "passingYear");
                if (year === null || year < 1960 || year > new Date().getFullYear()) { return ["passingYear", "Please enter the passing year."]; }
            }
            return null;
        },
        work: function (f) {
            if (val(f, "organisation").length < 2) { return ["organisation", "Please enter the organisation name."]; }
            if (val(f, "startDate") === "") { return ["startDate", "Please enter the start date."]; }
            if (val(f, "endDate") !== "" && val(f, "endDate") < val(f, "startDate")) { return ["endDate", "The end date must be after the start date."]; }
            return null;
        },
        step4: function (f) {
            var inputs = f.querySelectorAll("input.num");
            for (var i = 0; i < inputs.length; i++) {
                var v = inputs[i].value.trim();
                if (v !== "" && (!/^\d+$/.test(v) || Number(v) > 20)) { return [inputs[i].name, "Attempts must be a whole number from 0 to 20."]; }
            }
            return null;
        },
        password: function (f) {
            if (val(f, "currentPassword") === "") { return ["currentPassword", "Please enter your current password."]; }
            if (!passwordOk(f.elements.newPassword.value)) { return ["newPassword", "The new password must have at least 8 characters with a letter and a number."]; }
            if (f.elements.newPassword.value !== f.elements.confirmPassword.value) { return ["confirmPassword", "The two new passwords do not match."]; }
            return null;
        },
        attempt: function (f) {
            if (f.elements.examId && val(f, "examId") === "") { return ["examId", "Please choose the exam."]; }
            var year = number(f, "cycleYear");
            if (year === null || year < 1990 || year > new Date().getFullYear() + 1) { return ["cycleYear", "Please enter the exam year."]; }
            var sitting = number(f, "sittingNo");
            if (sitting !== null && (sitting < 1 || sitting > 12)) { return ["sittingNo", "Sitting must be a number from 1 to 12."]; }
            return null;
        },
        report: function (f) {
            var len = val(f, "message").length;
            if (len < 10 || len > 1000) { return ["message", "Please describe the problem in 10 to 1000 characters."]; }
            return null;
        },
        "delete-account": function (f) {
            if (val(f, "password") === "") { return ["password", "Please enter your password."]; }
            if (!checked(f, "confirm")) { return ["confirm", "Please tick the box to confirm."]; }
            return null;
        }
    };

    document.addEventListener("submit", function (event) {
        var form = event.target;
        var check = checks[form.getAttribute("data-validate")];
        if (!check) { return; }
        var problem = check(form);
        if (problem) {
            event.preventDefault();
            window.alert(problem[1]);
            var field = problem[0] ? form.elements[problem[0]] : null;
            if (field && field.focus) {
                if (field.setAttribute) { field.setAttribute("aria-invalid", "true"); }
                field.focus();
            }
        }
    });
    // the red border of a wrong field goes away as soon as it is changed
    document.addEventListener("input", function (event) {
        if (event.target.getAttribute && event.target.getAttribute("aria-invalid") === "true") {
            event.target.removeAttribute("aria-invalid");
        }
    });

    // ------------------------------------------------------------ toasts (flash.jspf)
    function closeToast(toast) {
        toast.classList.add("leaving");
        window.setTimeout(function () {
            var region = toast.parentNode;
            toast.remove();
            if (region && !region.children.length) { region.remove(); }
        }, 300);
    }
    document.querySelectorAll(".toast").forEach(function (toast) {
        toast.querySelector(".toast-close").addEventListener("click", function () { closeToast(toast); });
        if (toast.classList.contains("flash-success")) {      // errors stay until they are closed
            window.setTimeout(function () { closeToast(toast); }, 6000);
        }
    });

    // ------------------------------------------------------------ account menu in the header
    var menu = document.querySelector(".user-menu");
    if (menu) {
        document.addEventListener("click", function (event) {
            if (menu.open && !menu.contains(event.target)) { menu.open = false; }
        });
        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape" && menu.open) {
                menu.open = false;
                menu.querySelector("summary").focus();
            }
        });
    }

    // ------------------------------------------------------------ print buttons
    document.addEventListener("click", function (event) {
        if (event.target.closest("[data-print]")) { window.print(); }
    });
})();
