/* Eligibility horizon page:
   - the bars grow in from the left when the page opens (not with "reduce motion"),
   - the age clock ticks every second: exact age = years, months, days, hours, minutes, seconds
     from the date of birth to "today" (the app date, which may be the admin's simulation date)
     plus the current time of day. */
(function () {
    "use strict";
    var reduce = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (!reduce) {
        document.querySelectorAll(".h-bar").forEach(function (bar, i) {
            bar.style.transformOrigin = bar.getAttribute("x") + "px 0";
            bar.style.transform = "scaleX(0)";
            window.setTimeout(function () {
                bar.style.transition = "transform .6s ease-out";
                bar.style.transform = "scaleX(1)";
            }, 60 + i * 40);
        });
    }

    var clock = document.getElementById("age-clock");
    if (!clock) { return; }
    var text = document.getElementById("clock-text");
    var birthday = document.getElementById("clock-birthday");
    var dob = clock.getAttribute("data-dob").split("-");
    var day = clock.getAttribute("data-today").split("-");
    var born = new Date(+dob[0], +dob[1] - 1, +dob[2]);

    function plural(n, word) { return n + " " + word + (n === 1 ? "" : "s"); }

    function tick() {
        var now = new Date();
        var at = new Date(+day[0], +day[1] - 1, +day[2], now.getHours(), now.getMinutes(), now.getSeconds());
        var y = at.getFullYear() - born.getFullYear();
        var m = at.getMonth() - born.getMonth();
        var d = at.getDate() - born.getDate();
        if (d < 0) {
            m--;
            d += new Date(at.getFullYear(), at.getMonth(), 0).getDate();   // days of the previous month
        }
        if (m < 0) { y--; m += 12; }
        text.textContent = plural(y, "year") + " " + plural(m, "month") + " " + plural(d, "day") + " "
            + String(at.getHours()).padStart(2, "0") + ":" + String(at.getMinutes()).padStart(2, "0") + ":" + String(at.getSeconds()).padStart(2, "0");
        var next = new Date(at.getFullYear(), born.getMonth(), born.getDate());
        if (next <= new Date(at.getFullYear(), at.getMonth(), at.getDate())) {
            next = new Date(at.getFullYear() + 1, born.getMonth(), born.getDate());
        }
        var days = Math.round((next - new Date(at.getFullYear(), at.getMonth(), at.getDate())) / 86400000);
        birthday.textContent = days === 0 ? "Happy birthday!" : plural(days, "day") + " to your next birthday (you turn " + (y + 1) + ").";
    }
    tick();
    window.setInterval(tick, 1000);
})();
