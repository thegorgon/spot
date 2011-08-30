(function(go) {
  $.provide(go, "Events", {
    userRecord: function(event, value) {
      $.post('/uevent.json', {
        event: event,
        value: value
      });
      return true;
    },
    acquireRecord: function(event, value) {
      $.post('/aevent.json', {
        event: event,
        value: value
      });
      return true;
    },
    analytics: function(category, event, label, value) {
      if (window['_gaq']) {
        _gaq.push(['_trackEvent', category, event, label, value]);
      }
    },
    pageView: function(path) {
      if (window['_gaq']) {
        _gaq.push(['_trackPageview', path]);
      }
    }
  })
}(Spot));