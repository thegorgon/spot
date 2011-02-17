(function(go) {
  var ajaxes = [], oncomplete,
    killConnections = function() {
      $.each(ajaxes, function(i) { this.abort(); });
    },
    bindCustomForm = function(container) {
      container.find('.custom_form').ajaxForm({
        start: function() {
          $(this).addClass('loading');
        },
        success: function(data) {
          var results = $(data.html).find('.section');
          $(this).removeClass('loading');
          container.find('.section:first').before(results);
          bindPotentials(results);
        }
      })
    },
    bindPotentials = function(container) {
      $('.image_potential', container).unbind('.imageSelector').bind('click.imageSelector', function() {
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
      }).bind('mouseenter.imageSelector', function(e) {
        var img = new Image();
        img.src = $(this).attr('data-url');
        img.height = 150;
        $('.image_search_results .preview').html(img);
      }).bind('mouseleave.imageSelector', function(e) {
        $('.image_search_results .example').html('');
      })
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
                results = $('.image_search_results .sections'),
                section,
                scrollTop;
              if (results.length > 0) {
                section = html.find('.section');
                scrollTop = results.scrollTop();
                results.append(section).scrollTop(scrollTop);
              } else {
                $.lightbox.show(html);
                bindCustomForm(html);
              }
              bindPotentials(results);
            }
          }));
        });
      });
    }
  });
}(Spot));