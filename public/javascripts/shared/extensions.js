(function($) {
  $.extend($, {
    provide : function(object, name, features) {
      object[name] = object[name] || {};
      $.extend(object[name], features);
      return object;
    }
  });
  $.extend($.fn, {
    ajaxForm: function(options) {
      options = options || {};
      this.filter('form').each(function() {
        var $this = $(this);
        $this.unbind('submit.ajaxForm');
        $this.bind('submit.ajaxForm', function(e) {
          e.preventDefault();
          if ($.isFunction(options.save)) { options.save.apply(this); }
          $this.ajaxSubmit(options);
        });	    
      });
    },
    ajaxClick: function(options) {
      var $this = $(this), success, method, httpMethod, data;
      options = options || {};
      if (!$this.data('sending')) {
        $this.data('sending', true);
        success = ($.isFunction(options.success) ? options.success: function() {});
        options.success = function() {
          $this.data('sending', false);
          success.apply($this, arguments);
        };
        method = ($this.attr('data-method') || 'GET').toUpperCase();
        httpMethod = method == "GET" ? method : "POST";
        data = {};
        if (httpMethod != method) { data._method = method; }
        options = $.extend({
          type: httpMethod,
          url: $this.attr('href'),
          data: data,
          dataType: 'json'
        }, options);
        return $.ajax(options);        
      }
    },
    ajaxSubmit: function(options) {
      var $this = $(this), success;
      options = options || {};
      if (!$this.data('sending')) {
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
      }
    },
    runValidations: function() {
      $(this).filter('form').each(function() {
        var form = $(this), valid = true;
      });
    },
    popup: function() {
      var wrapper = $("<div id=\"popup_wrapper\"></div>");
      wrapper.append(this).appendTo("body").css('top', $(document).height() * 0.5 - $(this).outerHeight() * 0.5 + $(document).scrollTop());
    }
  });
}(jQuery));