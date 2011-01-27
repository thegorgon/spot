(function($) {
    var logLevel = 0;
    var _LEVELS = {
      NONE: 0,
      ERROR: 1,
      DEBUG: 2,
      VERBOSE: 3
    };
    var log = function(logs, level) {
      if (logLevel >= level) {
        try {
          console.log.apply(window.console, logs);
        } catch(e) {}
      }
    };
    $.logger = $.logger || {};
    $.extend($.logger, {
      level: function(level) {
        if (level) {
          logLevel = _LEVELS[level];
        } else {
          return logLevel;
        }
      },
      log: function() {
        log(arguments, _LEVELS.NONE);
      },
      error: function() {
        log(arguments, _LEVELS.ERROR);
      },
      debug: function() {
        log(arguments, _LEVELS.DEBUG);
      },
      LEVELS: _LEVELS
    });
}(jQuery));