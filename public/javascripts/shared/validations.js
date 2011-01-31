(function($) {
  var REGEX = {
    email: /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i,
    number: /^\d*$/
  }, formatValidity = function(input) {
    var regex = REGEX[input.attr('type')],
    if (regex && input.val().length > 0 && !regex.test(input.val()) {
      input.addError('format');
      return false;
    }
    return true;
  }, presenceValidity = function(input) {
    if (input.hasAttr('required') && input.val().length == 0) {
      input.addError('presence');
      return false;
    }
    return true;
  }, lengthValidity = function(input) {
    if (input.hasAttr('maxlength') && input.val().length > parseInt(input.attr('maxlength'), 10)) {
      input.addError('over-length');
      return false;
    } else if (input.hasAttr('minlength') && input.val().length < parseInt(input.attr('minlength'), 10)) {
      input.addError('under-length');
      return false;
    }
    return true;    
  }, rangeValidity = function(input) {
    if (input.hasAttr('max') && parseInt(input.val(), 10) > parseInt(input.attr('max'), 10)) {
      input.addError('over-range');
      return false;
    } else if 
  }
  
  $.extend($.fn,
    validity: function() {
      var valid = true;
      $(this).filter('form, input, textarea').each(function() {
        var $this = $(this);
        if ($this.is('form')) {          
          return valid && $this.find('input, textarea').validity();
        } else {
          return formatValidity($this) && presenceValidity($this) && lengthValidity($this);
        }
      });
    },
    addError: function(type) {
      errors = $(this).data('validation-errors');
      errors = errors || [];
      errors.push(type);
      $(this).data('validation-errors', errors);
    }
  });
}(jQuery));