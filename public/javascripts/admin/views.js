(function(go) {
  $.provide(go, 'Views', {
    run: function() {
      var body = $('body'),
        pageNS = body[0].id,
        pageClass = body.attr('class');
      $.logger.debug("Running page views for class: ", pageClass, "and namespace: ", pageNS);
      this.layout.call();
      go.behave();
      if ($.isFunction(go.Views[pageClass])) {
        go.Views[pageClass].call();
      } 
      if ($.isFunction(go.Views[pageNS])){
        go.Views[pageNS].call();        
      }
    },
    layout: function() {
      go.Navigator.link($("a.page"));
      go.Navigator.form($("form.page"));
    },
    admin_places: function() {
      var ajaxes = [],
        place;
      $('.image_potential').die('click').live('click', function() {
        $.lightbox.close();
        $.each(ajaxes, function(i) { this.abort(); });
        place.addClass('loading');              
        $(this).parents('form').ajaxSubmit({
          success: function(data) {
            if (data && data.html && data.html.row) {
              place.replaceWith(data.html.row)                
            }
          }
        });
      });
      $('.place_image').die('click').live('click', function(e) {
        place = $(this).parents('.place');
        $.lightbox.loading();
        $.each(['goc', 'gon', 'flrc', 'flrn', 'flrli', 'flrld'], function(i) {
          ajaxes.push($.ajax({
            url: place.attr('data-url') + '/images?source=' + this,
            dataType: 'json',
            success: function(data) {
              var html = $(data.html),
                results = $('.image_search_results'),
                scrollTop;
              if (results.length > 0) {
                scrollTop = results.scrollTop();
                results.append(html.html()).scrollTop(scrollTop);
              } else {
                $.lightbox.show(html);
              }
            }
          }));
        });
      });
    }
  });
}(Spot));