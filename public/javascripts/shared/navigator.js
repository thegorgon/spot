(function(go) {
  var lastHash, initialUrl,
    onStart = function() {
      var bd = $('#bd');  
      if (bd.is(":visible") && !bd.is(":animated")) {
        bd.fadeOut(function() {
          bd.trigger('faded');
        });        
      }
    },
    onSuccess = function(data, url, force) {
      var html, bd = $("#bd"), body = $('body');
      if (data.redirect_to) {
        return  go.Navigator.get(data.redirect_to);
      } else if (data.html) {
        html = $(data.html);
        bd.unbind('faded.navComplete').bind("faded.navComplete", function() {
          $.logger.debug("Received data : ", data);
          bd.html(html).unbind("faded.navComplete");
          body.attr("id", data.page.namespace);
          body.attr('class', data.page.controller);
          go.Views.run(url);
          bd.fadeIn();
        });
        if (!bd.is(":animated")) {
          bd.trigger("faded");
        }
      } else {
        $.logger.debug("UNHANDLED : ", data);
      }
      return setHash(url, force);
    },
    getHash = function(hash) {
      hash = hash || window.location.hash.toString();
      hash = hash.replace(/^[^#]*#?(.*)$/, '$1');                
      hash = hash.replace(/^\s+|\s+$/g, "");
      hash = hash || window.location.pathname + window.location.search;
      return hash;
    },
    setLastHash = function(hash) {
      hash = hash || getHash();
      $(window).data('onhashchange.lastHash', hash);
      return hash;
    },
    getLastHash = function() {
      return $(window).data('onhashchange.lastHash');
    },
    setHash = function(url, force) {
      var host = window.location.protocol.toString() + "//" + window.location.host.toString();
      url = url.replace(host, "");
      if (force === undefined || force === null) { force = true; }
      if (url == initialUrl) {
        setLastHash(url);
        if (force && window.location.hash.toString().length > 0) {
          window.location.href = "#" + initialUrl;
        }        
      } else {
        setLastHash(url);
        window.location.href = "#" + url;        
      }
    },
    onHashChange = function() {
      var lastHash = getLastHash(), e;
      if (getHash() != lastHash) {
        onStart();
        e = jQuery.Event("navigator");
        e.lastHash = lastHash;
        lastHash = getHash();
        e.newHash = lastHash;
        setLastHash(lastHash);
        $(window).trigger(e);
      }
    },
    bindOnHashChange = function() {
      if ('onhashchange' in window && (document.documentMode === undefined || document.documentMode > 7)) {
        window.onhashchange = onHashChange;
      } else {
        $(window).data('onhashchange.interval', setInterval(onHashChange, 50));
      }
    };
  $.provide(go, "Navigator", {
    init: function() {
      var lastHash = setLastHash(), that = this;
      initialUrl = window.location.pathname + window.location.search;
      if (lastHash && lastHash.length > 0 && lastHash != initialUrl) {
        this.get(lastHash);
      }
      bindOnHashChange();
      $(window).bind('navigator', function(e) {
        var url = e.newHash;
        url = url.length > 0 ? url : initialUrl;
        that.get(url, {force: false});
      });
    },
    current: function() {
      return getHash();
    },
    get: function(url, options) {
      options = options || {};
      options = $.extend({
        type: "GET",
        url: url,
        dataType: 'json',
        success: function(data) { onSuccess(data, url, options.force); }
      }, options);
      $.ajax(options);
    },
    post: function(url, data, options) {
      options = options || {};
      options = $.extend({
        dataType: 'json',
        url: url,
        type: 'POST',
        data: data,
        success: function(data) { onSuccess(data, url, options.force); }
      }, options);
      return $.ajax(options);
    },
    submit: function(form, options) {
      var method = form.attr('method').toUpperCase(),
        data = form.find('[name!=utf8]').serialize(),
        url = form.attr('action'),
        confirmMsg = form.attr('data-confirm');
      form.find('input, textarea').val('').blur();
      if (method == "GET") { url = url.indexOf('?') > 0 ? url + '&' + data : url + '?' + data; }
      if (confirmMsg === undefined || confirmMsg.length === 0 || window.confirm(confirmMsg)) {
        onStart();
        return method == "GET" ? this.get(url, options) : this.post(url, data, options);
      } else {
        return false;
      }
    },
    click: function(link, options) {
      var method = (link.attr('data-method') || 'GET').toUpperCase(),
        url = link.attr('href'),
        confirmMsg = link.attr('data-confirm');
        if (confirmMsg === undefined || confirmMsg.length === 0 || window.confirm(confirmMsg)) {
          onStart();
          return method == "GET" ? this.get(url, options) : this.post(url, {_method: method}, options);
        } else {
          return false;
        }
    }, 
    link: function(link, options) {
      link.filter('a').each(function() {
        var $this = $(this);
        $this.unbind('click.navLink');
        $this.bind('click.navLink', function(e) {
          e.preventDefault();
          go.Navigator.click($this, options);
        });
      });      
    },
    form: function(form, options) {
      options = options || {};
      form.filter('form').each(function() {
        var $this = $(this);
        $this.unbind('submit.navForm');
        $this.bind('submit.navForm', function(e) {
          e.preventDefault();
          go.Navigator.submit($this, options);
        });	    
      });
    }
  });
}(Spot));