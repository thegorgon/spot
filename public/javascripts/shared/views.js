(function(go) {
  $.provide(go, 'Views', {
    run: function(url) {
      var body = $('body'),
        pageNS = body[0].id,
        pageClasses = body.attr('class').split(' ');
      url = url || go.Navigator.current();
      $.logger.debug("Running page views for classes: ", pageClasses, "and namespace: ", pageNS, " and URL: ", url);
      this.layout.call(window, url);
      go.Behaviors.train();
      $.each(pageClasses, function(i) {
        if ($.isFunction(go.Views[this])) {
          go.Views[this].call(window, url);
        }
      });
      if ($.isFunction(go.Views[pageNS])){
        go.Views[pageNS].call(window, url);        
      }
    },
    layout: function(url) {
      $(document).unbind('konami').bind('konami', function(e) {
        $('.flips').toggleClass('upside_down');
      });
      $('#flashes .close').click(function(e) {
        var height = $('#flashes').outerHeight();
        $('#flashes .flash').absolutize();
        $('#flashes').slideUp(function() {
          $("#flashes").remove();
        });
      });
    }
  });
}(Spot));