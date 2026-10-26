/* Rule pack import: a picked .csv file is read in the browser (FileReader) and put into the
   text box, so the server only receives normal form text (no file upload needed). */
(function () {
    "use strict";
    document.querySelectorAll("input[type='file'][data-fill-textarea]").forEach(function (input) {
        input.addEventListener("change", function () {
            var file = input.files && input.files[0];
            var box = document.getElementById(input.getAttribute("data-fill-textarea"));
            if (!file || !box) { return; }
            if (file.size > 1024 * 1024) {
                window.alert("The file is larger than 1 MB - please split the rule pack.");
                input.value = "";
                return;
            }
            var reader = new FileReader();
            reader.onload = function () { box.value = reader.result; };
            reader.readAsText(file, "UTF-8");
        });
    });
})();
