/* [EXTRA] fetch() + JSON. Instant UPSC check on the landing page: the form is sent with fetch() to instant-check.jsp,
   which answers with JSON; the answer is shown under the form (aria-live, so screen readers
   read it). Without JavaScript the form still opens the JSON answer. */
(function () {
    "use strict";
    var form = document.querySelector("[data-instant-check]");
    if (!form) { return; }
    var out = document.getElementById("ic-result");

    var button = form.querySelector("button[type='submit']");

    function show(html, css) {
        out.className = "instant-result " + (css || "");
        out.innerHTML = html;
        out.setAttribute("aria-busy", css === "is-loading" ? "true" : "false");
        if (button) { button.disabled = css === "is-loading"; }
    }
    function esc(s) {
        return String(s).replace(/[&<>"']/g, function (c) {
            return { "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;" }[c];
        });
    }

    form.addEventListener("submit", function (event) {
        event.preventDefault();
        if (!form.elements.dob.value) {
            show("Please enter your date of birth.", "is-error");
            form.elements.dob.focus();
            return;
        }
        var params = new URLSearchParams(new FormData(form));
        show("Checking...", "is-loading");
        fetch(form.getAttribute("action") + "?" + params.toString(), { headers: { "Accept": "application/json" } })
            .then(function (r) { return r.json(); })
            .then(function (a) {
                if (!a.ok) {
                    show(esc(a.error), "is-error");
                    return;
                }
                var css = "is-" + a.status.toLowerCase().replace("_", "-");
                show("<p class=\"ic-headline\">" + esc(a.headline) + "</p>"
                    + "<p class=\"small\">" + esc(a.relaxation) + (a.dobWindow ? " " + esc(a.dobWindow) + "." : "") + "</p>"
                    + "<p class=\"small muted\">Worked out for " + esc(a.today) + ". Create an account to check all exams.</p>", css);
            })
            .catch(function () { show("The check is not available right now.", "is-error"); });
    });
})();
