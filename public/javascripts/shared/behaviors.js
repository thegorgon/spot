(function($) {
  $.extend($.fn, {
    placeholder: function(text) {
      $(this).filter('input,textarea').each(function() {
        var $input = $(this), placeholder,
          txt = text || $input.attr('placeholder');
        $input.removeAttr('placeholder');
        placeholder = $('#' + this.id + '_placeholder');        
        if (placeholder.length === 0) {
          placeholder = $('<div></div>').html(txt).attr('class', $input.attr('class')).addClass('placeholder').addClass($input.is("textarea") ? 'textarea' : 'input');
          $input.after(placeholder);
        }
        placeholder.add($input).unbind('.placeholder');
        placeholder.bind('click.placeholder', function(e) {
          e.preventDefault();
          $input.focus();
        });
        $input.bind('focus.placeholder', function(e) {
        });
        $input.bind('blur.placeholder', function(e) {
          if ($input.val() === '') {
            placeholder.css('display', '');
          } else {
            placeholder.hide();
          }
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
        } else {
          loaded();
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
    closer: function() {
      $(this).click(function(e) {
        $(this).parent().slideUp();
      });
    },
    reveals: function() {
      var target = $($(this).attr('href'));
      if (target.is('.hidden')) { target.removeClass('hidden').hide(); }
      $(this).click(function(e) {
        e.preventDefault();
        if (target.is(':visible')) {
          target.slideUp();          
        } else {
          target.slideDown();
        }
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
    toggleClass: function() {
      $(this).each(function(e) {
        var self = $(this),
          klass = self.attr('data-toggle-class'),
          target = self.is('[rel]') ? $(self.attr('rel')) : self;
        self.unbind('click.toggle-class').bind('click.toggle-class', function(e) {
          e.preventDefault();
          target.hasClass(klass) ? target.removeClass(klass) : target.addClass(klass);
        });
      })
    },
    tabBar: function() {
      var bar = $(this),
        tabs = bar.find('.tab');
      tabs.click(function(e) {
        e.preventDefault();
        var $this = $(this),
          current = tabs.filter('.active'),
          curcontent = $(current.attr('href')),
          rel = $($this.attr('href'));
        curcontent.fadeOut();
        tabs.removeClass('active');
        $this.addClass('active');
        rel.hide().removeClass('hidden').fadeIn();
      });
    },
    popupLink: function(options) {
      $(this).unbind('click.popup').bind('click.popup', function(e) {
        e.preventDefault();
        $.popup(this.href || $(this).add('data-href'), options);
      });
    },
    rowLink: function() {
      var bindRow = function(row) {
        row.each(function(i) {
          var self = $(this);
          self.find('a.rowlink').ajaxLink({
            start: function() {
              self.addClass('loading');
            }, success: function(data) {
              var html = $(data.html);
              bindRow(html);
              self.replaceWith(html);
            }
          });
        });
      };
      bindRow(this.parents('tr'));
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
      fetch('a.closer').closer();
      if ($.support.opacity) {
        fetch('.preload_bg').preloadBg();
        fetch('.preload').preloadImgs();
      }
      fetch('.pillbox .pill a').unbind('click.activate').bind('click.activate', function(e) {
        $(this).parents('.pillbox:first').find('.pill a').removeClass('active');
        $(this).addClass('active');
      });
      fetch('[data-toggle-class]').toggleClass();
      fetch('[placeholder]').placeholder();
      fetch('[data-mode=select]').selectOnly();
      fetch('.file_field input').fileField();
      fetch('a[data-method]:not(.ajax)').actionLink();
      fetch('a[data-confirm][data-method]:not(.ajax)').actionLink();
      fetch('.fbconnect').fbconnect();
      fetch('input, textarea').focus(function(e) {
        $(this).parents('.accept_focus').addClass('focus');
      });
      fetch('form input, form textarea').blur(function(e) {
        $(this).parents('.accept_focus').removeClass('focus');
      });
      fetch('.radio_fade').radioFade();
      fetch('.hoverable').hoverable();
      fetch('li.invalid input, input.invalid').focus(function(e) {
        $(this).parent('li').add(this).removeClass('invalid');
      });
      fetch('.rowlink').rowLink();
      fetch('.tabbar').tabBar();
      fetch('.twit-share-btn, .twitter-share-link').popupLink({width: 350, height: 300});
      fetch('.fb-share-button, .fb-share-link').popupLink({width: 550, height: 300});
      fetch('.fb-post-button, .fb-post-link').click(function(e) {
        e.preventDefault();
        FB.ui(
          {
            method: 'feed',
            name: $(this).attr('data-fb-name'),
            link: $(this).attr('data-fb-url') || 'http://www.spot-app.com',
            picture: $(this).attr('data-fb-image') || 'http://www.spot-app.com/images/logos/og_image.png',
            caption: $(this).attr('data-fb-caption'),
            description: $(this).attr('data-fb-description')
          },
          function(response) {
            if (response && response.post_id) {
              // SUCCESS
            } else {
              // FAIL
            }
          }
        );
      });
      fetch('form[data-validate]').autovalidate();        
      $('.editable').click(function(e) {
        e.preventDefault();
        $(this).addClass('editing').parents('ul.form').addClass('editing');
      });
      $('.stretcher').stretcher();
      $('.stretcher').load(function() { $(this).stretcher(); });
      $(window).unbind('resize.slideshow').bind('resize.slideshow', function(e) {
        $('.stretcher').stretcher();
      });
      fetch(".chzn-select").chosen()
    }
  });
}(Spot));