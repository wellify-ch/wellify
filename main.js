// Nav scroll effect — versteckt auf Splash, erscheint danach
const nav = document.getElementById('nav');
window.addEventListener('scroll', () => {
  const pastSplash = window.scrollY > window.innerHeight * 0.8;
  nav.classList.toggle('scrolled', pastSplash);
  nav.style.opacity = pastSplash ? '1' : '0';
  nav.style.pointerEvents = pastSplash ? 'auto' : 'none';
});
// Initialzustand
nav.style.opacity = '0';
nav.style.pointerEvents = 'none';

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

// Contact form
document.getElementById('contactForm').addEventListener('submit', function(e) {
  e.preventDefault();
  const success = document.getElementById('formSuccess');
  const btn = this.querySelector('button[type="submit"]');
  btn.textContent = 'Wird gesendet…';
  btn.disabled = true;
  setTimeout(() => {
    success.style.display = 'block';
    btn.textContent = 'Nachricht senden';
    btn.disabled = false;
    this.reset();
  }, 1000);
});

// Active nav link on scroll
const sections = document.querySelectorAll('section[id]');
const navLinks = document.querySelectorAll('.nav__links a[href^="#"]');

window.addEventListener('scroll', () => {
  let current = '';
  sections.forEach(section => {
    if (window.scrollY >= section.offsetTop - 120) current = section.id;
  });
  navLinks.forEach(link => {
    link.style.color = link.getAttribute('href') === `#${current}` ? '' : '';
  });
}, { passive: true });
