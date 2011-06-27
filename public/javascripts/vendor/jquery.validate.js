(function($) {
  var emailRegex = /\b[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,4}\b/i;
    
  $.validations = (function() {
    var invalid = function(input, message) {
        $(input).parents('li:first').removeClass('valid').removeClass('loading').addClass('invalid');
        $(input).parents('li:first').find('.validity, label').jstooltip(message, 'error');
      },
      valid = function(input) {
        $(input).parents('li:first').removeClass('loading').removeClass('invalid').addClass('valid');
        $(input).parents('li:first').find('.validity').removejstooltip();
      },
      validity = function(input, val, message) {
        if ($(input).valid() || val || $(input).parent('li').is('.loading')) {
          $(input).valid(val);
          return val ? valid(input) : invalid(input, message);        
        }
      },
      spliceInValidation = function(start, deleteCnt, validation) {
        validation = $.extend({
          selector: '*',
          test: function() { $.validations.validity(this, true, ""); },
          onChange: 1,
          onSubmit: 1
        }, validation || {});
        validationNames.splice(start, deleteCnt, validation.name);
        validations.splice(start, deleteCnt, validation);
      },
      validationNames = [],
      validations = [];
    
    return {
      validity: function(input, value, message) {
        validity(input, value, message);
      },
      loading: function(input) {
        $(input).parents('li:first').removeClass('valid').removeClass('invalid').addClass('loading');
        $(input).parents('li:first').find('.validity').jstooltip('checking', 'notice');
        $(input).valid(false);
      },
      describe: function() {
        $.each(validations, function(i) {
          var describe = "Run " + this.name + " validation on inputs matching " + this.selector;
          if (this.onChange) { describe += " on change"; }
          if (this.onSubmit) { describe += " on submit"; }
          $.logger.debug(describe);
        });
      },
      register: function(options) {
        spliceInValidation(validationNames.length, 0, options);
      },
      unregister: function(name) {
        var idx = $.inArray(name, validationNames);
        if (idx >= 0) {
          validationNames.splice(idx, 1);
          validations.splice(idx, 1);
        }
      },
      replace: function(name, options) {
        var idx = $.inArray(name, validationNames);
        if (idx >= 0) {
          spliceInValidation(idx, 1, options);          
        }
      },
      registerBefore: function(name, options) {
        var idx = $.inArray(name, validationNames);
        idx = idx >= 0 ? idx : validationNames.length;
        spliceInValidation(idx, 0, options);
      },
      registerAfter: function(name, options) {
        var idx = $.inArray(name, validationNames);
        idx = idx >= 0 ? idx : 0;
        spliceInValidation(idx + 1, 0, options);
      },
      run: function(element, options) {
        element = $(element);
        options = $.extend({
          submit: false,
          change: false
        }, options || {});

        if (element.is('form')) {
          element.find('input, textarea, select').filter(':not([formnovalidate])').each(function(e) {
            $.validations.run(this, options);
          });
        } else {
          $.validations.validity(element, true);
          $.each(validations, function(i) {
            var validation = this
              runValidation = element.valid() && 
                                element.is(validation.selector) && 
                                (validation.onSubmit || !options.submit) &&
                                (validation.onChange || !options.change);

            if (runValidation) {
              validation.test.call(element);
            }
          });
        }
        return element;        
      }
    };
  }());
  
  // Register Common Validations
  // Register Required Validation
  $.validations.register({
    name: 'required',
    selector: '[required]',
    test: function() {
      var select;
      if ($(this).is('input, textarea')) {
        $.validations.validity(this, $.trim($(this).val()).length > 0, "required");        
      } else if ($(this).is('select')) {
        select = $(this)[0];
         $.validations.validity(this, $.trim(select.options[select.selectedIndex].value), "required");
      }
    }
  });

  // Register Email Validation
  $.validations.register({
    name: 'email',
    selector: '[type=email], [pattern]',
    test: function() {
      $.validations.validity(this, $(this).pattern().test($(this).val()), "that doesn't look like an email address");
    }
  });

  // Register Length Validation
  $.validations.register({
    name: 'length',
    selector: '[minlength], [maxlength]',
    test: function() {
      var length = $.trim($(this).val()).length,
        msg = [$(this).minLength(), "to", $(this).maxLength(), "characters please"].join(' ');
      $.validations.validity(this, length <= $(this).maxLength() && length >= $(this).minLength(), msg);
    }
  });

  // Register Numeric Validation
  $.validations.register({
    name: 'numeric',
    selector: '[min], [max]',
    test: function() {
      var floatVal = $(this).floatVal(),
        msg = ["between", $(this).minValue(), "and", $(this).maxValue()].join(' ');
      $.validations.validity(this, floatVal <= $(this).maxValue() && floatVal >= $(this).minValue(), msg);
    }
  });
    
  // Register Server Validation
  $.validations.register({
    name: 'server',
    onSubmit: false,
    selector: '[data-validate-url]',
    test: function() {
      var url = $(this).attr('data-validate-url'), self = this;
      if ($(self).valid()) {
        $.validations.loading(self);
        $.ajax({
          url: url,
          data: {value: $(self).val()},
          success: function(data) {
            var msg = $(self).attr('data-invalid-msg') || data.message || "something's not right";
            $.validations.validity(self, data.valid, msg);
          },
          dataType: 'json'
        });
      }
    }
  });
  
  $.extend($.fn, {
    clear: function() {
      $(this).filter('form').each(function() {
        var inputs = $(this).find(':input').not(':button, :submit, :reset, [type=hidden], .placeholder');
        inputs.val('').removeAttr('checked').removeAttr('selected').blur(); 
        $(this).find('li').removeClass('valid').removeClass('loading').removeClass('invalid');
      });
      return $(this);
    },
    valid: function(val) {
      if (val !== undefined && val !== null) {
        $(this).attr('aria-invalid', val ? 'false' : 'true');
        return this;
      } else {
        return $(this).is(':not([aria-invalid])') || $(this).attr('aria-invalid') == 'false';
      }
    },
    floatVal: function(val) {
      if (val) {
        $(this).val(val);
        return this;
      } else {
        val = parseFloat($(this).val(), 10);
        return val ? val : 0;
      }
    },
    minValue: function(val) {
      if (val) {
        $(this).attr('min', val);
        return this;
      } else {
        val = parseFloat($(this).attr('min'), 10);
        return val ? val : 0;
      }
    },
    maxValue: function(val) {
      if (val) {
        $(this).attr('max', val);
        return this;
      } else {
        val = parseFloat($(this).attr('max'), 10);
        return val ? val : Infinity;
      }
    },
    minLength: function(val) {
      if (val) {
        $(this).attr('minlength', val);
        return this;
      } else {
        val = parseInt($(this).attr('minlength'), 10);
        return val ? val : 0;
      }
    },
    maxLength: function(val) {
      if (val) {
        $(this).attr('maxlength', val);
        return this;
      } else {
        val = parseInt($(this).attr('maxlength'), 10);
        return val ? val : Infinity;
      }
    },
    pattern: function(regex) {
      if (regex) {
        $(this).attr('pattern', regex.source);
        return this;
      } else if ($(this).filter('[type=email]').length > 0) {
        return emailRegex;
      } else if ($(this).filter('[type=tel]').length > 0) {
        return telRegex;
      } else {
        return new RegExp($(this).attr('pattern'));
      }
    },
    autovalidate: function() {
      $(this).filter('form').each(function(i) {
        var form = $(this);
        
        form.attr('novalidate', 'novalidate');
        
        form.find('input, textarea, select').filter(':not([formnovalidate])').valid(true).bind('change', function(e) {
          $.validations.run(this, {change: true});
        });

        form.bind('submit', function(e) {
          if (!form.data('validity')) {
            e.preventDefault();
            
            if (form.validate({submit: true})) {
              form.data('validity', true);
              form.submit();
              form.data('validity', false);
            }
          }
        });
      });
    },
    validate: function(options) {
      options = options || {};
      var validity = true;
      $(this).filter('form').each(function(i) {
        $.validations.run(this, options);

        validity = validity && $(this).find('input, textarea, select').filter('[aria-invalid=true]').length === 0;
      });
      return validity;
    }
  });  
}(jQuery));