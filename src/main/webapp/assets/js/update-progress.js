/* Progress of "Check all exams": asks update-check-progress.jsp (JSON) every 2 seconds
   and moves the bar; when the job ends the page reloads to show the new results. */
(function () {
    "use strict";
    var box = document.getElementById("check-all");
    if (!box) { return; }
    var fill = document.getElementById("progress-fill");
    var text = document.getElementById("progress-text");
    var wasRunning = box.getAttribute("data-running") === "true";

    function show(p) {
        var pct = p.total > 0 ? Math.round(p.done * 100 / p.total) : 0;
        fill.style.width = pct + "%";
        if (p.running) {
            text.textContent = "Checked " + p.done + " of " + p.total + " (" + pct + "%) - now: " + p.current
                + " - changed: " + p.changed + ", could not check: " + p.failed;
        } else if (p.total > 0) {
            text.textContent = (p.stopped ? "Stopped" : "Finished") + ": " + p.done + " of " + p.total
                + " checked, " + p.changed + " changed, " + p.failed + " could not be checked.";
        }
    }

    function poll() {
        fetch(box.getAttribute("data-progress-url"), { cache: "no-store" })
            .then(function (r) { return r.json(); })
            .then(function (p) {
                show(p);
                if (p.running) {
                    wasRunning = true;
                    window.setTimeout(poll, 2000);
                } else if (wasRunning) {
                    window.location.reload();
                }
            })
            .catch(function () { text.textContent = "Progress is not available right now."; });
    }
    poll();
})();
