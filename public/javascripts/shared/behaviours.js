(function($) {
  $.extend($.fn, {
    placeholder: function(text) {
      $(this).filter('input,textarea').each(function() {
        var $this = $(this);
        text = text || $this.attr('placeholder');
        $this.unbind('.placeholder').removeClass('placeholder').val(text).addClass('placeholder');
        $this.bind('focus.placeholder', function(e) {
          var $this = $(this);
          if ($this.val() == text) {
            $this.val('').removeClass('placeholder');
          }
        });
        $this.bind('blur.placeholder', function(e) {
          var $this = $(this);
          if ($this.val() === '') {
            $this.val(text).addClass('placeholder');
          }      
        });
      });
      return this;      
    },
    selectOnly: function() {
      $(this).live('click', function(e) {
        $(this).focus().select();
      });
    }
  });
}(jQuery));

(function(go) {
  var _vars = {};
  $.extend(go, {
    init: function(vars) {
      $.extend(_vars, vars);
      $.logger.level(_vars.env == 'production' ? 'ERROR' : 'DEBUG');
    },
    behave: function() {
      $('[placeholder]').placeholder();
      $('[data-mode=select]').selectOnly();
    }
  });
}(Spot));