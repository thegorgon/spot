(function($) {
  var preloadable = [ "/images/assets/general/white_check.png", 
                      "/images/assets/general/white_cross.png", 
                      "/images/assets/general/black_check.png", 
                      "/images/assets/general/black_cross.png", 
                      "/images/assets/loading/white-chasing30x30.gif" ],
    emailRegex = /\b[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,4}\b/i,
    invalid = function(input, message) {
      $(input).parent('li').removeClass('valid').removeClass('loading').addClass('invalid');
      $(input).parent('li').find('.validity .message').html(message || '');
    },
    loading = function(input) {
      $(input).parent('li').removeClass('valid').removeClass('invalid').addClass('loading');
      $(input).parent('li').find('.validity .message').html('checking');
      $(input).valid(false);
    },
    valid = function(input) {
      $(input).parent('li').removeClass('loading').removeClass('invalid').addClass('valid');
      $(input).parent('li').find('.validity .message').html('');
    },
    validity = function(input, val, message) {
      if ($(input).valid() || val || $(input).parent('li').is('.loading')) {
        $(input).valid(val);
        return val ? valid(input) : invalid(input, message);        
      }
    },
    testRequired = function(input) {
      validity(input, $(input).val().replace(/^\s+|\s+$/g, '').length > 0, "required");
    },
    testPattern = function(input) {
      validity(input, $(input).pattern().test($(input).val()), "doesn't look right");
    },
    testValue = function(input) {
      var floatVal = $(input).floatVal(),
        msg = ["between", $(input).minValue(), "and", $(input).maxValue()].join(' ');
      validity(input, floatVal >= $(input).maxValue() && floatVal <= $(input).minValue(), msg);
    },
    testLength = function(input) {
      var length = $(input).val().replace(/^\s+|\s+$/g, '').length,
        msg = [$(input).minLength(), "to", $(input).maxLength(), "characters"].join(' ');
      validity(input, length <= $(input).maxLength() && length >= $(input).minLength(), msg);
    },
    testAgainstServer = function(input) {
      var url = $(input).attr('data-validate-url');
      if ($(input).valid()) {
        loading(input);
        $.ajax({
          url: url,
          data: {value: $(input).val()},
          success: function(data) {
            var msg = $(input).attr('data-invalid-msg') || data.message;
            validity(input, data.valid, msg);
          },
          dataType: 'json'
        });
      }
    }, preload = function() {
      var img, src;
      while (preloadable.length > 0) {
        src = preloadable.pop();
        img = new Image();
        img.src = src;
      }
    };
  $.extend($.fn, {
    clear: function() {
      $(this).filter('ul.form').each(function() {
        $(this).find('input.text').not('.placeholder').val('').blur().valid(true);
        $(this).find('li').removeClass('invalid').removeClass('focus').removeClass('valid');
      });
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
      } else {
        return new RegExp($(this).attr('pattern'));
      }
    },
    validate: function() {
      preload();
      $(this).filter('form').each(function(i) {
        var form = $(this),
          required = form.find('input[required]:not([formnovalidate])'),
          patterned = form.find('input[type=email]:not([formnovalidate]), input[pattern]:not([formnovalidate])'),
          value = form.find('input[type=number][min]:not([formnovalidate]), input[type=number][max]:not([formnovalidate]):not([min])'),
          length = form.find('input[minlength]:not([formnovalidate]), input[maxlength]:not([formnovalidate]):not([minlength])'),
          server = form.find('input[data-validate-url]:not([formnovalidate])');

        form.attr('novalidate', 'novalidate');
        form.find('input').valid(true);

        required.bind('change', function() { testRequired(this); });
        patterned.bind('change', function() { testPattern(this); });
        value.bind('change', function() { testValue(this); });
        length.bind('change', function() { testLength(this); });
        server.bind('change', function() { testAgainstServer(this); });

        form.bind('submit', function(e) {
          if (!form.data('validity')) {
            e.preventDefault();
            required.each(function(i) { testRequired(this); });
            patterned.each(function(i) { testPattern(this); });
            value.each(function(i) { testValue(this); });
            length.each(function(i) { testLength(this); });

            if (form.find('input[aria-invalid=true]').length === 0) {
              form.data('validity', true);
              form.submit();
              form.data('validity', false);
            }
          }
        });
      });
    }
  });
}(jQuery));