(function(go) {
  $.provide(go, 'Views', {
    site: function() {
      $('#applydialog').modal({trigger: '.btnmembership', width: 875});
    },
    site_blog: function() {
      $('#pagination a').ajaxLink({
        click: function() {
          var posts = $('#posts');
          posts.fadeOut(function() {
            posts.trigger('faded');
          });
        },
        success: function(data) {
          var html = $(data.html).find("#posts"), posts = $('#posts');
          posts.bind("faded", function() {
            posts.html(html.html()).unbind("faded");
            posts.fadeIn(function() {
              go.Views.run();
            });
          });
          if (!posts.is(":animated")) {
            posts.trigger("faded");            
          }
        }
      });
    },
    site_home_index: function() {
      var slideshow = $("#slidedeck").slideshow({
          title: '#slidetitle',
          start: Math.floor(Math.random()* $("#slidedeck").find('.slide').length)
        }), top = $('#toplayer'), scenes = top.find('.scene');
      
      slideshow.start();
      $('.enter').click(function(e) {
        e.preventDefault();
        if (Modernizr.cssTransitions) { top.addClass('scene2'); }
        else { 
          top.addClass('jsanimation');
          scenes.eq(0).animate({left: '-100%'});
          scenes.eq(1).animate({left: '0%'});
          scenes.eq(2).animate({left: '100%'});
        }
        slideshow.stop();
      });
      $('.map .city').click(function(e) {
        if (Modernizr.cssTransitions) { top.addClass('scene3'); }
        else { 
          scenes.eq(0).animate({left: '-200%'});
          scenes.eq(1).animate({left: '-100%'});
          scenes.eq(2).animate({left: '0%'});
        }
      });
    },
    site_home_press: function() {
      go.AppPreview.init();
    },
    site_events_show: function() {
      var bind = function() {
        $('.btnclaim').unbind('click.modal').bind('click.modal', function(e) {
          e.preventDefault();
          $('#code_event_id').val($(this).attr('data-eid'));        
          $('#claimdialog').dialog("open");
        });
      };
      $('#claimdialog').modal({
        width: 620, 
        close: function() {
          $('#claimdialog').removeClass('loading').removeClass('claimed');
        }
      });
      try {
        var canvas = $('canvas#timewedge'),
          context = canvas[0].getContext('2d'),
          startangle = canvas.attr('data-start-hour') * 0.08333 * 2 * Math.PI - Math.PI * 0.5,
          endangle = canvas.attr('data-end-hour')  * 0.08333 * 2 * Math.PI  - Math.PI * 0.5,
          height = canvas.attr('height') * 1.0,
          width = canvas.attr('width') * 1.0,
          center = [Math.floor(0.5 * width) + 0.5, Math.floor(0.5 * height) + 0.5],
          radius = 73;
        context.beginPath();
        context.moveTo(center[0], center[1]);
        context.strokeStyle = 'rgba(0,0,0,0.2);';
        context.fillStyle = 'rgba(85,165,0,0.2)';
        context.lineJoin = "miter";
        context.arc(center[0], center[1], radius, startangle, endangle);
        context.lineTo(center[0], center[1]);
        context.closePath();
        context.fill();
        context.stroke();
      } catch(e) {
      }
      $('#claimform').ajaxForm({
        start: function(){
          $('#claimdialog').addClass('loading');
        },
        success: function(data) {
          $('#claimdialog').removeClass('loading').addClass('claimed');
          if (data.error) {
            $('#claimdialog').find('.code').html($("<div class='error'></div>").html(data.error));
          } else {
            $('#claimdialog').find('.code').html(data.code);
            go.Behaviors.train($('#claimdialog').find('.code'));
            $('#calendar').html(data.calendar);
            bind();
          }
        },
        error: function() {
          $('#claimdialog').find('.code').html($("<div class='error'></div>").html("Sorry, something went wrong, please refresh this page and try again."));
          $('#claimdialog').removeClass('loading').addClass('claimed');          
        }
      });
      bind();
    },
    site_memberships_new: function() {
      go.PaymentForm.init({form: $('form')});
    },
    site_memberships_endpoint: function() {
      go.PaymentForm.init({form: $('form')});      
    },
    site_cities_new: function() {
      $('#preview_city').autogeocode();
    },
    site_cities_calendar: function() {
      var getDateRange = function(calendar) {
          var allDates = [],
            dates = {min: null, max: null},
            scrollTop = $(window).scrollTop(),
            scrollBottom = scrollTop + $(window).height();
          calendar.find('.date').each(function(i) {
            var offset = $(this).offset(),
              visible = offset.top >= scrollTop + 20 && offset.top <= scrollBottom - 150,
              date = Date.parse($(this).attr('data-date'));
            if (visible) { allDates.push(date); }
          });
          dates.min = new Date(allDates.min());
          dates.max = new Date(allDates.max());
          return dates;
        },
        setTitle = function(title, minDate, maxDate) {
          var text;
          if (minDate && maxDate) {
            text = minDate.getMonthName();
            if (minDate.getFullYear() != maxDate.getFullYear()) {
              text = text + " " + minDate.getFullYear();
            }
            if (minDate.getFullYear() != maxDate.getFullYear() || minDate.getMonth() != maxDate.getMonth()) {
              text = text + " - ";
              text = text + maxDate.getMonthName();
            }
            text = text + " " + maxDate.getFullYear();        
            title.text(text);        
          }
        };
      
      $(window).scroll(function(e) {
        var scroll = $(window).scrollTop(),
          monthName = $('#calendar .month_title'),
          dates = getDateRange($('#calendar'));
          
        if (scroll >= 320) {
          monthName.addClass('fixed');
        } else {
          monthName.removeClass('fixed');
        }
        setTitle(monthName.find('.month'), dates.min, dates.max);
      })
    },
    site_accounts: function() {
      go.PaymentForm.init({form: $('ul.form.cc form')});
    }
  });
}(Spot));