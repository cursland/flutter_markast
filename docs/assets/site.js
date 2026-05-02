'use strict';

// ── State ─────────────────────────────────────────────────────────────────

let config      = null;
let currentPath = null;
let tocObserver = null;
const openSections = new Set(JSON.parse(localStorage.getItem('mast-open') || '[]'));

const CHEVRON = `<svg class="nav-section-chevron" xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>`;

// ── Bootstrap ─────────────────────────────────────────────────────────────

async function init() {
  try {
    config = await fetch('config.json').then(r => r.json());
  } catch {
    showError('No se pudo cargar <code>config.json</code>.');
    return;
  }

  document.title = config.title + ' documentación';
  initLayout();
  renderSidebar();
  initTheme();
  bindUI();
  routeFromHash();
}

// ── Layout (desktop sidebar collapse) ─────────────────────────────────────

function initLayout() {
  if (localStorage.getItem('mast-sidebar') === 'collapsed') {
    document.body.classList.add('sidebar-collapsed');
  }
}

function toggleDesktopSidebar() {
  const collapsed = document.body.classList.toggle('sidebar-collapsed');
  localStorage.setItem('mast-sidebar', collapsed ? 'collapsed' : 'open');
}

// ── Sidebar rendering ─────────────────────────────────────────────────────

function renderSidebar() {
  const nav = document.getElementById('sidebarNav');

  nav.innerHTML = config.categories.map((cat, i) => {
    const id      = slugify(cat.title);
    const isOpen  = openSections.has(id) || openSections.size === 0 && i === 0;
    if (isOpen) openSections.add(id);

    return `
      <div class="nav-section ${isOpen ? 'open' : ''}" data-section="${id}">
        <button class="nav-section-toggle" aria-expanded="${isOpen}" data-section="${id}">
          <span>${esc(cat.title)}</span>
          ${CHEVRON}
        </button>
        <div class="nav-section-items" role="list">
          <div class="nav-section-items-inner">
            ${cat.articles.map(art => `
              <a class="nav-link"
                 role="listitem"
                 href="#${art.path}"
                 data-path="${art.path}"
                 data-title="${esc(art.title)}"
                 data-category="${esc(cat.title)}">${esc(art.title)}</a>
            `).join('')}
          </div>
        </div>
      </div>`;
  }).join('');

  nav.querySelectorAll('.nav-section-toggle').forEach(btn => {
    btn.addEventListener('click', () => toggleSection(btn.dataset.section));
  });
}

function toggleSection(id) {
  const section = document.querySelector(`.nav-section[data-section="${id}"]`);
  const isOpen  = section.classList.toggle('open');
  section.querySelector('.nav-section-toggle').setAttribute('aria-expanded', isOpen);
  if (isOpen) openSections.add(id);
  else        openSections.delete(id);
  localStorage.setItem('mast-open', JSON.stringify([...openSections]));
}

function openSectionFor(path) {
  const link = document.querySelector(`.nav-link[data-path="${path}"]`);
  if (!link) return;
  const section = link.closest('.nav-section');
  if (section && !section.classList.contains('open')) {
    toggleSection(section.dataset.section);
  }
}

// ── Search ────────────────────────────────────────────────────────────────

function initSearch() {
  const input = document.getElementById('searchInput');

  input.addEventListener('input', () => filterNav(input.value.trim()));
  input.addEventListener('keydown', e => {
    if (e.key === 'Escape') { input.value = ''; filterNav(''); input.blur(); }
  });

  document.addEventListener('keydown', e => {
    if (e.key === '/' && document.activeElement !== input) {
      e.preventDefault();
      input.focus();
      input.select();
    }
  });
}

