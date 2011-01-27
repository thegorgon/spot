(function(go) {
  $.provide(go, 'Views', {
    run: function() {
      var body = $('body'),
        pageNS = body[0].id,
        pageClass = body.attr('class');
      $.logger.debug("Running page views for class: ", pageClass, "and namespace: ", pageNS);
      if ($.isFunction(go.Views[pageClass])) {
        go.Views[pageClass].call();
      } 
      if ($.isFunction(go.Views[pageNS])){
        go.Views[pageNS].call();        
      }
    },
    site_previews: function() {
      $('#preview_form').ajaxForm({
        save: function() {
          $(this).find('input,button').blur();
          $('#page .content').hide();
        },
        success: function(data) {
          var $this = $(this), html;
          if (data.errors) {
            $('#page .content').show();
          } else {
            html = $(data.html).popup();
          }
        }
      });
    }
  });
}(Spot));