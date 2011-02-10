(function($) {
  var boxHtml = $("<div id='lightbox_screen'></div><div id='lightbox_container'><div id='lightbox_content'></div></div>"),
    loadingContent = "<div id='lightbox_loading></div>";
  $.lightbox = {
    loading: function() {
      $.lightbox.show(loadingContent);
    },
    show: function(content) {
      var scrollTop = $(document).scrollTop(),
        windowHeight = $(window).height(),
        contentHeight, container, oldLeft, lbTop;
      content = $(content);
      $('#lightbox_loading').remove();
      if ($('#lightbox_container').length == 0) {
        boxHtml.hide().prependTo('body');
      }
      $('#lightbox_content').html(content);
      container = $('#lightbox_container');
      oldLeft = container.css('left');
      boxHtml.show();
      container.css('left', -1000);
      contentHeight = $('#lightbox_content').outerHeight();
      container.hide();
      container.css('left', oldLeft)
      if (contentHeight > windowHeight) {
        $('#lightbox_content').css({ position: 'absolute', top: scrollTop });
      } else {
        $('#lightbox_content').css({ position: 'fixed', top: 0.4 * (windowHeight - contentHeight) });
      }
      container.show();
      $('#lightbox_screen').bind('click.lightbox', function(e) {
        $.lightbox.close();
      });
    },
    close: function() {
      $('#lightbox_screen').unbind('.lightboxHide');
      $('#lightbox_screen, #lightbox_container').remove();
    }
  };
  $.fn.lightbox = function() {
    $.lightbox.show(this);
  }
}(jQuery));