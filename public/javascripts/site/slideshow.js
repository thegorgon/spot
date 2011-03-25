(function($) {
  $.fn.sizeToFit = function(container, options) {
    container = $(container);
    var resize = $(this),
      rH = resize.height(), rW = resize.width(),
      cW = container.width(), cH = container.height(),
      cRatio = (cH / cW).toFixed(2), rRatio = ( rH / rW).toFixed(2),
      dims = {}, off = {}, scale;
    if (cRatio > rRatio) {
      dims.h = cH;
      dims.w = cH/rRatio;
      scale = dims.h/rH;
    } else {
      dims.w = cW;
      dims.h = cW * rRatio;
      scale = dims.w/rW;
    }
    resize.width(dims.w);
    resize.height(dims.h);
    off.top = 0.5 * (cH - dims.h);
    off.left = 0.5 * (cW - dims.w);
    resize.css({top: off.top, left: top.left});
    return scale;
  };
  $.fn.slideshow = function(opts) {
    var element = $(this),
      slidereel = element.find('#slidereel'),
      logo = element.find('#logo').find('img');
      settings = {
        slides: [],
        start: -1
      }, loadCount = 0, i = 0,
      options = $.extend(settings, opts || {}),
      currentSlide = options.start > 0 ? options.start : Math.round(Math.random() * (options.slides.length - 1)),
      slidenav = element.find('#slidenav'),
      navList = $('<ul class="clearfix"></ul>').appendTo(slidenav),
      resize = function() {
        element.each(function() {
          var width = $(this).width(),
            height = $(this).height();
          slidereel.width(options.slides.length * width).height(height).css({left: -1 * currentSlide * width});
          $('.slide', slidereel).width(width).height(height).each(function(i) {
            var thisSlide = $(this),
              left = i * width, newRatio,
              scale = thisSlide.css({left: left}).find('img').sizeToFit(thisSlide, options.slides[i]);
            //   logoW = logo.width() * scale,
            //   logoH = logo.height() * scale;
            // if (logoW >= 500) {
            //   logoH = 500 * logoH/logoW;
            //   logoW = 500;
            // } else if (logoW <= 250) {
            //   logoH = 250 * logoH/logoW;
            //   logoW = 250;
            // }
            // logo.width(logoW);
            // logo.height(logoH);
          });
        });
      },
      buildSlide = function(img, i) {
        var slide = $("<div class='slide'></div>"),
          navLink = $('<li id="slidenav_' + i + '" class="slidenav"></li>');
        navList.append(navLink);
        navList.width(navList.width() + navLink.width());
        return slide.append(img);
      },
      loaded = function() {
        loadCount = loadCount + 1;
        if (loadCount == options.slides.length) {
          jumpTo(currentSlide);
          $('.slidenav', slidenav).unbind('click.slideshow').bind('click.slideshow', function(e) {
            e.preventDefault();
            jumpTo(this.id.split('_')[1]);
          });
          element.fadeIn(1000);
          setTimeout(resize, 1);
        }
      },
      jumpTo = function(i) {
        currentSlide = i;
        $('.slidenav').removeClass('selected');
        $('#slidenav_' + currentSlide).addClass('selected');        
        slidereel.animate({left: -1 * currentSlide * element.width()});
      };
    $('.slide img', slidereel).unbind("contextmenu.cancel").bind("contextmenu.cancel", function() { return false; });
    $('.slide img', slidereel).unbind("mousedown.cancel").bind("mousedown.cancel", function() { return false; });
    $(window).unbind('resize.slideshow').bind('resize.slideshow', resize);
    element.hide();
    for (i = 0; i < options.slides.length; i++) {
      var img = new Image();
      img.onload = loaded;
      img.src = options.slides[i].src;
      buildSlide(img, i).appendTo(slidereel);
    }
    return {
      nextSlide: function() {
        currentSlide = currentSlide + 1 >= options.slides.length ? 0 : currentSlide + 1;
        jumpTo(currentSlide);
      },
      jumpTo: function(i) {
        jumpTo(i);
      }
    };
  };
}(jQuery));