(function($) {
  $.extend($.fn, {
    ccType: function() {
      var ccnumber = $(this).val(),
        type = undefined, 
        firsttwo = parseInt(ccnumber.slice(0, 2), 10),
        iin = parseInt(ccnumber.slice(0, 6), 10), 
        halfiin = parseInt(ccnumber.slice(0, 3), 10);
      if (ccnumber[0] == '4') {
        type = 'visa';
      } else if (ccnumber.slice(0, 4) == '6011' || firsttwo == 65 || (halfiin >= 644 && halfiin <= 649) || (iin >= 622126 && iin <= 622925)) {
        type = 'discover';
      } else if (firsttwo >= 51 && firsttwo <= 55) {
        type = 'mastercard';
      } else if (firsttwo == 34 || firsttwo == 37) {
        type = 'amex';
      }
      return type;
    }
  });
  
  // Register Luhn Validation
  $.validations.registerAfter('length', {
    name: 'luhn',
    selector: '[data-subtype=creditcard]',
    test: function() {
      var sum = 0, flip = true, i, digit, value = $(this).val();
      for (i = value.length - 1; i >=0; i--) {
        digit = parseInt(value.charAt(i), 10);
        sum += (flip = flip ^ true) ? Math.floor((digit * 2)/10) + Math.floor(digit * 2 % 10) : digit;
      }
      $.validations.validity(this, sum % 10 === 0, "take a second look?");
    }
  });

  $.validations.registerAfter('luhn', {
    name: 'cctype',
    selector: '[data-subtype=creditcard]',
    test: function() {
      $.validations.validity(this, !!$(this).ccType(), "sorry, we can't accept that type of credit card");
    }
  });  

  $.validations.registerAfter('length', {
    name: 'cvvlength',
    selector: '[data-subtype=cvv]',
    test: function() {
      var length = $(this).val().length,
        type = $(this).parents('form').find('[data-subtype=creditcard]').ccType(),
        validity = (!type && length == 3 || length == 4) || ((type == 'amex' && length == 4) || (length == 3 && type != 'amex')), msg;
        if (type == 'amex') {
          msg = 'should be a 4-digit code printed on the front side of the card';
        } else if (type === undefined) {
          msg = 'should be a 3 or 4-digit code printed on the card';
        } else {
          msg = 'should be a 3 digit code printed on the back of the card';
        }
      $.validations.validity(this, validity, msg);
    }
  });
  
  $.validations.registerAfter('length', {
    name: 'ccexpiration',
    selector: '[data-subtype=ccexpiration]',
    onChange: false,
    test: function() {
      var yearField, monthField, year, month, validity;
      if ($(this).attr('data-part') == 'month') {
        yearField = $(this).siblings('[data-part=year][data-subtype=ccexpiration]');
        monthField = $(this)
      } else if ($(this).attr('data-part') == 'year') {
        monthField = $(this).siblings('[data-part=month][data-subtype=ccexpiration]');
        yearField = $(this)        
      }
      year = parseInt(yearField.val(), 10);
      month = parseInt(monthField.val(), 10);
      validity = year > Date.now().getFullYear() || (year == Date.now().getFullYear() && month > Date.now().getMonth() + 1);
      $.validations.validity(monthField, validity, "is your card expired?")
    }
  });
  
}(jQuery));

