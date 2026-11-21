/* CibulkaOS — minimální JS: kopírování make příkazů (vanilla, bez závislostí) */
(function () {
  "use strict";

  var $ = function (sel) { return document.querySelector(sel); };
  var $$ = function (sel) { return Array.prototype.slice.call(document.querySelectorAll(sel)); };

  var toastEl = $("#toast");
  var toastTimer;
  function toast(msg) {
    if (!toastEl) return;
    toastEl.textContent = msg;
    toastEl.classList.add("show");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { toastEl.classList.remove("show"); }, 2200);
  }

  function copyText(text) {
    if (navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve, reject) {
      var ta = document.createElement("textarea");
      ta.value = text;
      ta.setAttribute("readonly", "");
      ta.style.position = "fixed";
      ta.style.opacity = "0";
      document.body.appendChild(ta);
      ta.select();
      try { document.execCommand("copy") ? resolve() : reject(new Error("copy")); }
      catch (e) { reject(e); }
      finally { document.body.removeChild(ta); }
    });
  }

  $$(".copy").forEach(function (btn) {
    btn.addEventListener("click", function () {
      var text = btn.getAttribute("data-copy");
      copyText(text).then(function () {
        btn.textContent = "✓ Hotovo";
        btn.classList.add("done");
        toast("Zkopírováno: " + text);
        setTimeout(function () { btn.textContent = "Kopírovat"; btn.classList.remove("done"); }, 1600);
      }, function () { toast("Schránka zablokována fízlokracií."); });
    });
  });

  var y = $("#year");
  if (y) y.textContent = String(new Date().getFullYear());
})();
