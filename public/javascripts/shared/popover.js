(function($) {  
  var settings = {
    padding: 15,
    arrowOffset: 42,
    html: "<div class='popover'><div class='top'></div><div class='middle'><div class='hood'></div><div class='bg_left'></div><div class='bg_right'></div><div class='content'></div><div class='floor'></div></div></div>",
    bottomHeight: 20
  };
  $.extend($, {
    popover: {
      settings: function(options) {
        if (options) {
          settings = $.extend(settings, options);
          return settings;
        } else {
          return settings;
        }
      },
      init: function(title, content) {
        var raw = $($.popover.settings().html),
          body = $(content),
          id = "popover_" + (new Date()).getTime();
        raw.attr('id', id);
        raw.css({left: -9999}).appendTo('body').find('.content').html(body);
        raw.find('.top').append(title);
        body.show();
        raw.find('.middle').css({height: body.outerHeight() + $.popover.settings().bottomHeight});
        raw.hide().css({left: 0});
        return raw;
      },
      bind: function() {
        $('[data-popoverable][data-popover-title]').click(function(e) {
          var trigger = $(this),
            popoverable = $(this).attr('data-popoverable'),
            title = $(this).attr('data-popover-title');
          if ($(title).length > 0) { title = $(title).clone(); }
          if ($(popoverable).length > 0) { popoverable = $(popoverable).clone(); }
          if (popoverable.length > 0) {
            e.preventDefault(); 
            e.stopPropagation();
            $.popover.show(trigger, title, popoverable);
          }
        });
      },
      show: function(trigger, title, content) {
        var popover,
          reposition = function() {
            var offset = trigger.offset(),
              popwidth = popover.outerWidth(),
              width = trigger.outerWidth(),
              windowLeft = $(window).scrollLeft() + $.popover.settings().padding,
              windowRight = windowLeft + $(window).width() - $.popover.settings().padding;
            offset.top = offset.top + trigger.outerHeight() * 0.5;
            popover.removeClass('left_arrow').removeClass('center_arrow').removeClass('right_arrow');
            if (offset.left + width * 0.5 + popwidth * 0.5 > windowRight) {
              popover.addClass('right_arrow');
              offset.left = offset.left + width * 0.5 - popwidth + $.popover.settings().arrowOffset;
            } else if (offset.left + width * 0.5 - popwidth * 0.5 < windowLeft) {
              popover.addClass('left_arrow');
              offset.left = offset.left + width * 0.5 - $.popover.settings().arrowOffset;
            } else {
              popover.addClass('center_arrow');
              offset.left = offset.left + width * 0.5 - popwidth * 0.5;
            }
            popover.offset(offset);
          },
          hide = function() {
            if ($.support.opacity) {
              popover.fadeOut(250, function() {
                popover.remove();
              });              
            } else {
              popover.remove();
            }
          };
        if (content) {
          if ($.support.opacity) { $('.popover').fadeOut(250); }
          else { $('.popover').hide(); }
          popover = $.popover.init(title, content);
          trigger.data('popover-id', popover.attr('id'));
          reposition();
          if ($.support.opacity) { popover.fadeIn(250); }
          else { popover.show(); }
          $(window).unbind('resize.popover').bind('resize.popover', function() { reposition(); });
          $(window).unbind('scroll.popover').bind('scroll.popover', function() { reposition(); });
          $('body').click(function(e) {
            if ($(e.target).is(':not(.inpopover, .inpopover *)')) { hide(); }
          });
          return trigger;
        } else {
          var popid = trigger.data('popover-id');
          return $('#' + popid);
        }
      }
    }
  });
  $.fn.popover = function(title, content) {
    $.popover.show($(this), title, content);
  };  
}(jQuery));