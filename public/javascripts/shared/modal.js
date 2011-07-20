(function($) {
  $.modal = {
    loading: function() {
      $.modal.open('<div class="loading"></div>');
    },
    open: function(element, options) {
      options = options || {};
      var dialog = $(element);
      dialog.dialog("open");
    },
    close: function(element, options) {
      options = options || {};
      var dialog = $(element);
      dialog.dialog("close");      
    },
    init: function(element, options) {
      options = options || {};
      var dialog = $(element),
        position = options.position || ["center", "center"],
        onopen = options.open,
        onclose = options.close;
      options = $.extend({
        modal: false, 
        closeText: '',
        title: dialog.attr('data-title'),
        position: position,
        autoOpen: false
      }, options);
      options.close = function(event, ui) {
        $(window).unbind("resize.dialog");
        $(window).unbind("scroll.dialog");
        $('body').find('.ui-widget-overlay').remove();
        if ($.isFunction(onclose)) { onclose.call(dialog); }
      };
      options.open = function(event, ui) {
        var overlay = $('body').find('.ui-widget-overlay'),
          positionOverlay = function() {
            overlay.css({width: $(window).width(), height: $(window).height(), zIndex: 1000});
          };
        overlay = overlay.length > 0 ? overlay : $('<div></div>').addClass('ui-widget-overlay').appendTo('body');
        positionOverlay();
        $(window).bind("resize.dialog", function() { 
          dialog.dialog("option", "position", position);
          positionOverlay();
        });
        $(window).bind("scroll.dialog", function() { 
          dialog.dialog("option", "position", position);
          positionOverlay();
        });
        $('input, button, select, textarea').blur();
        if ($.isFunction(onopen)) { onopen.call(dialog); }
      };
      
      dialog.removeClass('hidden').dialog(options);
    }
  };
  $.fn.modal = function(options) {
    var self = this;
    $.modal.init(self, options);
    
    if (options.trigger) {
      $(options.trigger).unbind('click.modal-trigger').bind('click.modal-trigger', function(e) {
        e.preventDefault();
        $.modal.open(self);
      });
    }
    if (options.action == "open") {
      $.modal.open(self);
    } else if (options.action == "close") {
      $.modal.close(self);      
    }
  };
}(jQuery));