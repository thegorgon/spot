(function(go) {
  $.provide(go, 'Views', {
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
    },
    admin_businesses_index: function() {
      var bindRow = function(row) {
        $('a.verification', row).ajaxLink({
          start: function() {
            $(this).parents('tr').addClass('loading');
          }, success: function(data) {
            var html = $(data.html);
            bindRow(html);
            $(this).parents('tr').replaceWith(html);
          }
        });
      };
      bindRow();
    },
    admin_deals_index: function() {
      var bind = function() {
        $('.deal form').ajaxForm({
          start: function() {
            $(this).parents('.deal').addClass('loading');
          }, success: function(data) {
            $(this).parents('.deal').removeClass('loading');
            if (data.success) {
              $('#bd').fadeOut(function() { 
                $('#bd').html(data.html).fadeIn(); 
                bind();
              });
            } else {
              $('.manager .message').addClass('error').html(data.message);
            }
          }, error: function() {
            $(this).parents('.deal').removeClass('loading');
            $('.manager .message').addClass('error').html("Something went wrong");
          }
        });
      };
      bind();
    }
  });
}(Spot));