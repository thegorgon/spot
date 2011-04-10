(function($) {
  $.ajaxSetup({
    'beforeSend': function(xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name=csrf-token]').attr('content')); }
  });
  $.extend($, {
    mobile: function() {
      return navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/android/i) || navigator.userAgent.match(/ipod/i);
    },
    updateOrientation: function() {
      var orient = Math.abs(window.orientation) === 90 ? "landscape" : "portrait";
      if (orient !== $('body').attr('orient')) {
        $('body').attr('orient', orient);        
        window.scrollTo(0, 1);
      }
      return true;
    },
    mobileOptimize: function() {
      if (this.mobile()) {
        setTimeout(this.updateOrientation, 0);
        window.onorientationchange = function() {
          $.updateOrientation();
        };
      }
    },
    preload: function(images, cb) {
      var img;
      cb = $.isFunction(cb) ? cb : function() {};
      $.each(images, function(i) {
        img = new Image();
        img.src = this;
        img.onLoad = cb;
      });
    },
    provide : function(object, name, features) {
      object[name] = object[name] || {};
      $.extend(object[name], features);
      return object;
    },
    geolocate: function(options) {
      var geo = null;
      options.success = $.isFunction(options.success) ? options.success : function() {};
      options.error = $.isFunction(options.error) ? options.error : function() {};

      if (navigator.geolocation){
        geo = navigator.geolocation;
      } else if (google.gears) {
        geo = google.gears.factory.create('beta.geolocation');
      }
      if (geo) {
        geo.getCurrentPosition(options.success, options.error);        
      } else {
        options.error.call(window, -1, "Geolocation is not supported in this browser");
      }
    }
  });
  $.extend($.fn, {
    absolutize: function() {
      var $this = $(this),
        offset = $this.offset(),
        parent = $this.offsetParent();
      $this.css({width: $this.innerWidth(), height: $this.innerHeight(), position: 'absolute', top: offset.top, left: offset.left});
    },
    ajaxForm: function(options) {
      options = options || {};
      this.filter('form').each(function() {
        var $this = $(this);
        $this.unbind('submit.ajaxForm');
        $this.bind('submit.ajaxForm', function(e) {
          e.preventDefault();
          $this.ajaxSubmit(options);
        });	    
      });
    },
    ajaxLink: function(options) {
      options = options || {};
      this.filter('a').each(function() {
        var $this = $(this);
        $this.unbind('click.ajaxLink');
        $this.bind('click.ajaxLink', function(e) {
          e.preventDefault();
          $this.ajaxClick(options);
        });
      });
    },  
    ajaxClick: function(options) {
      var $this = $(this), success, method, httpMethod, data, confirmMsg;
      options = options || {};
      if (!$this.data('sending')) {
        confirmMsg = $this.attr('data-confirm') || '';
        if (confirmMsg.length === 0 || window.confirm(confirmMsg)) {
          if ($.isFunction(options.start)) { options.start.apply(this); }
          $this.data('sending', true);
          success = ($.isFunction(options.success) ? options.success: function() {});
          options.success = function() {
            $this.data('sending', false);
            success.apply($this, arguments);
          };
          method = ($this.attr('data-method') || 'GET').toUpperCase();
          httpMethod = method === "GET" ? method : "POST";
          data = {};
          if (httpMethod !== method) { data._method = method; }
          options = $.extend({
            type: httpMethod,
            url: $this.attr('href'),
            data: data,
            dataType: 'json'
          }, options);
          return $.ajax(options);
        } else {
          return false;
        }
      }
    },
    ajaxSubmit: function(options) {
      var $this = $(this), success, confirmMsg;
      options = options || {};
      if (!$this.data('sending')) {
        confirmMsg = $this.attr('data-confirm') || '';
        if (confirmMsg.length === 0 || window.confirm(confirmMsg)) {
          if ($.isFunction(options.start)) { options.start.apply(this); }
          $this.data('sending', true);
          success = ($.isFunction(options.success) ? options.success: function() {});
          options.success = function() {
            $this.data('sending', false);
            success.apply($this, arguments);
          };
          options = $.extend({
            dataType: 'json',
            url: $this.attr('action'),
            type: $this.attr('method').toUpperCase(),
            data: $this.serialize()
          }, options);
          return $.ajax(options);
        } else {
          return false;
        }
      }
    },
    popup: function() {
      var wrapper = $("<div id=\"popup_wrapper\"></div>");
      wrapper.append(this).appendTo("body").css('top', $(document).height() * 0.5 - $(this).outerHeight() * 0.5 + $(document).scrollTop());
    }
  });
}(jQuery));