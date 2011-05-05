(function($) {  
  var settings = {
      padding: 15,
      arrowHeight: 10,
      appendTo: 'body',
      html: "<div class='popover'> \
              <div class='hd'> \
                <div class='title'></div> \
                <div class='lft'></div> \
                <div class='pad lpad'></div> \
                <div class='arr'></div> \
                <div class='pad rpad'></div> \
                <div class='rt'></div> \
              </div> \
              <div class='bd'> \
                <div class='bgl'></div> \
                <div class='bgr'></div> \
                <div class='content'></div> \
              </div> \
              <div class='ft'> \
                <div class='lft'></div> \
                <div class='pad lpad'></div> \
                <div class='arr'></div> \
                <div class='pad rpad'></div> \
                <div class='rt'></div> \
              </div> \
            </div>",
      beforeShow: function() {}
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
        raw.css({position: 'absolute', left: -9999, zIndex: 10000}).appendTo($.popover.settings().appendTo).find('.content').html(body);
        body.show();
        if (title && title.length > 0) {
          raw.addClass('titled').find('.title').html(title);
        } else {
          raw.removeClass('titled');
        }
        $.popover.resize(raw, body);
        raw.hide().css({left: 0});
        return raw;
      },
      bind: function(container) {
        $('[data-popover]').each(function(e) {
          var trigger = $(this),
            popoverable = trigger.attr('data-popover'),
            title = trigger.attr('data-popover-title'),
            popover;
          if ($(title).length > 0) { title = $(title); }
          if ($(popoverable).length > 0) { popoverable = $(popoverable); }
          if (popoverable.length > 0) {
            if (popoverable.removeClass) { popoverable.removeClass('hidden'); }
            popover = $.popover.init(title, popoverable);
            trigger.attr('data-popover-id', popover.attr('id'));
            trigger.bind('click', function(e) {
              e.preventDefault();
              e.stopPropagation();
              $.popover.reveal(trigger, popover);
            });
          }
        });
      },
      reveal: function(trigger, popover) {
        $.popover.hide();
        $.popover.settings().beforeShow.call(popover);
        $.popover.position(trigger, popover);
        if ($.support.opacity) { popover.fadeIn(250); }
        else { popover.show(); }
        trigger.addClass('active');
        $(window).unbind('resize.popover').bind('resize.popover', function() { $.popover.position(trigger, popover); });
        $(window).unbind('scroll.popover').bind('scroll.popover', function() { $.popover.position(trigger, popover); });
        $('body').click(function(e) {
          if ($(e.target).is(':not(.popover, .popover *)')) { $.popover.hide(trigger, popover); }
        });
        popover.find('a').unbind('click.popover').bind('click.popover', function(e) { $.popover.hide(trigger, popover); });
        popover.find('form').unbind('submit.popover').bind('submit.popover', function(e) { $.popover.hide(trigger, popover); });
      },
      hide: function(trigger, popover, options) {
        trigger = trigger || $('[data-popover]');
        popover = popover || $('.popover');
        trigger.removeClass('active');
        options = options || {};
        if (!$.isFunction(options.complete)) { options.complete = function() {}; }
        if ($.support.opacity) {
          popover.fadeOut(250, function() {
            options.complete.call(popover);
          });
        } else {
          popover.hide();
          options.complete.call(popover);
        }        
      },
      remove: function(trigger, popover) {
        $.popover.hide(trigger, popover, {
          complete: function() {
            $(this).remove();
          }
        });
      },
      resize: function(popover, content, options) {
        var ft = popover.find('.ft'),
            hd = popover.find('.hd'),
            hdlWidth = hd.find('.lft').width(),
            hdrWidth = hd.find('.rt').width(),
            arrow = hd.find('.arr'),
            contentPos = popover.find('.content').position(),
            popWidth = Math.max(arrow.width() + hdlWidth + hdrWidth, content.outerWidth() + 2.0 * contentPos.left),
            popHeight = content.outerHeight() + hd.height() + ft.height();
        options = options || {};
        if (options.animate || options.animateT > 0) {
          popover.animate({height: popHeight, width: popWidth}, options.animateT || 250);
        } else {
          popover.height(popHeight);
          popover.width(popWidth);
        }
      },
      removeArrows: function(popover) {
        popover.find('.arr').css({width: '0px'});
        $.each(['top', 'center', 'bottom'], function() {
          $.popover.positionArrow(popover, this, 'center');
        });
      },
      positionArrow: function(popover, vertical, horizontal) {
        var container = popover.find(vertical == 'bottom' ? '.hd' : '.ft'),
            arrow = container.find('.arr'),
            lPad = container.find('.lpad'),
            rPad = container.find('.rpad'),
            lWidth = container.find('.lft').width(),
            rWidth = container.find('.rt').width(),
            popWidth = popover.width(),
            lpadWidth, rpadWidth;
        
        if (horizontal == 'center') {
          lpadWidth = rpadWidth = 0.5 * (popWidth - lWidth - rWidth - arrow.width());
        } else if (horizontal == 'right') {
          lpadWidth = 0;
          rpadWidth = (popWidth - lWidth - rWidth - arrow.width());
        } else if (horizontal == 'left') {
          lpadWidth = (popWidth - lWidth - rWidth - arrow.width());          
          rpadWidth = 0;
        }
        
        lPad.width(lpadWidth);
        rPad.width(rpadWidth);
        arrow.css({left: lpadWidth + lWidth, right: rpadWidth + rWidth});
      },
      position: function(trigger, popover) {
        var offset = trigger.offset(),
          popHeight = popover.outerHeight(),
          popWidth = popover.outerWidth(),
          trigWidth = trigger.outerWidth(),
          trigHeight = trigger.outerHeight(),
          windowTop = $(window).scrollTop() + $.popover.settings().padding,
          windowBottom = windowTop + $(window).height() - $.popover.settings().padding,
          windowLeft = $(window).scrollLeft() + $.popover.settings().padding,
          windowRight = windowLeft + $(window).width() - $.popover.settings().padding,
          positions = trigger.attr('data-popover-pos'), 
          vertical, horizontal, lWidth, arrow;

        if (positions) {
          positions = positions.split(',');
          horizontal = $.trim(positions[0]);
          vertical = $.trim(positions[1]);
        }

        if (!vertical) {
          if (offset.top + trigHeight * 0.5 + popHeight * 0.5 > windowBottom) {
            vertical = 'top';
          } else {//if (offset.top + trigHeight * 0.5 - popHeight * 0.5 < windowTop) {
            vertical = 'bottom';
          } 
          // else {
          //   vertical = 'center';
          // }
        }
        
        if (vertical == 'bottom') {
          offset.top = offset.top + trigger.outerHeight() * 0.5;
          lWidth = popover.find('.hd .lft').width();
          arrow = popover.find('.hd .arr');
        } else if (vertical == 'top') {
          offset.top = offset.top - trigger.outerHeight() * 0.5 - popHeight;
          lWidth = popover.find('.ft .lft').width();
          arrow = popover.find('.ft .arr');
        } else if (vertical == 'center') {
          offset.top = offset.top - trigger.outerHeight() * 0.5 - popHeight;
        }
        
        $.popover.removeArrows(popover);
        arrow.css({width: arrow.css('max-width')});

        if (!horizontal) {
          if (offset.left + trigWidth * 0.5 + popWidth * 0.5 > windowRight) {
            horizontal = 'left';
          } else if (offset.left + trigWidth * 0.5 - popWidth * 0.5 < windowLeft) {
            horizontal = 'right';
          } else {
            horizontal = 'center';
          }
        }

        if (horizontal == 'left') {
          offset.left = offset.left + trigWidth * 0.5 - popWidth + arrow.width() * 0.5 + lWidth;
        } else if (horizontal == 'right') {
          offset.left = offset.left + trigWidth * 0.5 - arrow.width() * 0.5 - lWidth;
        } else if (horizontal == 'center') {
          offset.left = offset.left + trigWidth * 0.5 - popWidth * 0.5;
        }

        $.popover.positionArrow(popover, vertical, horizontal);

        popover.css(offset);
      },
      show: function(trigger, title, content) {
        var popid = trigger.data('popover-id'),
          popover = $('#' + popid);
        
        if (title && content) { 
          popover = $.popover.init(title, content); 
          trigger.attr('data-popover-id', popover.attr('id'));
        }
        
        if (popover.length > 0) {
          $.popover.reveal(trigger, popover);
          return popover;
        } else {
          return null;
        }
      }
    }
  });
  $.fn.popover = function(title, content) {
    return $.popover.show($(this), title, content);
  };  
}(jQuery));