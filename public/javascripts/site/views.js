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
      $('#joke img').live('click', function(e) {
        e.preventDefault();
        var id = parseInt($(this).attr('src').replace(/^.+joke_(\d)+\..+$/, "$1"), 10),
          newId = (id + 1) > go.getVar('max_joke_id') ? 1 : id + 1,
          format = "jpg",
          newFormat = "jpg";
        if (id == 2) {
          format = "gif";
        } else if (newId == 2) {
          newFormat = "gif";
        }
        $(this).attr('src', $(this).attr('src').replace(id + "." + format, newId + "." + newFormat));
      });
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