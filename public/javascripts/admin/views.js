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
      go.ImageSelector.init('.place_image', {
        complete: function(data) {
          if (data && data.html && data.html.row) {
            $(this).replaceWith(data.html.row);
          } else {
            $(this).removeClass('loading');
            alert("There was an error with that image. Please try again.");
          }
        }
      });
    }
  });
}(Spot));