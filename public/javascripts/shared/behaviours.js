(function($) {
  var passwordPlaceholder = function(input, text) {
      var $input = $(input), placeholder,
        text = text || $input.attr('placeholder');
      $input.after('<input id="'+ input.id + '_placeholder" type="text" value="' + text + '" autocomplete="off" class="'+ $input.attr('class') + ' placeholder" />');
      placeholder = $('#' + input.id + '_placeholder');
      placeholder.show();
      $input.hide();
      $input.val('');
      placeholder.bind('focus.placeholder', function(e) {
        placeholder.hide();
        $input.show();
        $input.focus();
      });
      $input.bind('blur.placeholder', function(e) {
        $input.hide();
        placeholder.show();
        placeholder.blur();
      });
    };
  $.extend($.fn, {
    placeholder: function(text) {
      $(this).filter('input,textarea,password').each(function() {
        if ($(this).attr('type') == 'password') {
          passwordPlaceholder(this, text);
        } else {
          var $this = $(this), text = text || $this.attr('placeholder');
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
        }
      });
      return this;      
    },
    selectOnly: function() {
      $(this).live('click', function(e) {
        $(this).focus().select();
      });
    },
    imagePreload: function() {
      $(this).find('img').hide().each(function(i) {
        var img = new Image(), $this = $(this);
        img.onload = function() { $this.fadeIn(1000); };
        img.src = this.src;
      });
    },
    preloadBackground: function() {
      $(this).hide().each(function(i) {
        var img = new Image(), $this = $(this);
        img.onload = function() { $this.fadeIn(1000); };
        img.src = $this.css('background-image').replace(/url\(([^\)]+)\)/i, '$1');
      });
    },
    preloadAll: function(cb) {
      var parent = $(this),
        imgCount = 0,
        loadCount = 0,
        loaded = function() {
          loadCount = loadCount + 1;
          if (loadCount >= imgCount) {
            parent.fadeIn(1000, cb);
          }
        };
      parent.hide().find('*').add(parent).each(function(i) {
        var img, child = $(this), src = child[0].src || child.css('background-image').replace(/url\(([^\)]+)\)/i, '$1'),
          ext = src.toString().split(".").pop();
        ext = ext.replace(/([^\?]+)?.+/i, '$1');
        if (ext === 'jpg' || ext === 'jpeg' || ext === 'png') {
          img = new Image();
          imgCount = imgCount + 1;
          img.onload = loaded;
          img.src = src;
        }
      });
    },
    actionLink: function() {
      $(this).die('click').live('click', function(e) {
        e.preventDefault();
        var link = $(this),
          url = link.attr('href'),
          method = (link.attr('data-method') || 'GET').toUpperCase(),
          confirmMsg = link.attr('data-confirm'),
          httpMethod = method == 'GET' ? method  : 'POST',
          authParam = $('meta[name=csrf-param]').attr('content'),
          authValue = $('meta[name=csrf-token]').attr('content'),
          form = $('<form action="' + url + '" method="' + httpMethod + '"></form>');
        if (confirmMsg === undefined || confirmMsg.length === 0 || window.confirm(confirmMsg)) {
          form.append('<input type="hidden" name="' + authParam + '" value="' + authValue + '"/>');
          if (httpMethod != method) { form.append('<input type="hidden" name="_method" value="' + method + '" />')}
          form.hide().appendTo('body').submit();                    
        }
      })
    },
    fileField: function() {
      var $this = $(this),
        setFilename = function() {
          $this.siblings('.filename').html($this.val());
        };
      setFilename();
      $this.live('mouseout change', function(e) {
        setFilename()
      })
    }
  });
}(jQuery));

(function(go) {
  var _vars = {};
  $.extend(go, {
    init: function(vars) {
      $.extend(_vars, vars);
      $.logger.level(_vars.env == 'production' ? 'ERROR' : 'DEBUG');
      go.Navigator.init();
      $('#ft').preloadAll();
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
      $('#flash').hide().removeClass('hidden').slideDown(500, function() {
        setTimeout(function() { $('#flash').slideUp(500) }, 3000);
      })
      $('.preload', '#bd').imagePreload();
      $('.preload_bg', '#bd').preloadBackground();
    }
  });
}(Spot));