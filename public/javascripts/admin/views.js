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
      $.preload(['/images/buttons/black_button_77x32_active.png', '/images/buttons/black_button_77x32_hover.png', '/images/buttons/black_button_77x32.png']);
      go.Navigator.link($("a.page"));
      go.Navigator.form($("form.page"));
    },
    admin_places: function() {
      go.ImageSelector.init('.place_image');
    },
    admin_search: function() {
      go.SearchEmulator.init();
    },
    admin_duplicates: function() {
      $('.ignore a.ajax').ajaxLink({
        start: function() {
          $(this).parents('.duplicate').slideUp();
        }, success: function(data) {
        }
      });
      $('.resolve').ajaxForm({
        start: function() {
          $(this).parents('.duplicate').slideUp();
        }, success: function(data) {
        }
      });
    },
    admin_places_edit: function() {
      go.PlaceForm.init({mapDiv: $('.map')});
    },
    admin_places_new: function() {
      go.PlaceForm.init({mapDiv: $('.map')});
    }
  });
}(Spot));