function filterNav(query) {
  const nav   = document.getElementById('sidebarNav');
  const q     = query.toLowerCase();
  let   total = 0;

  nav.querySelectorAll('.nav-section').forEach(section => {
    let sectionHits = 0;
    section.querySelectorAll('.nav-link').forEach(link => {
      const title   = link.dataset.title.toLowerCase();
      const matches = !q || title.includes(q);
      link.style.display = matches ? '' : 'none';
      if (matches) {
        sectionHits++;
        total++;
        link.innerHTML = q
          ? esc(link.dataset.title).replace(
              new RegExp(esc(q).replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gi'),
              m => `<mark>${m}</mark>`
            )
          : esc(link.dataset.title);
      }
    });

    if (q) {
      if (!section.classList.contains('open') && sectionHits > 0) {
        section.classList.add('open');
      }
    }
    section.style.display = (q && sectionHits === 0) ? 'none' : '';
  });

  let noResults = nav.querySelector('.nav-no-results');
  if (q && total === 0) {
    if (!noResults) {
      noResults = document.createElement('p');
      noResults.className = 'nav-no-results';
      nav.appendChild(noResults);
    }
    noResults.textContent = `Sin resultados para "${query}"`;
  } else if (noResults) {
    noResults.remove();
  }
}

// ── Routing ───────────────────────────────────────────────────────────────

function routeFromHash() {
  const hash = decodeURIComponent(location.hash.slice(1));
  if (hash) {
    loadArticle(hash);
  } else {
    const first = config?.categories[0]?.articles[0];
    if (first) loadArticle(first.path);
  }
}

async function loadArticle(path) {
  if (path === currentPath) { closeMobileSidebar(); return; }
  currentPath = path;

  openSectionFor(path);
  setActiveLink(path);
  updateBreadcrumb(path);
  closeMobileSidebar();

  const body = document.getElementById('articleBody');
  body.style.opacity = '0';
  body.style.transform = 'translateY(6px)';

  try {
    const res = await fetch(path);
    if (!res.ok) throw new Error(`${res.status}`);
    const html = await res.text();

    body.innerHTML = html;
    body.style.transition = 'opacity 200ms ease, transform 200ms ease';
    body.offsetHeight; // reflow
    body.style.opacity  = '1';
    body.style.transform = 'translateY(0)';

    location.hash = path;
    window.scrollTo({ top: 0, behavior: 'instant' });

    initCodeBlocks(body);
    initTabs(body);
    initHeadingAnchors(body);
    buildTOC(body);
  } catch {
    body.innerHTML = `
      <article class="markast">
        <h1>Página no encontrada</h1>
        <p>No se pudo cargar <code>${esc(path)}</code>.</p>
        <p>Ejecuta <code>python build.py</code> dentro de la carpeta <code>docs/</code>
           y luego sirve con <code>python -m http.server 8090</code>.</p>
      </article>`;
    body.style.opacity = '1';
    body.style.transform = 'translateY(0)';
  }

  buildFooterNav(path);
}

function setActiveLink(path) {
  document.querySelectorAll('.nav-link').forEach(a => {
    a.classList.toggle('active', a.dataset.path === path);
  });
  document.querySelectorAll('.nav-section').forEach(s => {
    s.classList.toggle('has-active', !!s.querySelector('.nav-link.active'));
  });
}

function updateBreadcrumb(path) {
  const bc = document.getElementById('breadcrumb');
  if (!config) { bc.innerHTML = ''; return; }

  for (const cat of config.categories) {
    for (const art of cat.articles) {
      if (art.path === path) {
        document.title = `${art.title} — ${config.title} documentación`;
        bc.innerHTML = `
          <span class="breadcrumb-cat">${esc(cat.title)}</span>
          <span class="breadcrumb-sep">/</span>
          <span class="breadcrumb-page">${esc(art.title)}</span>`;
        return;
      }
    }
  }
  bc.innerHTML = '';
}

// ── Footer prev/next ──────────────────────────────────────────────────────

function buildFooterNav(currentPath) {
  const footer = document.getElementById('articleFooter');
  const all    = config.categories.flatMap(c => c.articles);
  const idx    = all.findIndex(a => a.path === currentPath);
  const prev   = all[idx - 1];
  const next   = all[idx + 1];

  footer.innerHTML = `
    ${prev ? `<a class="footer-nav-btn prev" href="#${prev.path}" data-path="${prev.path}">
        <span class="footer-nav-label">← Anterior</span>
        <span class="footer-nav-title">${esc(prev.title)}</span>
      </a>` : '<div></div>'}
    ${next ? `<a class="footer-nav-btn next" href="#${next.path}" data-path="${next.path}">
        <span class="footer-nav-label">Siguiente →</span>
        <span class="footer-nav-title">${esc(next.title)}</span>
      </a>` : '<div></div>'}
  `;

  footer.querySelectorAll('.footer-nav-btn[data-path]').forEach(btn => {
    btn.addEventListener('click', e => {
      e.preventDefault();
      loadArticle(btn.dataset.path);
    });
  });
}

// ── Code blocks ───────────────────────────────────────────────────────────

function initCodeBlocks(root) {
  root.querySelectorAll('pre').forEach(pre => {
    const code = pre.querySelector('code');
    if (!code) return;

    const lang = getLang(code);
    if (lang) {
      pre.setAttribute('data-lang', lang);
      code.classList.add('language-' + lang);
      try { hljs.highlightElement(code); } catch { /* unknown lang */ }
    }
  });
}

function getLang(el) {
  for (const cls of el.classList) {
    if (cls.startsWith('lang-'))     return cls.slice(5);
    if (cls.startsWith('language-')) return cls.slice(9);
  }
  return null;
}

// ── Tabs ──────────────────────────────────────────────────────────────────

function initTabs(root) {
  root.querySelectorAll('.tabs').forEach(tabs => {
    const buttons = Array.from(tabs.querySelectorAll('.tab'));
    const panes   = Array.from(tabs.querySelectorAll('.tab-pane'));

    function activate(name) {
      buttons.forEach(b => b.classList.toggle('active', b.dataset.tab === name));
      panes.forEach(p   => p.classList.toggle('active', p.dataset.tab === name));
    }

    if (buttons.length) activate(buttons[0].dataset.tab);
    buttons.forEach(btn => btn.addEventListener('click', () => activate(btn.dataset.tab)));
  });
}

// ── Heading anchors ───────────────────────────────────────────────────────

function initHeadingAnchors(root) {
  root.querySelectorAll('.markast h2, .markast h3').forEach(h => {
    if (!h.id) {
      h.id = slugify(h.textContent);
    }
    const anchor = document.createElement('a');
    anchor.className = 'anchor';
    anchor.href = '#' + h.id;
    anchor.innerHTML = `<img src="assets/icons/link.svg" alt="anchor">`;
    anchor.addEventListener('click', e => {
      e.preventDefault();
      history.replaceState(null, '', '#' + currentPath + '-' + h.id);
      h.scrollIntoView({ behavior: 'smooth' });
    });
    h.appendChild(anchor);
  });
}

// ── Table of contents ─────────────────────────────────────────────────────

function buildTOC(root) {
  if (tocObserver) { tocObserver.disconnect(); tocObserver = null; }

  const tocNav = document.getElementById('tocNav');
  const headings = Array.from(root.querySelectorAll('.markast h2, .markast h3'));

  if (headings.length < 2) {
    tocNav.innerHTML = '';
    document.getElementById('tocPanel').style.visibility = 'hidden';
    return;
  }

  document.getElementById('tocPanel').style.visibility = '';
  tocNav.innerHTML = headings.map(h => `
    <a class="toc-link" href="#${h.id}" data-id="${h.id}" data-level="${h.tagName[1]}">
      ${esc(h.textContent.replace(/\s*#\s*$/, ''))}
    </a>`).join('');

  tocNav.querySelectorAll('.toc-link').forEach(link => {
    link.addEventListener('click', e => {
      e.preventDefault();
      document.getElementById(link.dataset.id)?.scrollIntoView({ behavior: 'smooth' });
    });
  });

  tocObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      const link = tocNav.querySelector(`[data-id="${entry.target.id}"]`);
      if (link) link.classList.toggle('active', entry.isIntersecting);
    });
  }, { rootMargin: '-20px 0px -70% 0px', threshold: 0 });

  headings.forEach(h => tocObserver.observe(h));
}

