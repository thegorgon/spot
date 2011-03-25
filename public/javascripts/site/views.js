(function(go) {
  var run = false;
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
      $(document).unbind('konami').bind('konami', function(e) {
        $('.flips').toggleClass('upside_down');
      });
    },
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
    site_previews_index: function() {
      var slideshow = $("#slideshow").slideshow({
        slides: [{ src : '/images/assets/slideshow/slide_00.jpg', gravity: '0x0' },
                 { src : '/images/assets/slideshow/slide_01.jpg', gravity: '0.75x0.75' },
                 { src : '/images/assets/slideshow/slide_02.jpg', gravity: '0.5x1.0' }],
        start: 0,
        version: 2
      });
      $('#nextslide').click(function(e) {  
        e.preventDefault();      
        slideshow.nextSlide();
      });
    },
    site_support_press: function() {
      go.AppPreview.init();
      $('#screenshots img').each(function(i) {
        var img = new Image(), $this = $(this);
        img.onload = function() { $this.fadeIn(); };
        img.src = this.src;
      })
    },
    site_previews_share: function() {
      $('#joke img').bind('click', function(e) {
        e.preventDefault();
        var id = parseInt($(this).attr('src').replace(/^.+joke_(\d)+\..+$/, "$1"), 10),
          newId = (id + 1) > go.getVar('max_joke_id') ? 1 : id + 1,
          format = "jpg",
          newFormat = "jpg";
        if (id === 2) {
          format = "gif";
        } else if (newId === 2) {
          newFormat = "gif";
        }
        $(this).attr('src', $(this).attr('src').replace(id + "." + format, newId + "." + newFormat));
      });
    }
  });
}(Spot));