/* ============================================================
   Asset Management System — shared front-end behaviour
   ============================================================ */

document.addEventListener('DOMContentLoaded', function () {

  /* ---------- Mobile sidebar toggle ---------- */
  var menuBtn = document.querySelector('.menu-btn');
  var sidebar = document.querySelector('.sidebar');
  if (menuBtn && sidebar) {
    menuBtn.addEventListener('click', function () {
      sidebar.classList.toggle('open');
    });
    document.addEventListener('click', function (e) {
      if (sidebar.classList.contains('open') &&
          !sidebar.contains(e.target) &&
          !menuBtn.contains(e.target)) {
        sidebar.classList.remove('open');
      }
    });
  }

  /* ---------- Live table search ----------
     Any input with [data-table-search="<table-id>"] filters the
     rows of the referenced table by visible text.            */
  document.querySelectorAll('[data-table-search]').forEach(function (input) {
    var table = document.getElementById(input.getAttribute('data-table-search'));
    if (!table) return;
    input.addEventListener('input', function () {
      var q = input.value.trim().toLowerCase();
      table.querySelectorAll('tbody tr').forEach(function (row) {
        var text = row.innerText.toLowerCase();
        row.style.display = text.indexOf(q) > -1 ? '' : 'none';
      });
      updateEmptyState(table);
    });
  });

  /* ---------- Column / status filter dropdowns ----------
     Any select with [data-table-filter="<table-id>"] and a
     [data-col] attribute filters rows by exact match on the
     text content of that column. value="" clears the filter. */
  document.querySelectorAll('[data-table-filter]').forEach(function (sel) {
    var table = document.getElementById(sel.getAttribute('data-table-filter'));
    var col = parseInt(sel.getAttribute('data-col'), 10);
    if (!table) return;
    sel.addEventListener('change', function () {
      var val = sel.value.trim().toLowerCase();
      table.querySelectorAll('tbody tr').forEach(function (row) {
        if (!val) { row.style.display = ''; return; }
        var cell = row.children[col];
        var text = cell ? cell.innerText.trim().toLowerCase() : '';
        row.style.display = text.indexOf(val) > -1 ? '' : 'none';
      });
      updateEmptyState(table);
    });
  });

  function updateEmptyState(table) {
    var wrap = table.closest('.table-wrap') || table.parentElement;
    var visible = Array.prototype.filter.call(
      table.querySelectorAll('tbody tr'),
      function (r) { return r.style.display !== 'none'; }
    ).length;
    var msg = wrap.querySelector('.no-results-msg');
    if (visible === 0) {
      if (!msg) {
        msg = document.createElement('div');
        msg.className = 'no-results-msg empty-state';
        msg.innerHTML = '<h3>No matching records</h3><p>Try a different search term or clear the filters.</p>';
        wrap.appendChild(msg);
      }
    } else if (msg) {
      msg.remove();
    }
  }

  /* ---------- Generic modal open/close ----------
     [data-open-modal="id"] opens #id, [data-close-modal] closes
     the nearest .modal-backdrop                                 */
  document.querySelectorAll('[data-open-modal]').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var modal = document.getElementById(btn.getAttribute('data-open-modal'));
      if (modal) modal.classList.add('open');

      // If the trigger carries asset data, populate a QR modal
      if (modal && modal.id === 'qrModal') {
        var assetId = btn.getAttribute('data-asset-id') || '';
        var assetName = btn.getAttribute('data-asset-name') || '';
        var label = modal.querySelector('.qr-label');
        if (label) label.textContent = assetId + ' — ' + assetName;
        renderQR(assetId);
      }
    });
  });
  document.querySelectorAll('[data-close-modal]').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var modal = btn.closest('.modal-backdrop');
      if (modal) modal.classList.remove('open');
    });
  });
  document.querySelectorAll('.modal-backdrop').forEach(function (backdrop) {
    backdrop.addEventListener('click', function (e) {
      if (e.target === backdrop) backdrop.classList.remove('open');
    });
  });

  /* ---------- QR code rendering ----------
     Uses qrcode.js (loaded from cdnjs). The encoded value is the
     Asset ID — in a real deployment this links to
     assets.jsp?action=view&id=<AssetID>                          */
  function renderQR(assetId) {
    var target = document.getElementById('qrCanvas');
    if (!target || typeof QRCode === 'undefined') return;
    target.innerHTML = '';
    new QRCode(target, {
      text: 'ASSET:' + assetId,
      width: 160,
      height: 160,
      colorDark: '#1F3A2E',
      colorLight: '#ffffff'
    });
  }

  /* ---------- Delete confirmation ----------
     Any form with [data-confirm] shows a confirm dialog before
     submitting (used for delete / disposal actions).            */
  document.querySelectorAll('form[data-confirm]').forEach(function (form) {
    form.addEventListener('submit', function (e) {
      if (!window.confirm(form.getAttribute('data-confirm'))) {
        e.preventDefault();
      }
    });
  });

  /* ---------- Auto-dismiss flash alerts ---------- */
  document.querySelectorAll('.alert[data-autohide]').forEach(function (alert) {
    setTimeout(function () {
      alert.style.transition = 'opacity .4s ease';
      alert.style.opacity = '0';
      setTimeout(function () { alert.remove(); }, 400);
    }, 4000);
  });

  /* ---------- Login role toggle (visual only) ---------- */
  document.querySelectorAll('.role-toggle input').forEach(function (radio) {
    radio.addEventListener('change', function () {
      document.querySelectorAll('.role-toggle label').forEach(function (l) {
        l.classList.remove('checked');
      });
      var label = document.querySelector('.role-toggle label[for="' + radio.id + '"]');
      if (label) label.classList.add('checked');
    });
  });

});
