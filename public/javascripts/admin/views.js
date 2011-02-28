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
          // var html = $(data.html);
          // $(this).parents('.duplicate').replaceWith(html.hide())
          // html.slideDown();
        }
      });
      $('.resolve').ajaxForm({
        start: function() {
          $(this).parents('.duplicate').slideUp();
        }, success: function(data) {
          // var html = $(data.html);
          // $(this).parents('.duplicate').replaceWith(html.hide())
          // html.slideDown();
        }
      })
    },
    admin_places_index: function() {
      $('.search_link').toggle(function(e) {
        $('#search_form_wrapper').hide().removeClass('hidden').slideDown();
      }, function() {
        $('#search_form_wrapper').slideUp();
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