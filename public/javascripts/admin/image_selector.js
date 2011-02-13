(function(go) {
  var ajaxes = [], oncomplete,
    killConnections = function() {
      $.each(ajaxes, function(i) { this.abort(); });
    },
    bindPotentials = function(container) {
      $('.image_potential', container).unbind('click.imageSelector').bind('click.imageSelector', function() {
        var form = $(this).parents('form'),
          place = $('#place_' + form.attr('data-place-id')),
          image = place.find('.place_image');
        $.lightbox.close();
        killConnections();
        image.addClass('loading');
        form.ajaxSubmit({
          success: function(data) {
            image.removeClass('loading');              
            oncomplete.call(image, data);
          }
        });
      });
    };
  $.provide(go, 'ImageSelector', {
    init: function(selector, options) {
      oncomplete = $.isFunction(options.complete) ? options.complete : function() {};
      $(selector).bind('click', function(e) {
        place = $(this).parents('.place'),
          id = place.attr('id').split('_').pop();
        $.lightbox.loading();
        $(window).bind('closeLightbox', function(e) {
          killConnections();
        });
        $.each(['goc', 'gon', 'flrc', 'flrn', 'flrld'], function(i) {
          ajaxes.push($.ajax({
            url: '/admin/places/' + id + '/images?source=' + this,
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
              bindPotentials(results);
            }
          }));
        });
      });
    }
  });
}(Spot));