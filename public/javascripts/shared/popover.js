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
                <div class='bgl'> \
                  <div class='tpad'></div> \
                  <div class='arr'></div> \
                  <div class='bpad'></div> \
                </div> \
                <div class='bgr'> \
                  <div class='tpad'></div> \
                  <div class='arr'></div> \
                  <div class='bpad'></div> \
                </div> \
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
    },
    positionArrow = function(popover, orientation, vertical, horizontal) {
      if (orientation && orientation.charAt(0) == 'v') {
        positionArrowHorizontally(popover, vertical, horizontal);
      } else {
        positionArrowVertically(popover, vertical, horizontal);
      }
    },
    removeArrows = function(popover) {
      popover.find('.hd .arr, .ft .arr').css({width: '0px'});
      popover.find('.bgl .arr, .bgr .arr').css({height: '0px'});
      
      $.each(['top', 'bottom'], function() {
        positionArrow(popover, 'v', this, 'center');
      });
      $.each(['left', 'right'], function() {
        positionArrow(popover, 'h', 'center', this);
      });
    },
    positionArrowHorizontally = function(popover, vertical, horizontal) {
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
    positionHorizontally = function(trigger, popover) {
      popover.css({left: 1000}).show();
      
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
          vertical = 'top'; //
        } else {
          vertical = 'bottom';
        } 
      }
      
      if (vertical == 'bottom') {
        offset.top = offset.top + trigger.outerHeight() * 0.5;
        lWidth = popover.find('.hd .lft').width();
        arrow = popover.find('.hd .arr');
      } else if (vertical == 'top') {
        offset.top = offset.top - popHeight;
        lWidth = popover.find('.ft .lft').width();
        arrow = popover.find('.ft .arr');
      }
      
      removeArrows(popover);
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

      positionArrow(popover, 'v', vertical, horizontal);

      popover.css(offset);
    },
    positionArrowVertically = function(popover, vertical, horizontal) {
      var container = popover.find(horizontal == 'left' ? '.bgr' : '.bgl'),
          arrow = container.find('.arr'),
          tPad = container.find('.tpad'),
          bPad = container.find('.bpad'),
          popHeight = popover.height(),
          hdHeight = popover.find('.hd').outerHeight(),
          ftHeight = popover.find('.ft').outerHeight(),
          cHeight, tpadHeight, bpadHeight;
      
      cHeight = container.height();
      
      if (vertical == 'center') { // Arrow centered vertically on left or right side
        tpadHeight = Math.round(0.5 * (cHeight - arrow.height()));
        bpadHeight = cHeight - tpadHeight - arrow.height();
      } else if (vertical == 'bottom') { // Arrow at top on left or right side
        tpadHeight = 0;
        bpadHeight = (cHeight - arrow.height());
      } else if (vertical == 'top') { // Arrow on bottom on left or right side
        tpadHeight = (cHeight - arrow.height());
        bpadHeight = 0;
      }
      
      tPad.height(tpadHeight);
      bPad.height(bpadHeight);
      arrow.css({top: tpadHeight, bottom: bpadHeight});
    },
    positionVertically = function(trigger, popover) {
      popover.css({left: 1000}).show();
      
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
        hdHeight = popover.find('.hd').outerHeight(),
        ftHeight = popover.find('.ft').outerHeight(),
        vertical, horizontal, arrow;

      if (positions) {
        positions = positions.split(',');
        horizontal = $.trim(positions[0]);
        vertical = $.trim(positions[1]);
      }
      
      if (!horizontal) { // Auto determine left or right side
        if (offset.left + trigWidth + popWidth > windowRight) {
          horizontal = 'left'; // Popover on left side
        } else {
          horizontal = 'right'; // Popover on right side
        }
      }

      
      if (horizontal == 'left') { // Put the popover to the left of the trigger
        arrow = popover.find('.bgr .arr'); // implies arrow on right
        offset.left = offset.left - popWidth + arrow.width() * 0.5;
      } else if (horizontal == 'right') { // Put the popover to the right of the trigger
        arrow = popover.find('.bgl .arr'); // implies arrow on left
        offset.left = offset.left + trigWidth - arrow.width() * 0.5;
      }

      removeArrows(popover);
      arrow.css({height: arrow.css('max-height')});

      if (!vertical) {
        if (offset.top - popHeight * 0.5 < windowTop) {
          vertical = 'bottom'; // Popover below, arrow goes on the top
        } else if (offset.top + popHeight * 0.5 > windowBottom) {
          vertical = 'top'; // Popover on top, arrow goes on the bottom
        } else {
          vertical = 'center'; // Popover centered, arrow goes in the middle
        }
      }
      
      if (vertical == 'bottom') { // Put popover below trigger
        offset.top = offset.top - popover.find('.hd').height() + (trigHeight - arrow.height()) * 0.5;
      } else if (vertical == 'top') { // Put popover above trigger
        offset.top = offset.top - popHeight + ftHeight + arrow.height() * 0.5 + trigHeight * 0.5;
      } else if (vertical == 'center') { // Put popover in the middle of trigger
        offset.top = offset.top - 0.5 * (popHeight - popover.find('.hd').height());
      }

      positionArrow(popover, 'h', vertical, horizontal);
      popover.css(offset);
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
      visible: function(trigger, popover) {
        $(trigger).hasClass("active");
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
            trigger.unbind('.popovershow').bind('click.popovershow touchstart.popovershow', function(e) {
              e.preventDefault();
              e.stopPropagation();
              if ($.popover.visible(trigger, popover)) {
                $.popover.hide(trigger, popover);
              } else {
                $.popover.reveal(trigger, popover);
              }
            });
          }
        });
      },
      reveal: function(trigger, popover, options) {
        $.popover.hide();
        $.popover.settings().beforeShow.call(popover);
        $.popover.position(trigger, popover, options);
        if ($.support.opacity) { popover.fadeIn(250); }
        else { popover.show(); }
        trigger.addClass('active');
        $(window).unbind('resize.popover').bind('resize.popover', function() { $.popover.position(trigger, popover); });
        $(window).unbind('scroll.popover').bind('scroll.popover', function() { $.popover.position(trigger, popover); });
        setTimeout(function() { // Otherwise this event might count
          $('body').unbind('.hidepopover').bind('click.hidepopover touchstart.hidepopover', function(e) {
            if ($(e.target).is(':not(.popover, .popover *)')) { $.popover.hide(); }
          });
        }, 1);
        popover.find('a:not(.inpopover)').unbind('click.popover').bind('click.popover', function(e) { $.popover.hide(trigger, popover); });
        popover.find('form.page').unbind('submit.popover').bind('submit.popover', function(e) { $.popover.hide(trigger, popover); });
      },
      hide: function(trigger, popover, options) {
        trigger = trigger || $('[data-popover]');
        popover = popover || $('.popover:not(.permanent)');
        trigger.removeClass('active');
        options = options || {};
        $('body').unbind('click.hidepopover');
        $(window).unbind('resize.popover').unbind('scroll.popover');
        if (!$.isFunction(options.complete)) { options.complete = function() {}; }
        if ($.support.opacity) {
          popover.fadeOut(250, function() {
            $(window).trigger('popoverhide');
            options.complete.call(popover);
          });
        } else {
          popover.hide();
          $(window).trigger('popoverhide');
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
      position: function(trigger, popover, options) {
        options = options || {}
        var orientation = options.orient || trigger.attr('data-popover-orient');
        if (orientation && orientation.charAt(0) == 'v') {
          positionHorizontally(trigger, popover);
        } else {
          positionVertically(trigger, popover);
        }
      }
    }
  });
  $.fn.popover = function(title, content) {
    return $.popover.show($(this), title, content);
  };  
}(jQuery));