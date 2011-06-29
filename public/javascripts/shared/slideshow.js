(function($) {
  $.fn.sizeToFit = function(container, options) {
    container = $(container);
    var resize = $(this),
      gravities = (options.gravity || '0.5x0.5').split('x'),
      rH = resize.height(), rW = resize.width(),
      cW = container.width(), cH = container.height(),
      cRatio = (cH / cW).toFixed(2), rRatio = ( rH / rW).toFixed(2),
      dims = {}, off = {},
      gravityTop = parseFloat(gravities[0], 10), 
      gravityLeft = parseFloat(gravities[1], 10);
    if (cRatio > rRatio) {
      dims.h = cH;
      dims.w = (cH/rRatio);
    } else {
      dims.w = cW;
      dims.h = (cW * rRatio);
    }
    if (dims.w > 0 && dims.h > 0) {
      resize.width(dims.w);
      resize.height(dims.h);
      off.top = Math.round(gravityTop * (cH - dims.h));
      off.left = Math.round(gravityLeft * (cW - dims.w));
      resize.css({width: dims.w, height: dims.h, top: off.top, left: off.left});
    }
  };
  $.fn.slideshow = function(opts) {
    var element = $(this),
      viewport = element.find('#viewport'),
      title = element.find('#slidetitle'),
      settings = {
        slides: [],
        start: 0,
        fadeFor: 2000,
        waitFor: 10000,
        useCss: true,
        version: 1
      }, i = 0, runningInterval,
      options = $.extend(settings, opts || {}),
      currentIdx = options.start,
      resize = function() {
        var width = viewport.width(),
          height = viewport.height();
        $('.slide', viewport).width(width).height(height).each(function(i) {
          var self = $(this);
          self.find('img').sizeToFit(self, options.slides[i]);
        });
      },
      buildSlide = function(img, i) {
        var image = $('<div class="image"></div>').append(img);
        return $("<div class='slide'></div>").append(image);
      },
      jumpTo = function(i, wait) {
        var current = viewport.find('.slide').eq(currentIdx),
          next = viewport.find('.slide').eq(i);
                
        if (options.useCss && Modernizr.csstransitions) {
          title.removeClass('visible');
          setTimeout(function() {
            title.text(options.slides[i].title).addClass('visible');
          }, 1000);
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
          title.animate({bottom: -70}, 1000, function() {
            title.text(options.slides[i].title).animate({bottom: 40}, 1000);
            current.fadeOut(options.fadeFor, function() {
              next.css({zIndex: 20});
              current.css({zIndex: 10});
              currentIdx = i;        
            });          
          });
        }
      }, 
      nextSlide = function() {
        var next = currentIdx < options.slides.length - 1 ? currentIdx + 1 : 0;
        jumpTo(next);
      },
      lastSlide = function() {
        var last = currentIdx > 0 ? currentIdx - 1 : options.slides.length - 1;
        jumpTo(last);
      },
      start = function() {
        runningInterval = setInterval(function() {
          nextSlide();
        }, options.waitFor);
      },
      stop = function() {
        clearInterval(runningInterval);
      }
    $('.slide img', viewport).unbind("contextmenu.cancel").bind("contextmenu.cancel", function() { return false; });
    $('.slide img', viewport).unbind("mousedown.cancel").bind("mousedown.cancel", function() { return false; });
    $(window).unbind('resize.slideshow').bind('resize.slideshow', resize);
    element.hide();
    for (i = 0; i < options.slides.length; i++) {
      var img = new Image(),
        size = options.slides[i].size.split('x');
      img.style.width = size[0];
      img.style.height = size[1];
      img.src = options.slides[i].src + '?' + options.version;
      buildSlide(img, i).appendTo(viewport);
    }
    $(document).ready(function() {
      resize();
    });
    $(window).load(function() {
      setTimeout(function() {
        var current = viewport.find('.slide').eq(currentIdx);
        viewport.find('.slide').css({zIndex: 10});
        
        if (options.useCss && Modernizr.csstransitions) {
          element.css('-webkit-transform', 'translateZ(0)');
          title.text(options.slides[currentIdx].title).addClass('visible');
          current.addClass('current');
          current.css({zIndex: 20});
        } else {
          element.addClass('jsanimated');
          title.text(options.slides[currentIdx].title);
          current.css({zIndex: 20}).show();          
        }
        element.show();
        resize();
        resize();
      }, 100);
    });
    
    // $(window).click(function(e) {
    //   e.preventDefault();
    //   nextSlide();
    // });
    return {
      nextSlide: nextSlide,
      lastSlide: lastSlide,
      jumpTo: jumpTo,
      start: start,
      stop: stop
    };
  };
}(jQuery));