document.addEventListener("DOMContentLoaded", function(e) {
  const element = document.querySelector('.new_copy_vacancy_form') || document.body || {};
  const dataset = element.dataset || {};
  dataLayer.push({ vacancy_state: dataset.vacancyState });
});