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
    developmentCC = function() {
      if (go.env('env') != 'production') {
        var devCards = [4111111111111111, 4005519200000004, 4009348888881881, 4012000033330026, 4012000077777777, 4012888888881881, 4217651111111119, 4500600000000061, 5555555555554444, 378282246310005, 371449635398431, 6011111111111117];        
        $('input#customer_credit_card_number').val($.rand(devCards)).focus().keyup().blur().change();
        $('select#customer_credit_card_expiration_month').val('05').change();
        $('select#customer_credit_card_expiration_year').val(Date.now().getFullYear() + 3).change();
        $('input#customer_credit_card_cvv').val('364').focus().blur().change();
      }
    },
    pushView = function(dialog, view) {
      var current = viewStack[viewStack.length - 1];
      if (current) {
        dialog.css({height: dialog.height()});
        // dialog.find('.previous').show();
        current.css({position: 'absolute', left: 0 }).animate({left: -800});
        view.css({position: 'absolute', left: 800 }).show().animate({left: 0});
        dialog.find('form').clear();
      }
      $('#ui-dialog-title-getitnowdialog').text(view.attr('data-title'));
      viewStack.push(view);
    },
    popView = function(dialog) {
      var current = viewStack.pop(),
        previous = viewStack[viewStack.length - 1];
      if (current && previous) {
        dialog.css({height: dialog.height()});
        previous.css({position: 'absolute', left: -800}).show().animate({left: 0});
        current.css({position: 'absolute', left: 0 }).show().animate({left: 800});
        $('#ui-dialog-title-getitnowdialog').text(previous.attr('data-title'));
        if (viewStack.length <= 1) {
          dialog.find('.previous').hide();
        }
      }
    },
    clearViews = function(dialog) {
      while (viewStack.length > 0) { popView(dialog); }
    },
    bindPaymentDialog = function(dialog) {
      // dialog.find('.previous').unbind('click.dialognav').bind('click.dialognav', function(e) {
      //   e.preventDefault();
      //   popView(dialog);
      // });
      $('.forward').unbind('click.dialognav').bind('click.dialognav', function(e) {
        e.preventDefault();
        pushView(dialog, $($(this).attr('data-view')));
      });
    },
    bindPaymentForm = function(form) {
      $(form).find('input.username').bind('keyup.updatecard', function(e) {
        var equiv = $(this).parents('form').find('.card .username'),
          name = $.trim([$('#customer_first_name').val(), $('#customer_last_name').val()].join(" ")).toUpperCase();
        if (name.length === 0) {
          equiv.text(equiv.attr("data-default"));
        } else {
          equiv.text(name);
        }
      });
      $(form).find('input.ccnumber').bind('keyup.updatecard', function(e) {
        var input = $(this), 
          type = input.ccType();
        if (type) {
          $('.card .types').addClass('selected').addClass(type);
        } else {
          $('.card .types').attr('class', 'types');
        }
      });
      $(form).find('.types').unbind('click.speedup').bind('click.speedup', function(E) {
        developmentCC();
      });
    },
    initDialog = function(dialog, options) {
      var position = options.position || ["center", "center"];
      options = $.extend({
        modal: false, 
        closeText: '',
        width: 800,
        title: "",
        position: position,
        autoOpen: false,
        close: function(event, ui) {
          clearViews(dialog);
          $(window).unbind("resize.dialog");
          $(window).unbind("scroll.dialog");
          dialog.find('.view').add(dialog).removeAttr('style');
          dialog.find('.view:first').show();
          $('body').find('.ui-widget-overlay').remove();
        },
        open: function(event, ui) {
          var overlay = $('body').find('.ui-widget-overlay');
          overlay = overlay.length > 0 ? overlay : $('<div></div>').addClass('ui-widget-overlay').appendTo('body');
          overlay.css({width: $(window).width(), height: $(window).height(), zIndex: 1000});
          pushView(dialog, dialog.find('.view:first'));
          $(window).bind("resize.dialog", function() { 
            dialog.dialog("option", "position", position);
          });
          $(window).bind("scroll.dialog", function() { 
            dialog.dialog("option", "position", position);
          });
        }
      }, options);
      dialog.removeClass('hidden').dialog(options);
    },
    openDialog = function(dialog) {
      dialog.dialog('open');
    };
  $.provide(go, "PaymentDialog", {
    init: function(options) {
      options = options || {};
      var dialog = $(options.dialog),
        trigger = $(options.trigger),
        position = options.position || ["center", "center"];
      
      dialog.find('.view:first').show();
      initDialog(dialog, options);
      bindPaymentDialog(dialog);
      bindPaymentForm(dialog.find('.payform'));
      
      trigger.click(function(e) {
        e.preventDefault();
        $('button').blur();
        openDialog(dialog, {position: position});
      });
    }
  });
}(Spot));