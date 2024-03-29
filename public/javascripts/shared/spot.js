window.Spot = {};

(function(go) {
  var _vars = {};  
  $.extend(go, {
    init: function(vars) {
      $.extend(_vars, vars);
      $.logger.level(_vars.env === 'production' ? 'ERROR' : 'DEBUG');
      go.Navigator.init();
      $.mobileOptimize();
      $.preload(vars.preload);
      $.jstooltip.init();
      go.Views.run();
      $(window).load(this.loaded);    // Call loaded on load
      setTimeout(this.loaded, 2000);  // Call loaded in two seconds if not loaded by then
    },
    env: function(name) {
      return _vars[name];
    },
    setEnv: function(name, value) {
      _vars[name] = value;
    },
    loaded: function() {
      if (!$('html').hasClass('loaded')) {
        $('html').addClass('loaded');        
      }
    }
  });
}(Spot));

window.fbAsyncInit = function() {
  FB.init({appId: Spot.env('env') == 'production' ? 146911415372759 : 329653055238, status: true, cookie: true, xfbml: true});
};
(function() {
  var e = document.createElement('script'); e.async = true;
  e.src = document.location.protocol +
    '//connect.facebook.net/en_US/all.js';
  document.getElementById('fb-root').appendChild(e);
}());

$.ajaxSetup({
  'beforeSend': function(xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name=csrf-token]').attr('content')); }
});

window.addthis_share = {
  templates: { twitter: '{{title}} {{lurl}} via @spotteam' },
  email_template: "glasses_tpl"
};

