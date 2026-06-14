/* ── CONFIG ─────────────────────────────────────── */
const API = 'https://localhost:7000/api'; // Change to your .NET API URL

/* ── HELPERS ────────────────────────────────────── */
async function apiFetch(path) {
    try {
        const r = await fetch(`${API}${path}`);
        if (!r.ok) throw new Error();
        const d = await r.json();
        return d.success ? d.data : null;
    } catch { return null; }
}

/* ── NAV ────────────────────────────────────────── */
const navbar = document.getElementById('navbar');
const hamburger = document.getElementById('hamburger');
const navLinks = document.getElementById('navLinks');

window.addEventListener('scroll', () => {
    navbar.classList.toggle('scrolled', window.scrollY > 60);
});
hamburger.addEventListener('click', () => navLinks.classList.toggle('open'));

/* ── REVEAL on SCROLL ───────────────────────────── */
const observer = new IntersectionObserver((entries) => {
    entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
}, { threshold: 0.1 });
document.querySelectorAll('.reveal').forEach(el => observer.observe(el));

/* ── SETTINGS ───────────────────────────────────── */
async function loadSettings() {
    const s = await apiFetch('/settings');
    if (!s) return;
    if (s.cafe_address) document.getElementById('addr').textContent = s.cafe_address;
    if (s.cafe_phone) document.getElementById('phone').textContent = s.cafe_phone;
    if (s.cafe_email) document.getElementById('email').textContent = s.cafe_email;
    if (s.cafe_hours) document.getElementById('hours').textContent = s.cafe_hours;
    if (s.cafe_about) document.getElementById('about-desc').textContent = s.cafe_about;
}

/* ── MENU ───────────────────────────────────────── */
let allItems = [];
let allCategories = [];

const menuTabs = document.getElementById('menuTabs');
const menuGrid = document.getElementById('menuGrid');

const EMOJI = { 'Hot Coffee': '☕', 'Cold Coffee': '🧊', 'Tea & Others': '🍵', 'Food & Snacks': '🥐' };

async function loadMenu() {
    const [cats, items] = await Promise.all([
        apiFetch('/menu/categories'),
        apiFetch('/menu/items')
    ]);
    if (!cats || !items) {
        menuGrid.innerHTML = '<p class="menu-loading">Menu unavailable — check back soon.</p>';
        return;
    }
    allCategories = cats;
    allItems = items;

    // Build tabs
    const allBtn = makeTab('All', 'all', true);
    menuTabs.appendChild(allBtn);
    cats.forEach(c => menuTabs.appendChild(makeTab(c.name, c.id)));

    renderMenuItems(allItems);
}

function makeTab(label, val, active = false) {
    const b = document.createElement('button');
    b.className = 'tab-btn' + (active ? ' active' : '');
    b.textContent = label;
    b.dataset.cat = val;
    b.addEventListener('click', () => {
        document.querySelectorAll('.tab-btn').forEach(x => x.classList.remove('active'));
        b.classList.add('active');
        const filtered = val === 'all' ? allItems : allItems.filter(i => i.categoryId == val);
        renderMenuItems(filtered);
    });
    return b;
}

function renderMenuItems(items) {
    if (!items.length) { menuGrid.innerHTML = '<p class="menu-loading">Nothing here yet.</p>'; return; }
    menuGrid.innerHTML = items.map(item => {
        const emoji = EMOJI[item.categoryName] || '🫖';
        return `
    <div class="menu-card">
      <div class="menu-card-img">${emoji}</div>
      <div class="menu-card-body">
        <h3 class="menu-card-name">${item.name}</h3>
        <p class="menu-card-desc">${item.description || ''}</p>
        <div class="menu-card-footer">
          <span class="menu-card-price">₹${item.price}</span>
          ${item.isFeatured ? '<span class="menu-badge">Signature</span>' : ''}
        </div>
      </div>
    </div>`;
    }).join('');
}

/* ── TEAM ───────────────────────────────────────── */
async function loadTeam() {
    const team = await apiFetch('/team');
    const grid = document.getElementById('teamGrid');
    if (!team || !team.length) {
        grid.innerHTML = '<p class="menu-loading">Meet us in person!</p>';
        return;
    }
    grid.innerHTML = team.map(m => `
    <div class="team-card reveal">
      <div class="team-avatar">${m.name[0]}</div>
      <h3 class="team-name">${m.name}</h3>
      <p class="team-role">${m.role || ''}</p>
      <p class="team-bio">${m.bio || ''}</p>
    </div>`).join('');
    grid.querySelectorAll('.reveal').forEach(el => observer.observe(el));
}

/* ── TESTIMONIALS ───────────────────────────────── */
async function loadTestimonials() {
    const data = await apiFetch('/testimonials');
    if (!data || !data.length) return;
    const track = document.getElementById('testimonialTrack');
    track.innerHTML = data.map(t => `
    <div class="testimonial-card">
      <div class="stars">${'★'.repeat(t.rating)}${'☆'.repeat(5 - t.rating)}</div>
      <p class="testimonial-text">"${t.review}"</p>
      <p class="testimonial-author">— ${t.customerName}</p>
    </div>`).join('');
}

/* ── CONTACT FORM ───────────────────────────────── */
document.getElementById('contactForm').addEventListener('submit', async function (e) {
    e.preventDefault();
    const btn = this.querySelector('button');
    const msg = document.getElementById('formMsg');
    btn.textContent = 'Sending…'; btn.disabled = true;
    msg.className = 'form-msg';

    const body = {
        name: this.name.value,
        email: this.email.value,
        phone: this.phone.value,
        subject: this.subject.value,
        message: this.message.value,
    };

    try {
        const r = await fetch(`${API}/contact`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });
        const d = await r.json();
        if (d.success) {
            msg.className = 'form-msg success';
            msg.textContent = '✓ Message sent! We\'ll get back to you soon.';
            this.reset();
        } else throw new Error();
    } catch {
        msg.className = 'form-msg error';
        msg.textContent = '✗ Something went wrong. Please try again.';
    }
    btn.textContent = 'Send Message →'; btn.disabled = false;
});

/* ── INIT ───────────────────────────────────────── */
loadSettings();
loadMenu();
loadTeam();
loadTestimonials();