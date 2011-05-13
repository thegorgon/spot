(function($){
  var bind = function(container) {
    $('[data-jstooltip]', container).each(function(i) {
      $(this).jstooltip($(this).attr('data-jstooltip'), $(this).attr('data-jstooltip-class'));
    })
  }
  $.extend($, {
    jstooltip: {
      init: function() {
        var tt = $('<div></div>').attr('id', 'jsTooltip').hide().appendTo('body');
        $(window).unbind('mousemove.tooltip').bind('mousemove.tooltip', function(e) {
          tt.css({left:e.pageX + 10, top: e.pageY + 10});
        });
        bind();
      }, 
      show: function(msg, klass) {
        $('#jsTooltip').removeAttr('class').addClass(klass).html(msg).show();
      }, 
      hide: function() {
        $('#jsTooltip').removeAttr('class').html('').hide();
      },
      bind: function(container) {
        bind(container);
      }
    }
  });
  $.extend($.fn, {
    jstooltip: function(msg, klass) {
      $(this).removejstooltip().bind('mouseenter.tooltip', function(e) {
        $.jstooltip.show(msg, klass);
      }).bind('mouseleave.tooltip', function(e) {
        $.jstooltip.hide();
      });
    }, 
    removejstooltip: function() {
      return $(this).unbind('mouseenter.tooltip, mouseleave.tooltip');
    }
  }); 
}(jQuery));