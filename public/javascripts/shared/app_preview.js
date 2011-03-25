(function(go) {
  var dT = 3000,
    animationT = 750,
    easing = "easeOutSine",
    step = 0,
    active, next, nextStep, screenCount,
    cleanup = function() {
      active.removeAttr("style");
      active = $('.screen').removeClass('active').eq(nextStep).addClass('active').removeClass('pending');
      step = nextStep;
      start();
    },
    run = function() {
      dT = 5000;
      if (nextStep === 0) {
        dT = 7000;
        next.addClass('pending');
        active.animate({opacity: 0}, animationT, easing, cleanup);
      } else if (nextStep === 1) {
        dT = 500;
        next.css({top: active.height(), zIndex: 10 }).show().animate({ top: 0 }, animationT, easing, cleanup);
      } else if ($.inArray(nextStep, [2, 3, 4, 5, 6, 7]) >= 0) {
        dT = nextStep === 7 ? 5000 : 500;
        dT = nextStep === 6 ? 1000 : dT;
        cleanup();
      } else if (nextStep === 8) {
        next.addClass('pending');
        next.css({ left: active.width() }).animate({ left: 0 }, animationT, easing);
        active.animate({left: -1 * active.width()}, animationT, easing, cleanup);
      } else if (nextStep === 9) {
        next.addClass('pending');
        active.animate({top: active.height()}, animationT, "easeInSine", cleanup);
      }
    },
    start = function() {
      nextStep = (step + 1) % screenCount;
      next = $('.screen').eq(nextStep);
      setTimeout(run, dT);        
    },
    startClock = function() {
      setInterval(function() {
        var now = new Date(),
          mins = now.getMinutes() >= 10 ? now.getMinutes() : '0' + now.getMinutes(),
          hrs = now.getHours(),
          ampm = hrs >= 12 ? 'PM' : 'AM';
        hrs = hrs === 12 || hrs === 0 ? 12 : hrs % 12;
        $('.status').text( hrs + ':' + mins  + ' ' + ampm);
      }, 250);
    };
  $.provide(go, "AppPreview", {
    init: function() {
      $('#phone').preloadAll(function() {
        start();
      });
      active = $('.screen').removeClass('active').eq(0).addClass('active'); 
      screenCount = $('.screen').length;      
      step = 0;
      startClock();
    }
  });
}(Spot));