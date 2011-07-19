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
      $.validations.validity(yearField, validity, "is your card expired?")
      $.validations.validity(monthField, validity, "is your card expired?")
    }
  });
  
}(jQuery));

(function(go) {
  var viewStack = [],
    uiDialog,
    form = null,
    developmentCC = function() {
      if (go.env('env') != 'production') {
        var devCards = [4111111111111111, 4005519200000004, 4009348888881881, 4012000033330026, 4012000077777777, 4012888888881881, 4217651111111119, 4500600000000061, 5555555555554444, 378282246310005, 371449635398431, 6011111111111117];        
        form.find('.ccnumber').val($.rand(devCards)).focus().keyup().blur().change();
        $('.expmonth').val('05').change();
        $('.expyear').val(Date.now().getFullYear() + 3).change();
        $('.cvv').val('364').focus().blur().change();
      }
    },
    bind = function() {
      var cc = form.find('.ccfields'), 
        planId = $('#customer_custom_fields_subscription_plan_id'),
        options = $('.paymentoptions'),
        selectOption = function(option) {
          if (option.length > 0) {
            options.find('.paymentoption').removeClass('active');
            options.addClass('selected');
            option.addClass('active');
            planId.val(option.attr('data-value'));
            cc.slideDown();            
          }
        };
      cc.hide().removeClass('hidden');
      
      form.find('.paymentoption').click(function(e) {
        e.preventDefault();
        var self = $(this);
        if (self.hasClass('active')) {
          self.removeClass('active');
          options.removeClass('selected');
          planId.val('');
          cc.slideUp();
        } else {
          selectOption(self);
        }
      });
      
      selectOption(form.find('.paymentoption.active'));
      
      form.find('input.ccnumber').bind('keyup.updatecard', function(e) {
        var input = $(this), 
          type = input.ccType();
        if (type) {
          $('.creditcard .types').addClass('selected').addClass(type);
        } else {
          $('.creditcard .types').attr('class', 'types');
        }
      });
      form.find('.types').unbind('click.speedup').bind('click.speedup', function(E) {
        developmentCC();
      });
    };
  $.provide(go, "PaymentForm", {
    init: function(options) {
      form = $(options.form);
      bind();
    }
  });
}(Spot));