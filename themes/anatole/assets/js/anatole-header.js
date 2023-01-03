document.addEventListener('DOMContentLoaded', () => {
  const navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);
  const nav = document.querySelector('nav');
  if (navbarBurgers.length < 1) return;
  navbarBurgers.forEach((navbarBurger) => {
    navbarBurger.addEventListener('click', () => {
      navbarBurger.classList.toggle('nav--active');
      nav.classList.toggle('nav--active');
    });
  });
});

var elements = document.querySelectorAll('p');
Array.prototype.forEach.call(elements, function(el, i){
    if(el.innerHTML=='[expand]') {
        var parentcontent = el.parentNode.innerHTML.replace('<p>[expand]</p>','<div class="expand" style="display: none; height: 0; overflow: hidden;">').replace('<p>[/expand]</p>','</div>');
        el.parentNode.innerHTML = parentcontent;
    }
});

var elements = document.querySelectorAll('div.expand');
Array.prototype.forEach.call(elements, function(el, i){
    el.previousElementSibling.innerHTML = el.previousElementSibling.innerHTML + '<span>..&nbsp; <a href="#" style="cursor: pointer;" onclick="this.parentNode.parentNode.nextElementSibling.style.display = \'block\'; this.parentNode.parentNode.nextElementSibling.style.height = \'auto\'; this.parentNode.style.display = \'none\';">read&nbsp;more&nbsp;&rarr;</a></span>';
});
