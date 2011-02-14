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
          if (data) {
            $(this).attr('src', data.image_url_640x400);
          } else {
            alert("There was an error with that image. Please try again.");
          }
        }
      });
    },
    admin_search: function() {
      $('#search_form').ajaxForm({
        start: function() {
          $(this).addClass('loading');
        }, success: function(data) {
          $(this).removeClass('loading');
          $('.table').html(data.html);
          go.ImageSelector.init('.place_image', {
            complete: function(data) {
              if (data) {
                $(this).attr('src', data.image_url_640x400);
              } else {
                alert("There was an error with that image. Please try again.");
              }
            }
          });
        }
      });
      $('.location').click(function(e) {
        e.preventDefault();
        $('#search_ll').val($(this).attr('data-ll'));
      })
      $('.geolocate').click(function(e) {
        var lnk = $(this);
        e.preventDefault();
        lnk.addClass('loading');
        $.geolocate({
          success: function(position) {
            var ll = position.coords.latitude + "," + position.coords.longitude;
            $('#search_ll').val(ll);
            lnk.removeClass('loading');
          }
        });
      });
    },
    admin_places_index: function() {
      $('.search_link').toggle(function(e) {
        $('#search_form').hide().removeClass('hidden').slideDown();
      }, function() {
        $('#search_form').slideUp();        
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