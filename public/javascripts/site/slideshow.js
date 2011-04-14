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
      dims.w = Math.round(cH/rRatio);
    } else {
      dims.w = cW;
      dims.h = Math.round(cW * rRatio);
    }
    off.top = Math.round(gravityTop * (cH - dims.h));
    off.left = Math.round(gravityLeft * (cW - dims.w));
    resize.css({'position': 'absolute', 'width': dims.w, 'height': dims.h, 'top': off.top, 'left': off.left});
  };
  $.fn.slideshow = function(opts) {
    var element = $(this),
      slidereel = element.find('#slidereel'),
      viewport = element.find('#viewport'),
      nextControl = element.find('#nextslide'),
      lastControl = element.find('#lastslide'),
      settings = {
        slides: [],
        start: 0,
        version: 1
      }, loadCount = 0, i = 0, finalized = false,
      options = $.extend(settings, opts || {}),
      currentSlide = options.start,
      slidenav = element.find('#slidenav'),
      navList = $('<ul class="clearfix"></ul>').appendTo(slidenav),
      resize = function() {
        $.logger.debug("Resizing slideshow");
        var width = viewport.width(),
          height = viewport.height();
        slidereel.width(options.slides.length * width).height(height).css({left: Math.round(-1 * currentSlide * width)});
        $('.slide', slidereel).width(width).height(height).each(function(i) {
          var thisSlide = $(this),
            left = i * width;
          thisSlide.css({left: left}).find('img').sizeToFit(thisSlide, options.slides[i]);
        });
      },
      buildSlide = function(img, i) {
        var slide = $("<div class='slide'></div>"),
          navLink = $('<li class="slidenav"></li>');
        navLink.bind("click", function() { jumpTo(i); });
        navList.append(navLink);
        navList.width(navList.width() + navLink.width());
        return slide.append(img);
      },
      loaded = function() {
        loadCount = loadCount + 1;
        if (loadCount >= options.slides.length && !finalized) {
          finalized = true;
          setTimeout(resize, 1);
          setTimeout(function() { jumpTo(currentSlide, false); }, 1);
          element.fadeIn(250);
        }
      },
      jumpTo = function(i) {
        currentSlide = i;
        if (currentSlide === 0) {
          lastControl.fadeOut(1000);
          nextControl.fadeIn(1000);
        } else if (currentSlide === options.slides.length - 1) {
          lastControl.fadeIn(1000);
          nextControl.fadeOut(1000);
        } else {
          lastControl.fadeIn(1000);
          nextControl.fadeIn(1000);
        }
        $('.slidenav').removeClass('selected');
        $('.slidenav').eq(i).addClass('selected');
        slidereel.animate({left : -1 * currentSlide * viewport.width()}, 1500);
      }, 
      nextSlide = function() {
        if (currentSlide < options.slides.length - 1) {
          jumpTo(currentSlide + 1);          
        }
      },
      lastSlide = function() {
        if (currentSlide > 0) {
          jumpTo(currentSlide - 1);
        }
      };
    $('.slide img', slidereel).unbind("contextmenu.cancel").bind("contextmenu.cancel", function() { return false; });
    $('.slide img', slidereel).unbind("mousedown.cancel").bind("mousedown.cancel", function() { return false; });
    $(window).unbind('resize.slideshow').bind('resize.slideshow', resize);
    element.hide();
    for (i = 0; i < options.slides.length; i++) {
      var img = new Image(),
        size = options.slides[i].size.split('x');
      img.width = size[0];
      img.height = size[1];
      img.onload = loaded;
      img.src = options.slides[i].src + '?' + options.version;
      buildSlide(img, i).appendTo(slidereel);
    }
    nextControl.click(nextSlide);
    lastControl.click(lastSlide);
    viewport.swipe({
      threshold: { x: 25, y: 100},
      swipeLeft: function() { nextSlide(); },
      swipeRight: function() { lastSlide(); },
      swipeDown: function(y) { window.scrollTo(0, 1000) },
      swipeUp: function(y) { window.scrollTo(0, -60) }
    });
    return {
      nextSlide: nextSlide,
      lastSlide: lastSlide,
      jumpTo: jumpTo
    };
  };
}(jQuery));