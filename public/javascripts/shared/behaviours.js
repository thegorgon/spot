(function($) {
  $.extend($.fn, {
    placeholder: function(text) {
      $(this).filter('input,textarea').each(function() {
        var $input = $(this), placeholder,
          txt = text || $input.attr('placeholder');
        placeholder = $('#' + this.id + '_placeholder');        
        if (placeholder.length === 0) {
          $input.after('<input id="'+ this.id + '_placeholder" type="text" tabindex="-1" value="' + txt + '" autocomplete="off" class="'+ $input.attr('class') + ' placeholder" formnovalidate="formnovalidate"/>');
          placeholder = $('#' + this.id + '_placeholder');        
        }
        placeholder.add($input).unbind('.placeholder');
        placeholder.bind('focus.placeholder', function(e) {
          e.preventDefault();
          $input.focus(); 
        });
        $input.bind('focus.placeholder', function(e) {
          placeholder.fadeOut($.support.opacity ? 250 : 0, function() {
            $input.data('focused', true);
          });
        });
        $input.bind('blur.placeholder', function(e) {
          if ($input.val() === '' && $input.data('focused')) {
            placeholder.fadeIn($.support.opacity ? 250 : 0, function() {
              $input.data('focused', false);              
            });
            placeholder.blur();          
          }
        });
        $input.bind('change.placeholder', function(e) {
          placeholder.change();
        });
        $input.blur();
      });
      return this;      
    },
    selectOnly: function() {
      $(this).live('click', function(e) {
        $(this).focus().select();
      });
    },
    imagePreload: function() {
      $(this).addClass('loading').find('img').hide().each(function(i) {
        var img = new Image(), $this = $(this);
        img.onload = function() { $this.hide().removeClass('loading').fadeIn(1000); };
        img.src = this.src;
      });
    },
    fbconnect: function() {
      var btn = $(this);
      btn.bind('click', function(e) {
        e.preventDefault();
        FB.login(function(response) {
          var form = btn.parent('form');
          if (response.session) {
            $.each(['access_token', 'base_domain', 'expires', 'uid', 'secret', 'session_key', 'sig', 'uid'], function(i) {
              form.find('input[rel=' + this + ']').val(response.session[this]);
            });
            form.submit();
          }
        }, {perms:'email'});
      });
    },
    preloadBackground: function() {
      $(this).hide().each(function(i) {
        var img = new Image(), $this = $(this),
          bg = $this.css('background-image').replace(/url\([\"\']?([^\)]+?)[\"\']?\)/i, '$1'),
          loaded = function() { $this.fadeIn(1000); };
        if (bg !== "none") {
          img.onload = loaded;
          img.src = bg;          
        }
        if (bg === null || bg === "") { loaded(); }
      });
    },
    preloadAll: function(cb) {
      var parent = $(this),
        images = [], loadCount = 0,
        completed = false,
        loaded = function() {
          loadCount = loadCount + 1;
          if (loadCount >= images.length && !completed) { 
            completed = true;
            parent.hide().removeClass('loading').fadeIn(500, cb); 
          }
        },
        forceLoad = function() {
          loadCount = images.length + 100;
          loaded();
        };
      parent.addClass('loading').find('*').add(parent).each(function(i) {
        var img, child = $(this), src = child[0].src || child.css('background-image').replace(/url\([\"\']?([^\)]+?)[\"\']?\)/i, '$1'),
          ext = src.toString().split(".").pop();
        ext = ext.replace(/([^\?]+)\?.+/i, '$1');
        if ($.inArray(src, images) < 0 && (ext === 'jpg' || ext === 'jpeg' || ext === 'png')) {
          img = new Image();
          images.push(src);
          img.onload = loaded;
          img.src = src;
        }
      });
      if (images.length === 0) { loaded(); }
      setTimeout(forceLoad, 3000);
    },
    actionLink: function() {
      $(this).die('click').live('click', function(e) {
        e.preventDefault();
        var link = $(this),
          url = link.attr('href'),
          method = (link.attr('data-method') || 'GET').toUpperCase(),
          confirmMsg = link.attr('data-confirm'),
          httpMethod = method === 'GET' ? method  : 'POST',
          authParam = $('meta[name=csrf-param]').attr('content'),
          authValue = $('meta[name=csrf-token]').attr('content'),
          form = $('<form action="' + url + '" method="' + httpMethod + '"></form>');
        if (confirmMsg === undefined || confirmMsg.length === 0 || window.confirm(confirmMsg)) {
          form.append('<input type="hidden" name="' + authParam + '" value="' + authValue + '"/>');
          if (httpMethod !== method) { form.append('<input type="hidden" name="_method" value="' + method + '" />'); }
          form.hide().appendTo('body').submit();                    
        }
      });
    },
    radioFade: function() {
      var container = this;
      $('.radio, .label', container).click(function(e) {
        var choice = $(this).parents('.choice'),
          rel = choice.attr('rel'),
          cb = choice.find('.radio'),
          curChoice = $('.choice.selected', container);
        curChoice.removeClass('selected');
        choice.addClass('selected');
        $(curChoice.attr('rel')).fadeOut($.support.opacity ? 250 : 0, function(i) {
          $(this).removeClass('selected');
        });
        $(rel).fadeIn($.support.opacity ? 250 : 0, function() {
          $(this).addClass('selected');
        });
      });
    },
    fileField: function() {
      var $this = $(this),
        setFilename = function() {
          $this.siblings('.filename').html($this.val());
        };
      setFilename();
      $this.live('mouseout change', function(e) {
        setFilename();
      });
    }
  });
}(jQuery));

(function(go) {
  var _vars = {};
  $.extend(go, {
    init: function(vars) {
      $.extend(_vars, vars);
      $.logger.level(_vars.env === 'production' ? 'ERROR' : 'DEBUG');
      go.Navigator.init();
      $.mobileOptimize();
      if ($.support.opacity) {
        $('#bg').preloadBackground();
        $('#page').preloadAll();
      }
    },
    getVar: function(name) {
      return _vars[name];
    },
    behave: function() {
      $('[placeholder]').placeholder();
      $('[data-mode=select]').selectOnly();
      $('.file_field input').fileField();
      $('a[data-method]:not(.ajax)').actionLink();
      $('a[data-confirm][data-method]:not(.ajax)').actionLink();
      $('.fade_in').fadeIn();
      $('#flash').hide().removeClass('hidden').slideDown(500, function() {
        setTimeout(function() { $('#flash').slideUp(500); }, 3000);
      });
      $('.fbconnect').fbconnect();
      $('ul.form input').focus(function(e) {
        $(this).parent('li').addClass('focus');
        $(this).parents('ul').addClass('focus');
      });
      $('ul.form input').blur(function(e) {
        $(this).parent('li').removeClass('focus');
        $(this).parents('ul').removeClass('focus');
      });
      $('.radio_fade').radioFade();
      $('#flashes .close').click(function(e) {
        var height = $('#flashes').outerHeight();
        $('#flashes').animate({top: -1 * height}, 500, 'linear', function() {
          $('#flashes').remove();
        });
      });
      $('li.invalid input, input.invalid').focus(function(e) {
        $(this).parent('li').add(this).removeClass('invalid');
      });
      $('form[data-validate]').validate();
    }
  });
}(Spot));