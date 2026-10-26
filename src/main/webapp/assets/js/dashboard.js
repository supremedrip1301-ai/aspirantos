/* Dashboard counters count up from 0 when the page opens (skipped when the user prefers less motion). */
(function () {
    "use strict";
    if (window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
        return;
    }
    document.querySelectorAll("[data-count]").forEach(function (el) {
        var target = parseInt(el.getAttribute("data-count"), 10) || 0;
        if (target === 0) { return; }
        var start = null;
        var duration = 700;
        el.textContent = "0";
        function step(time) {
            if (start === null) { start = time; }
            var progress = Math.min(1, (time - start) / duration);
            el.textContent = String(Math.round(target * progress));
            if (progress < 1) { window.requestAnimationFrame(step); }
        }
        window.requestAnimationFrame(step);
    });
})();
