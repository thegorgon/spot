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
    }
  })
}(Spot));