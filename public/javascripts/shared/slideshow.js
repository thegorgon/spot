(function($) {
  $.fn.slideshow = function(opts) {
    var element = $(this),
      slideTpl = element.find('#slidetpl'),
      settings = {
        title: null,
        start: 0,
        fadeFor: 2000,
        waitFor: 10000,
        useCss: true
      }, i = 0, runningInterval,
      options = $.extend(settings, opts || {}),
      title = $(options.title),
      slideData = options.slides,
      slides = element.find('.slide'),
      currentIdx = options.start,
      jumpTo = function(i, wait) {
        var current = slides.eq(currentIdx),
          next = slides.eq(i);
        if (options.useCss && Modernizr.csstransitions) {
          title.removeClass('visible');
          setTimeout(function() {
            title.text(next.attr('title')).addClass('visible');
          }, 1100);
          setTimeout(function() {
            next.css({zIndex: 20});
            current.css({zIndex: 10});
            next.addClass('current');
            setTimeout(function() {
              current.removeClass('current');
              currentIdx = i;
            }, 2000);
          }, 500);
        } else {
          current.css({zIndex: 20});
          next.css({zIndex: 10}).show();
          title.animate({bottom: 10}, 1000, function() {
            title.text(next.attr('title')).animate({bottom: 100}, 1000);
            current.fadeOut(options.fadeFor, function() {
              next.css({zIndex: 20});
              current.css({zIndex: 10});
              currentIdx = i;        
            });          
          });
        }
      }, 
      nextSlide = function() {
        var next = currentIdx < slides.length - 1 ? currentIdx + 1 : 0;
        jumpTo(next);
      },
      lastSlide = function() {
        var last = currentIdx > 0 ? currentIdx - 1 : slides.length - 1;
        jumpTo(last);
      },
      start = function() {
        runningInterval = setInterval(function() {
          nextSlide();
        }, options.waitFor);
      },
      build = function() {
        $.each(slideData, function(i) {
          var slide = slideTpl.tmpl(this).appendTo(element);
        });
        slides = element.find('.slide');
      },
      stop = function() {
        clearInterval(runningInterval);
      };
    $('.slide img', element).unbind("contextmenu.cancel").bind("contextmenu.cancel", function() { return false; });
    $('.slide img', element).unbind("mousedown.cancel").bind("mousedown.cancel", function() { return false; });
    element.hide();
    build();
    $(window).load(function() {
      setTimeout(function() {
        var current = slides.eq(currentIdx);
        slides.css({zIndex: 10});
        
        if (options.useCss && Modernizr.csstransitions) {
          element.css('-webkit-transform', 'translateZ(0)');
          title.text(current.attr('title')).addClass('visible');
          current.addClass('current');
          current.css({zIndex: 20});
        } else {
          title.text(current.attr('title'));
          current.css({zIndex: 20}).show();          
        }
        element.show();
      }, 100);
    });
    
    return {
      nextSlide: nextSlide,
      lastSlide: lastSlide,
      jumpTo: jumpTo,
      start: start,
      stop: stop
    };
  };
}(jQuery));