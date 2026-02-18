document.querySelectorAll('[data-year]').forEach((el) => {
  el.textContent = String(new Date().getFullYear());
});

const menuBtn = document.querySelector('[data-menu-btn]');
const nav = document.querySelector('[data-nav]');

if (menuBtn && nav) {
  menuBtn.addEventListener('click', () => {
    const expanded = menuBtn.getAttribute('aria-expanded') === 'true';
    menuBtn.setAttribute('aria-expanded', String(!expanded));
    nav.classList.toggle('open');
  });
}

const slides = document.querySelectorAll('[data-slide]');
if (slides.length > 0) {
  let index = 0;
  const show = (nextIndex) => {
    slides.forEach((slide, i) => {
      slide.classList.toggle('active', i === nextIndex);
    });
    index = nextIndex;
  };

  const next = () => show((index + 1) % slides.length);
  const prev = () => show((index - 1 + slides.length) % slides.length);

  const nextBtn = document.querySelector('[data-next]');
  const prevBtn = document.querySelector('[data-prev]');

  if (nextBtn) nextBtn.addEventListener('click', next);
  if (prevBtn) prevBtn.addEventListener('click', prev);

  show(0);
  setInterval(next, 4500);
}