// ── Theme ─────────────────────────────────────────────────────────────────

function initTheme() {
  setTheme(localStorage.getItem('mast-theme') || 'light');
}

function toggleTheme() {
  setTheme(document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark');
}

function setTheme(theme) {
  document.documentElement.dataset.theme = theme;
  document.getElementById('hljs-theme').href = theme === 'dark'
    ? 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/atom-one-dark.min.css'
    : 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/atom-one-light.min.css';
  localStorage.setItem('mast-theme', theme);
}

// ── UI bindings ───────────────────────────────────────────────────────────

function bindUI() {
  document.getElementById('themeToggle').addEventListener('click', toggleTheme);

  const sidebar  = document.getElementById('sidebar');
  const overlay  = document.getElementById('sidebarOverlay');
  const toggle   = document.getElementById('sidebarToggle');

  toggle.addEventListener('click', () => {
    if (window.matchMedia('(max-width: 860px)').matches) {
      // Mobile: slide-over overlay behavior
      sidebar.classList.toggle('open');
      overlay.classList.toggle('open');
    } else {
      // Desktop: collapse/expand sidebar inline
      toggleDesktopSidebar();
    }
  });

  overlay.addEventListener('click', closeMobileSidebar);
  document.getElementById('sidebarClose')?.addEventListener('click', closeMobileSidebar);

  // Close on nav link click
  document.getElementById('sidebarNav').addEventListener('click', e => {
    const link = e.target.closest('.nav-link');
    if (!link) return;
    e.preventDefault();
    loadArticle(link.dataset.path);
    history.pushState(null, '', '#' + link.dataset.path);
  });

  window.addEventListener('hashchange', routeFromHash);
  initSearch();
}

function closeMobileSidebar() {
  document.getElementById('sidebar').classList.remove('open');
  document.getElementById('sidebarOverlay').classList.remove('open');
}

function showError(msg) {
  document.getElementById('articleBody').innerHTML =
    `<article class="markast"><p style="color:red">⚠ ${msg}</p></article>`;
}

// ── Utilities ─────────────────────────────────────────────────────────────

function slugify(str) {
  return str.toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function esc(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

document.addEventListener('DOMContentLoaded', init);
