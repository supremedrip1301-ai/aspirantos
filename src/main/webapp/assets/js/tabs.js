/* Tabs on the exam page (keyboard friendly: Left / Right / Home / End).
   Without JavaScript every panel is simply shown one below the other. */
(function () {
    "use strict";
    document.querySelectorAll("[data-tabs]").forEach(function (box) {
        var tabs = Array.prototype.slice.call(box.querySelectorAll("[role='tab']"));
        var panels = tabs.map(function (t) { return document.getElementById(t.getAttribute("aria-controls")); });
        box.classList.add("tabs-ready");

        function select(index, focus) {
            tabs.forEach(function (t, i) {
                var on = i === index;
                t.setAttribute("aria-selected", on ? "true" : "false");
                t.tabIndex = on ? 0 : -1;
                panels[i].hidden = !on;
            });
            if (focus) { tabs[index].focus(); }
            var name = tabs[index].id.replace("tab-", "");
            if (window.history && window.history.replaceState) {
                window.history.replaceState(null, "", "#" + name);
            }
        }

        tabs.forEach(function (t, i) {
            t.addEventListener("click", function () { select(i, false); });
            t.addEventListener("keydown", function (e) {
                var next = null;
                if (e.key === "ArrowRight") { next = (i + 1) % tabs.length; }
                if (e.key === "ArrowLeft") { next = (i - 1 + tabs.length) % tabs.length; }
                if (e.key === "Home") { next = 0; }
                if (e.key === "End") { next = tabs.length - 1; }
                if (next !== null) { e.preventDefault(); select(next, true); }
            });
        });

        // start with the tab named in the address (#rules), else "My eligibility"
        var wanted = window.location.hash.replace("#", "") || "mine";
        var start = 0;
        tabs.forEach(function (t, i) { if (t.id === "tab-" + wanted) { start = i; } });
        select(start, false);
    });
})();
