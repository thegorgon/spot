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
      options = {
        start: function() {
          var bd = $('#bd');
          bd.fadeOut(function() {
            bd.trigger('faded');
          })
        }, success: function(data) {
          var html = $(data.html), bd = $("#bd"), body = $('body');
          bd.bind("faded", function() {
            bd.html(html).unbind("faded");
            body.attr("id", data.page.namespace);
            body.attr('class', data.page.controller);
            go.Views.run();
            bd.fadeIn();
          });
          if (!bd.is(":animated")) {
            bd.trigger("faded");            
          }
        }
      }
      $("a.page").ajaxLink(options);
      $("form").ajaxForm(options);
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
      })
    },
    site_previews: function() {
      $('#joke img').live('click', function(e) {
        e.preventDefault();
        var id = parseInt($(this).attr('src').replace(/^.+joke_(\d)+\..+$/, "$1"), 10),
          newId = (id + 1) > go.getVar('max_joke_id') ? 1 : id + 1,
          format = "jpg",
          newFormat = "jpg";
        if (id == 2) {
          format = "gif";
        } else if (newId == 2) {
          newFormat = "gif";
        }
        $(this).attr('src', $(this).attr('src').replace(id + "." + format, newId + "." + newFormat));
      });
    }
  });
}(Spot));