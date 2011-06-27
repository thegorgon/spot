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
        slides: [{ src : '/images/assets/slideshow/slide_00.jpg', gravity: '0.39x0.6', size: '2292x1524' },
                 { src : '/images/assets/slideshow/slide_01.jpg', gravity: '0.51x0.1', size: '2292x1423' },
                 { src : '/images/assets/slideshow/slide_02.jpg', gravity: '0.70x0.75', size: '2292x1298' }],
        start: 0,
        version: 3
      });
    },
    site_home_press: function() {
      go.AppPreview.init();
    },
    site_events_show: function() {
      go.PaymentDialog.init({ dialog: '#getitnowdialog', trigger: '.getitnow' });
    }
  });
}(Spot));