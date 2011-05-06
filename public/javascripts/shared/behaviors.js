(function($) {
  $.extend($.fn, {
    placeholder: function(text) {      
      $(this).filter('input,textarea').each(function() {
        var $input = $(this), placeholder,
          txt = text || $input.attr('placeholder');
        $input.removeAttr('placeholder');
        placeholder = $('#' + this.id + '_placeholder');        
        if (placeholder.length === 0) {
          placeholder = $input.clone().attr('id', this.id).val(txt).removeAttr('name').attr('autocomplete', 'off').attr('formnovalidate', 'formnovalidate').attr('tabindex', '-1').addClass('placeholder');
          $input.after(placeholder);
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
        if ($input.val() === '') {
          $input.blur();          
        } else {
          placeholder.hide();
        }
      });
      return this;      
    },
    selectOnly: function() {
      $(this).live('click', function(e) {
        $(this).focus().select();
      });
    },
    preloadImgs: function() {
      $(this).find('img').hide().each(function(i) {
        var img = $(this),
          obj = new Image();
        obj.onload = function() { img.fadeIn(); };
        obj.src = img.attr('src');
      });
    },
    preloadBg: function() {
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
    reveals: function() {
      $(this).click(function(e) {
        e.preventDefault();
        $($(this).attr('href')).toggle(250);
      });
    },
    actionLink: function() {
      $(this).unbind('click.submit').bind('click.submit', function(e) {
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
    hoverable: function() {
      $(this).each(function() {
        var imgs =  $(this).find('img').add(this).filter('img'),
          hoversrc = function(src) {
            var ext = src.split('.').pop();
            return src.replace("." + ext, "_hover." + ext);
          };
        imgs.each(function() {
          $.preload( [hoversrc($(this).attr('src'))] );
        });
        $(this).bind('mouseenter', function(e) {
         imgs.each(function(i) { $(this).attr('src', hoversrc($(this).attr('src'))); });
        });
        $(this).bind('mouseleave', function(e) {
          imgs.each(function(i) { $(this).attr('src',$(this).attr('src').replace('_hover', '')); });        
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
    },
    tabBar: function() {
      var bar = $(this),
        tabs = bar.find('.tab');
      tabs.click(function(e) {
        e.preventDefault();
        var $this = $(this),
          current = tabs.filter('.current'),
          curcontent = $(current.attr('href')),
          rel = $($(this).attr('href'));
        curcontent.fadeOut();
        tabs.removeClass('current');
        $this.addClass('current');
        rel.fadeIn();
      });
    }
  });
}(jQuery));

(function(go) {
  $.provide(go, "Behaviors", {
    train: function(container) {
      var fetch = function(sel) { return $(sel, container); };
      go.Navigator.link(fetch("a.page"));
      go.Navigator.form(fetch("form.page"));
      $.popover.bind(container);
      fetch('a.reveals').reveals();
      if ($.support.opacity) {
        fetch('.preload_bg').preloadBg();
        fetch('.preload').preloadImgs();
      }
      fetch('[placeholder]').placeholder();
      fetch('[data-mode=select]').selectOnly();
      fetch('.file_field input').fileField();
      fetch('a[data-method]:not(.ajax)').actionLink();
      fetch('a[data-confirm][data-method]:not(.ajax)').actionLink();
      fetch('.fbconnect').fbconnect();
      fetch('ul.form input, ul.form textarea').focus(function(e) {
        $(this).parent('li').addClass('focus');
        $(this).parents('ul').addClass('focus');
      });
      fetch('ul.form input, ul.form textarea').blur(function(e) {
        $(this).parent('li').removeClass('focus');
        $(this).parents('ul').removeClass('focus');
      });
      fetch('.radio_fade').radioFade();
      fetch('.hoverable').hoverable();
      fetch('li.invalid input, input.invalid').focus(function(e) {
        $(this).parent('li').add(this).removeClass('invalid');
      });
      fetch('.tabbar').tabBar();
      fetch('.twitter-share-button').click(function(e) {
        e.preventDefault();
        var left = screen.width > 350 ? Math.round(0.5 * (screen.width - 350)) : 0,
          top = screen.height > 300 ? Math.round(0.5 * (screen.height - 300)) : 0;
        window.open(this.href, "tweetwindow", "scrollbars=yes,resizable=yes,toolbar=no,location=yes,width=350,height=300,left=" + left + ",top=" + top);
      });
      fetch('form[data-validate]').autovalidate();
    }
  });
}(Spot));