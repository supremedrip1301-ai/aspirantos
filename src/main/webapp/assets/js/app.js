/* AspirantOS shared script (vanilla JavaScript, no libraries).
   Phase 3: only small helpers; feature scripts are added in later phases. */
(function () {
    "use strict";

    // Delete / dangerous links and buttons ask before acting:
    // <a href="..." data-confirm="Delete this row?">  (same idea as onclick="return confirm(...)" in the lab)
    document.addEventListener("click", function (event) {
        var target = event.target.closest("[data-confirm]");
        if (target && !window.confirm(target.getAttribute("data-confirm"))) {
            event.preventDefault();
        }
    });
})();
