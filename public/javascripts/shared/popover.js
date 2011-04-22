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
              <div class='cntr'></div> \
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
          raw.addClass('titled').find('.title').html(title)
        } else {
          raw.removeClass('titled');
        }
        $.popover.resize(raw, body)
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
      positionArrow: function(popover, position) {
        var hd = popover.find('.hd'),
            arrow = hd.find('.arr'),
            hdlPad = hd.find('.lpad'),
            hdrPad = hd.find('.rpad'),
            hdlWidth = hd.find('.lft').width(),
            hdrWidth = hd.find('.rt').width(),
            popWidth = popover.width(),
            lpadWidth, rpadWidth;
            
        if (position == 'center') {
          lpadWidth = rpadWidth = 0.5 * (popWidth - hdlWidth - hdrWidth - arrow.width());
        } else if (position == 'left') {
          lpadWidth = 0;
          rpadWidth = (popWidth - hdlWidth - hdrWidth - arrow.width());
        } else if (position == 'right') {
          lpadWidth = (popWidth - hdlWidth - hdrWidth - arrow.width());          
          rpadWidth = 0;
        } else if (position == 'none') {
          lpadWidth = rpadWidth = 0.5 * (popWidth - hdlWidth - hdrWidth);          
          arrow.width(0);
        }
        hdlPad.width(lpadWidth);
        hdrPad.width(rpadWidth);
        arrow.css({left: lpadWidth + hdlWidth, right: rpadWidth + hdrWidth});
      },
      position: function(trigger, popover) {
        var offset = trigger.offset(),
          hdlWidth = popover.find('.hd .lft').width(),
          arrow = popover.find('.arr'),
          popWidth = popover.outerWidth(),
          trigWidth = trigger.outerWidth(),
          windowLeft = $(window).scrollLeft() + $.popover.settings().padding,
          windowRight = windowLeft + $(window).width() - $.popover.settings().padding,
          position = trigger.attr('data-popover-dir');
        
        offset.top = offset.top + trigger.outerHeight() * 0.5;
        
        if (!position) {
          if (offset.left + trigWidth * 0.5 + popWidth * 0.5 > windowRight) {
            position = 'right';
          } else if (offset.left + trigWidth * 0.5 - popWidth * 0.5 < windowLeft) {
            position = 'left';
          } else {
            position = 'center';
          }
        }
                
        if (position == 'right') {
          offset.left = offset.left + trigWidth * 0.5 - popWidth + arrow.width() * 0.5 + hdlWidth;
        } else if (position == 'left') {
          offset.left = offset.left + trigWidth * 0.5 - arrow.width() * 0.5 + hdlWidth;
        } else if (position == 'center') {
          offset.left = offset.left + trigWidth * 0.5 - popWidth * 0.5;
        } else if (position == 'none') {
          offset.left = offset.left + trigWidth * 0.5 - popWidth * 0.5;
          offset.top = offset.top - $.popover.settings().arrowHeight;
        }
        
        $.popover.positionArrow(popover, position);
        
        popover.offset(offset);        
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