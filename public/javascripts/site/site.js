(function(go) {
  $.provide(go, 'Views', {
    site_blog: function() {
      $('#pagination a').ajaxLink({
        click: function() {
          var posts = $('#posts');
          posts.fadeOut(function() {
            posts.trigger('faded');
          });
        },
        success: function(data) {
          var html = $(data.html).find("#posts"), posts = $('#posts');
          posts.bind("faded", function() {
            posts.html(html.html()).unbind("faded");
            posts.fadeIn(function() {
              go.Views.run();
            });
          });
          if (!posts.is(":animated")) {
            posts.trigger("faded");            
          }
        }
      });
    },
    site_home_index: function() {
      var slideshow = $("#slidedeck").slideshow({
          title: '#slidetitle',
          start: Math.floor(Math.random()* $("#slidedeck").find('.slide').length)
        }), top = $('#toplayer'), scenes = top.find('.scene');
      
      slideshow.start();
      $('.enter').click(function(e) {
        e.preventDefault();
        if (Modernizr.cssTransitions) { top.addClass('scene2'); }
        else { 
          top.addClass('jsanimation');
          scenes.eq(0).animate({left: '-100%'});
          scenes.eq(1).animate({left: '0%'});
          scenes.eq(2).animate({left: '100%'});
        }
        slideshow.stop();
      });
      $('.map .city').click(function(e) {
        if (Modernizr.cssTransitions) { top.addClass('scene3'); }
        else { 
          scenes.eq(0).animate({left: '-200%'});
          scenes.eq(1).animate({left: '-100%'});
          scenes.eq(2).animate({left: '0%'});
        }
      });
    },
    site_cities_show: function() {
      $('#applydialog').removeClass('hidden').dialog({
        title: $('#applydialog').attr('data-title'),
        closeText: '',
        modal: false,
        width: 825,
        autoOpen: false
      });
      $('.btnmembership').click(function(e) {
        $('#applydialog').dialog('open');
        $('input, button').blur();
      });
    },
    site_home_press: function() {
      go.AppPreview.init();
    },
    site_events_show: function() {
      try {
        var canvas = $('canvas#timewedge'),
          context = canvas[0].getContext('2d'),
          startangle = canvas.attr('data-start-hour') * 0.08333 * 2 * Math.PI - Math.PI * 0.5,
          endangle = canvas.attr('data-end-hour')  * 0.08333 * 2 * Math.PI  - Math.PI * 0.5,
          height = canvas.attr('height') * 1.0,
          width = canvas.attr('width') * 1.0,
          center = [0.5 * width, 0.5 * height],
          radius = 73;
        context.beginPath();
        context.moveTo(center[0], center[1]);
        context.strokeStyle = '#808080;'
        context.fillStyle = 'rgba(48,200,48,0.75)';
        context.arc(center[0], center[1], radius, startangle, endangle);
        context.lineTo(center[0], center[1]);
        context.closePath();
        context.stroke();
        context.fill();
      } catch(e) {
      }
      
      $('#applydialog').modal({trigger: '.btnmembership', width: 825});
    }
  });
}(Spot));