(function(go) {
  var viewStack = [],
    uiDialog,
    form = null,
    promoCodeTO = null,
    developmentCC = function() {
      if (go.env('env') != 'production') {
        var devCards = [4111111111111111, 4005519200000004, 4009348888881881, 4012000033330026, 4012000077777777, 4012888888881881, 4217651111111119, 4500600000000061, 5555555555554444, 378282246310005, 371449635398431, 6011111111111117];        
        form.find('.ccnumber').val($.rand(devCards)).focus().keyup().blur().change();
        $('.expmonth').val('05').change();
        $('.expyear').val(Date.now().getFullYear() + 3).change();
        $('.cvv').val('364').focus().blur().change();
      }
    },
    clearInput = function(input) {
      input.val(''); 
      input.data('lastsent', '');
      input.blur();
    },
    setPromoCode = function(input, data) {
      if (data) {
        var html = $('#promodescribe').tmpl(data.code);
        if (data.code && data.code.available) {
          input.blur();
          input.parents('li:first').removeClass('loading').removeClass('invalid').addClass('valid');
          if (data.code.acts_as_payment) {
            html.hide().insertAfter(form).slideDown();
            form.slideUp();
            html.find('.close').bind('click.removecode', function(e) {
              e.preventDefault();
              form.slideDown();
              clearInput(input);
              html.slideUp(function() {
                html.remove();
              });
            });
          } else {
            $('#promocodefields').slideUp();
            $('#promocodefields').after(html.hide());
            html.slideDown();
            html.find('.close').bind('click.removecode', function(e) {
              e.preventDefault();
              clearInput(input);
              $('#promocodefields').slideDown();
              html.slideUp(function() {
                html.remove();
              });
            });
          }
          $('.promo_congrats').slideUp();
          form.removeClass('loading');
        } else {
          input.parents('li:first').removeClass('loading').removeClass('valid').addClass('invalid');
        }        
      }
    },
    updatePromoCode = function(input, promoCode) {
      input = $(input);
      if (input.data('lastsent') != input.val()) {
        input.data('lastsent', input.val());
        if (input.val().toString().length > 0) {
          input.parents('li:first').removeClass('valid').removeClass('invalid').addClass('loading');
          $.get('/codes/promo/' + input.val(), function(data) {
            setPromoCode(input, data);
          });
        }
      }
    },
    bind = function() {
      var planId = $('#customer_custom_fields_subscription_plan_id'),
        promocode = form.find('#customer_custom_fields_promo_code'),
        options = $('.paymentoptions'),
        selectOption = function(option) {
          if (option.length > 0) {
            options.find('.paymentoption').removeClass('selected');
            options.addClass('selected');
            option.addClass('selected');
            planId.val(option.attr('data-value'));
            planId.change();
          }
        };
      $('#apply_code_btn').unbind('click').bind('click', function(e) {
        e.preventDefault();
        $('.promo_congrats').addClass('loading');
        form.addClass('loading');
        $("#customer_custom_fields_promo_code").focus();
        $("#customer_custom_fields_promo_code").val($(this).attr('data-value'));
        $("#customer_custom_fields_promo_code").blur();
        $("#customer_custom_fields_promo_code").change();
      });
    
      form.find('.paymentoption').click(function(e) {
        e.preventDefault();
        var self = $(this);
        if (self.hasClass('selected')) {
          self.removeClass('selected');
          options.removeClass('selected');
          planId.val('');
          planId.change();
        } else {
          selectOption(self);
        }
      });
      
      selectOption(form.find('.paymentoption.selected'));
      
      form.find('#customer_custom_fields_subscription_plan_id').addValidation({
        name: 'ccinlist',
        test: function() {
          var validValues = $('.paymentoption').map(function() { return $(this).attr('data-value'); }),
            validity = $.inArray($(this).val(), validValues) >= 0;
          $.validations.validity($(this), validity, "please select a payment option")
        }
      }).bind('validity', function(e) {
        if (e.valid) {
          $('.paymentoptions').removeClass('invalid').addClass('valid');
        } else {
          $('.paymentoptions').removeClass('valid').addClass('invalid');
        }
      });
      
      form.find('.ccfields input, .ccfields select').bind('validity', function(e) {
        if (e.valid) {
          $('.ccfields').removeClass('invalid').addClass('valid');
        } else {
          $('.ccfields').removeClass('valid').addClass('invalid');
        }
      })
      
      form.find('input.ccnumber').bind('keyup.updatecard', function(e) {
        var input = $(this), 
          type = input.ccType();
        if (type) {
          $('.creditcard .types').addClass('selected').addClass(type);
        } else {
          $('.creditcard .types').attr('class', 'types');
        }
      });
      form.find('.types').unbind('click.speedup').bind('click.speedup', function(e) {
        developmentCC();
      });
      promocode.unbind('change.updatecode').bind('change.updatecode', function(e) {
        updatePromoCode(this);
      });
      promocode.unbind('keydown.updatecode').bind('keydown.updatecode', function(e) {
        var self = this,
          timeout = $(self).data('change-timeout'),
          li = $(self).parents('li:first');
        if (e.keyCode == 13) {
          e.preventDefault();
          updatePromoCode(this);
        } else {
          li.removeClass('valid').removeClass('invalid');
          if ($(self).val() == '') {
            li.removeClass('loading');
          } else {
            li.addClass('loading');
          }
          clearTimeout(timeout);
          $(self).data('change-timeout', setTimeout(function() {
            $(self).change();
          }, 1000));
        }
      });
    };
  $.provide(go, "PaymentForm", {
    init: function(options) {
      form = $(options.form);
      bind();
    }
  });
}(Spot));