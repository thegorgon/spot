(function(go) {
  $.provide(go, 'Views', {
    run: function(url) {
      var body = $('body'),
        pageNS = body[0].id,
        pageClass = body.attr('class');
      url = url || go.Navigator.current();
      $.logger.debug("Running page views for class: ", pageClass, "and namespace: ", pageNS, " and URL: ", url);
      this.layout.call(this, url);
      go.behave();
      if ($.isFunction(go.Views[pageClass])) {
        go.Views[pageClass].call();
      } 
      if ($.isFunction(go.Views[pageNS])){
        go.Views[pageNS].call();        
      }
    },
    layout: function(url) {
      $('li a[href!=' + url + ']', '#nav').removeClass('current');
      $('li a[href=' + url + ']', '#nav').addClass('current');
      go.Navigator.link($("a.page"));
      go.Navigator.form($("form.page"));
    }
  });
}(Spot));