/* global $*/
const jQuery = $;

(function main($) {
  $(document).ready(() => {
    const fixedNavBar = $('#fixed-nav-bar');
    function closeBurgerMenu() {
      $('#container').unbind('touchmove');
      $('#container').css('marginLeft', '0');
      $('#content').css('width', 'auto');
      $('#contentLayer').css('display', 'none');
      $('#burger-menu').css('opacity', 0);
      $('#wrapper').removeClass('no-radius').addClass('radius');
      $('#content').css('min-height', 'auto');
    }
    $(window).scroll(() => {
      if ($(window).scrollTop() > 95) {
        fixedNavBar.removeClass('hidden').addClass('fixed');
      } else {
        fixedNavBar.removeClass('fixed').addClass('hidden');
      }
    });
    $('#mini-burger, #burger').click((event) => {
      if ($(event.currentTarget).hasClass('clicked')) {
        $(event.currentTarget).removeClass('clicked');
        closeBurgerMenu();
      } else {
        $(event.currentTarget).addClass('clicked');
        $('#content').css('min-height', $(window).height());
        $('#burger-menu').css('opacity', 1);
        $('#burger-menu').css('top', '70px');
        $('#wrapper').removeClass('radius').addClass('no-radius');
        const contentWidth = $('#content').width();
        $('#content').css('width', contentWidth);
        $('#contentLayer').css('display', 'block');
        $('#container').css('marginLeft', '70%');
        $('#container').bind('touchmove', (e) => {
          e.preventDefault();
        });
      }
    });
    $('#contentLayer').click(() => {
      closeBurgerMenu();
    });
  });
}(jQuery));
