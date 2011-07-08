(function($) {
  $.modal = {
    loading: function() {
      $.modal.show('<div class="loading"></div>');
    },
    show: function(element, options) {
      options = options || {};
      var dialog = $(element);
      $.modal.init(dialog, options);
      dialog.dialog("open");
    },
    init: function(element, options) {
      options = options || {};
      var dialog = $(element),
        position = options.position || ["center", 200];
      
      options = $.extend({
        modal: false, 
        closeText: '',
        width: 800,
        title: dialog.attr('data-title'),
        position: position,
        autoOpen: false,
        close: function(event, ui) {
          $(window).unbind("resize.dialog");
          $(window).unbind("scroll.dialog");
          $('body').find('.ui-widget-overlay').remove();
          if ($.isFunction(options.onClose)) { options.onClose.call(dialog); }
        },
        open: function(event, ui) {
          var overlay = $('body').find('.ui-widget-overlay');
          overlay = overlay.length > 0 ? overlay : $('<div></div>').addClass('ui-widget-overlay').appendTo('body');
          overlay.css({width: $(window).width(), height: $(window).height(), zIndex: 1000});
          $(window).bind("resize.dialog", function() { 
            dialog.dialog("option", "position", position);
          });
          $(window).bind("scroll.dialog", function() { 
            dialog.dialog("option", "position", position);
          });
          $('input, button, select, textarea').blur();
          if ($.isFunction(options.onClose)) { options.onOpen.call(dialog); }
        }
      }, options);
      dialog.removeClass('hidden').dialog(options);
    }
  };
  $.fn.modal = function(options) {
    var self = this;
    $.modal.init(self, options);
    
    if (options.trigger) {
      $(options.trigger).unbind('click.modal-trigger').bind('click.modal-trigger', function(e) {
        e.preventDefault();
        $.modal.show(self);
      });
    }
  };
}(jQuery));