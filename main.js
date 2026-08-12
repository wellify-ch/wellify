// Splash überspringen bei Ad-Traffic (UTM) oder wiederkehrenden Besuchern
(function() {
  const params = new URLSearchParams(window.location.search);
  const hasUtm = params.has('utm_source') || params.has('utm_medium') || params.has('gclid') || params.has('fbclid');
  const returning = sessionStorage.getItem('visited');
  if (hasUtm || returning) {
    const splash = document.getElementById('logoSplash');
    if (splash) splash.style.display = 'none';
    window.scrollTo(0, 0);
  }
  sessionStorage.setItem('visited', '1');
})();

// Nav scroll effect — versteckt auf Splash, erscheint danach
const nav = document.getElementById('nav');
window.addEventListener('scroll', () => {
  const splash = document.getElementById('logoSplash');
  const splashHidden = !splash || splash.style.display === 'none';
  const pastSplash = splashHidden || window.scrollY > window.innerHeight * 0.8;
  nav.classList.toggle('scrolled', pastSplash);
  nav.style.opacity = pastSplash ? '1' : '0';
  nav.style.pointerEvents = pastSplash ? 'auto' : 'none';
});
// Initialzustand
const _splash = document.getElementById('logoSplash');
const _splashHidden = !_splash || _splash.style.display === 'none';
nav.style.opacity = _splashHidden ? '1' : '0';
nav.style.pointerEvents = _splashHidden ? 'auto' : 'none';

// Mobile menu
const toggle = document.getElementById('navToggle');
const mobileMenu = document.getElementById('navMobile');
toggle.addEventListener('click', () => {
  mobileMenu.classList.toggle('open');
});

mobileMenu.querySelectorAll('a').forEach(link => {
  link.addEventListener('click', () => mobileMenu.classList.remove('open'));
});

// Scroll animations
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.12 });

document.querySelectorAll(
  '.service-card, .process__step, .testimonial-card, .pricing-card, .cert, .about__image, .about__content'
).forEach((el, i) => {
  el.classList.add('fade-in');
  el.style.transitionDelay = `${(i % 4) * 80}ms`;
  observer.observe(el);
});

// Contact form (bookingForm handles submission via Supabase inline script)

// DSG Banner
(function() {
  const banner = document.getElementById('dsgBanner');
  const close  = document.getElementById('dsgClose');
  if (!banner || !close) return;
  if (localStorage.getItem('dsg_ok')) { banner.style.display = 'none'; return; }
  close.addEventListener('click', () => {
    banner.style.display = 'none';
    localStorage.setItem('dsg_ok', '1');
  });
})();

// Active nav link on scroll
const sections = document.querySelectorAll('section[id]');
const navLinks = document.querySelectorAll('.nav__links a[href^="#"]');

window.addEventListener('scroll', () => {
  let current = '';
  sections.forEach(section => {
    if (window.scrollY >= section.offsetTop - 120) current = section.id;
  });
  navLinks.forEach(link => {
    const active = link.getAttribute('href') === `#${current}`;
    link.style.color = active ? 'var(--green-light)' : '';
    link.style.fontWeight = active ? '700' : '';
  });
}, { passive: true });
