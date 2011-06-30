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
      var slideshow = $("#slideshow").slideshow({
          slides: [{ src : '/images/assets/slideshow/slide_00.jpg', 
                     gravity: '1.0x1.0', size: '2292x1524', 
                     title: "Chef's Table Exclusive Seating at Credo" },
                   { src : '/images/assets/slideshow/slide_01.jpg', 
                     gravity: '1.0x1.0', 
                     size: '2292x1524', 
                     title: "Napa Wine Tasting at Foreign Cinema" },
                   { src : '/images/assets/slideshow/slide_02.jpg', 
                     gravity: '1.0x1.0', size: '2292x1524', 
                     title: "Beer and Sausage Pairing at Schmidt's" }],
          start: Math.floor(Math.random()*3),
          version: 0
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
      })
    },
    site_cities_show: function() {
    },
    site_home_press: function() {
      go.AppPreview.init();
    },
    site_events_show: function() {
      go.PaymentDialog.init({ dialog: '#getitnowdialog', trigger: '.getitnow' });
    }
  });
}(Spot));