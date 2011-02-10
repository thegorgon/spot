(function($) {
  var boxHtml = $("<div id='lightbox_screen'></div><div id='lightbox_container'><div id='lightbox_content'></div></div>"),
    loadingContent = "<div id='lightbox_loading></div>";
  $.lightbox = {
    loading: function() {
      $.lightbox.show(loadingContent);
    },
    show: function(content) {
      content = $(content);
      $('#lightbox_loading').remove();
      if ($('#lightbox_container').length == 0) {
        boxHtml.hide().prependTo('body');
      }
      $('#lightbox_content').html(content);
      boxHtml.show();
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