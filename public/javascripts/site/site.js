(function(go) {
  $.provide(go, 'Views', {
    site: function() {
      var explain = $('#explain_designed_by_spot').hide().removeClass('hidden'),
        showDesignedBySpot = function(self) {
          clearTimeout(self.data('popover-timeout'));
          explain.css({left: 1000}).show();
          var offset = self.offset(),
            left = offset.left - explain.outerWidth() * 0.5 + self.outerWidth() * 0.5,
            top = offset.top - explain.outerHeight();
          explain.css({left: left, top: top});          
          
        },
        lock = $('#applicationform').find('#application_lock'),
        invitationCode = $('#applicationform').find('#application_invitation_code'),
        unlock = $('#applicationform').find('.unlock');
      // Initialize Apply Form Lock
      go.Lock.init({ 
          lock: $('#applicationform').find('#application_lock'),
          invitationCode: $('#applicationform').find('#application_invitation_code'),
          unlock: $('#applicationform').find('.unlock'),
          onUnlock: function(code) {
            $(this).removeClass('unlocking').addClass('unlocked');
          }
      });
      $('.designed_by_spot').unbind('mouseenter.show-explain').bind('mouseenter.show-explain', function(e) {
        var self = $(this);
        self.data('popover-timeout', setTimeout(function() { showDesignedBySpot(self); }, 500));
      }).unbind('mouseleave.hide-expain').bind('mouseleave.hide-explain', function(e) {
        clearTimeout($(this).data('popover-timeout'));
        explain.hide();
      });
      $('.designed_by_spot').unbind('click.show-explain').bind('click.show-explain', function(e) {
        e.preventDefault();
        e.stopPropagation();
        showDesignedBySpot($(this));
      });
      if (!$.mobile()) {
        $('#aboutmembership').modal({
          trigger: '.btnmemabout', 
          width: 840,
          open: function() {
            go.Events.pageView('/membership/about');
            go.Events.analytics('Acquisition', 'Membership Dialog Launch');
          }
        });
        $('#applydialog').modal({
          trigger: '.btnmembership', 
          width: 800,
          open: function() {
            go.Events.pageView('/application/new');
            go.Events.analytics('Acquisition', 'Apply Dialog Launch');
          }
        });
        if ($('#applydialog').hasClass('autoopen')) {
          $('#applydialog').dialog("open");
        }      
      }
    },
    site_blog: function() {
      $('#invite_request_form').ajaxForm({
        start: function() {
          if ($(this).validate()) {
            $(this).parents('.overlay').addClass('received');
            $('#explore_city_link').attr('href', '/cities/redirect?id=' + $(this).find('#request_city_id').val());            
            return true;
          } else {
            return false;
          }
        }
      });
    },
    site_home_index: function() {
      var slides, slideshow, top, scenes, initMap, tabs;
      
      slides = [
        {slide: '/images/assets/slideshow/slide1.jpg', size: '2292x1524', title: 'Sommelier Wine Pairing at Credo', gravity: '0.5x0.5'},
        {slide: '/images/assets/slideshow/slide2.jpg', size: '2292x1524', title: 'Complimentary Beer with Dinner at Schmidt\'s', gravity: '1.0x1.0'},
        {slide: '/images/assets/slideshow/slide3.jpg', size: '2292x1524', title: 'Six Course Tasting Menu & VIP Kitchen Tour at Spruce', gravity: '0.5x0.5'},
        {slide: '/images/assets/slideshow/slide4.jpg', size: '2292x1524', title: "Chef's Evening at Epic Roasthouse", gravity: '1.0x1.0'},
        {slide: '/images/assets/slideshow/slide5.jpg', size: '2292x1524', title: "Free Bonus Cupcake at Mission Mini's", gravity: '0.5x0.5'}
      ];
      
      if ($.mobile) {
        $.each(slides, function(i) {
          this.slide = this.slide.replace(/\.jpg/i, '_mobile.jpg');
        });
      }
      
      slideshow = $("#slidedeck").slideshow({
        title: '#slidetitle',
        start: Math.floor(Math.random()* slides.length),
        slides: slides
      });
      
      top = $('#toplayer');
      
      
      scenes = top.find('.scene');
      
      initMap = function(fn) {
        $('html, body').animate({scrollTop: 0}, 100);
        if (Modernizr.csstransitions) { top.addClass('scene2'); }
        else { 
          top.addClass('jsanimation');
          scenes.eq(0).animate({left: '-100%'}, 1000);
          scenes.eq(1).animate({left: '0%'}, 750);
        }
        slideshow.stop();
        if (fn) {
          $('.city').unbind('click.submit').bind('click.submit', function(e) {
            e.preventDefault();
            fn.call(this);
          });
        }
      };
      
      tabs = $('.entrance').find('.tab');
            
      tabs.unbind('click.tabs').bind('click.tabs', function(e) {
        var rel = $(this).attr('rel') ? $(this).attr('rel') : this;
        e.preventDefault();
        tabs.each(function(i) {
          $(this).removeClass('active');
          $('.entrance').removeClass($(this).attr('data-class'));
        });
        $(rel).addClass('active');
        $('.entrance').addClass($(this).attr('data-class'));
      });
      
      $('#email_form').unbind('submit.continue').bind('submit.continue', function(e) {
        e.preventDefault();
        if ($(this).validate()) {
          var rForm = $('#invite_request_form');
          rForm.find('#invite_request_email').val($(this).find('#email_email').val());
          go.Events.analytics('Acquisition', 'Email Entered');
          initMap(function() {
            rForm.find('#invite_request_city_id').val($(this).attr('data-id'));
            go.Events.analytics('Acquisition', 'City Selected');
            rForm.submit();
          });          
        }
      });
      // Initialize Invitation Lock
      go.Lock.init({ 
          lock: $('#invitation_code'),
          invitationCode: $('#invitation_code_value'),
          unlock: $('#invite_form').find('.unlock'),
          onUnlock: function(code) {
            initMap(function() {
              var form = $('#invitation_submit_form');
              $('#invitation_city_id').val($(this).attr('data-id'));
              form.submit();
            });
          }
      });
      
      $('#select_city_link').unbind('click').bind('click', function(e) {
        e.preventDefault();
        var accountForm = $('#account_update_form');
        initMap(function() {
          accountForm.find('#account_city_id').val($(this).attr('data-id'));
          accountForm.find('#account_redirect_to').val($(this).attr('href'));
          accountForm.submit();          
        });
      });
    },
    site_home_press: function() {
      go.AppPreview.init();
    },
    site_events_show: function() {
      if ($('#claimdialog').length > 0) {
        var bind = function() {
          $('.btnclaim').unbind('click.modal').bind('click.modal', function(e) {
            e.preventDefault();
            $('#code_event_id').val($(this).attr('data-eid'));        
            $('#claimdialog').dialog("open");
            $('#claimdialog').find('.cancel').unbind('click').click(function(e) {
              $('#claimdialog').dialog("close");
              $('#code_event_id').val("");
            });
          });
        };
        $('#claimdialog').modal({
          width: 620, 
          close: function() {
            $('#claimdialog').removeClass('loading').removeClass('claimed');
          }
        });
        go.ClaimForm.init({
          form: '#claimform', 
          dialog: '#claimdialog', 
          calendar: '#calendar', 
          complete: bind
        });
        bind();
      }
      try {
        var canvas = $('canvas#timewedge'),
          context = canvas[0].getContext('2d'),
          startangle = canvas.attr('data-start-hour') * 0.08333 * 2 * Math.PI - Math.PI * 0.5,
          endangle = canvas.attr('data-end-hour')  * 0.08333 * 2 * Math.PI  - Math.PI * 0.5,
          height = canvas.attr('height') * 1.0,
          width = canvas.attr('width') * 1.0,
          center = [Math.floor(0.5 * width) + 0.5, Math.floor(0.5 * height) + 0.5],
          radius = width * 0.5;
        context.beginPath();
        context.moveTo(center[0], center[1]);
        context.strokeStyle = 'rgba(0,0,0,0.2);';
        context.fillStyle = 'rgba(85,165,0,0.2)';
        context.lineJoin = "miter";
        if (startangle == endangle) {
          context.arc(center[0], center[1], radius, 0, Math.PI * 2);          
          context.fill();
        } else {
          context.arc(center[0], center[1], radius, startangle, endangle);          
          context.lineTo(center[0], center[1]);
          context.closePath();
          context.fill();
          context.stroke();
        }
      } catch(e) {
      }      
    },
    site_registrations_new: function() {
      go.ClaimForm.init({
        form: '#claimform', 
        dialog: '#claimdialog'
      });
    },
    site_memberships_new: function() {
      go.PaymentForm.init({form: $('form.new_membership')});
    },
    site_memberships_endpoint: function() {
      go.PaymentForm.init({form: $('form.new_membership')});      
    },
    site_cities: function() {
      $('form#city_preview').find('#email_subscription_city_id').unbind('change.showother').bind('change.showother', function(e) {
        if ($(this).val().toString() == "-1") {
          $('#othercityfields').hide().removeClass('hidden').slideDown();
        } else {
          $('#preview_city').val('');
          $('#othercityfields').slideUp();
        }
      });
      var getDateRange = function(calendar) {
          var allDates = [],
            dates = {min: null, max: null},
            scrollTop = $(window).scrollTop(),
            scrollBottom = scrollTop + $(window).height();
          calendar.find('.date').each(function(i) {
            var offset = $(this).offset(),
              visible = offset.top >= scrollTop + 20 && offset.top <= scrollBottom - 150,
              date = Date.parse($(this).attr('data-date'));
            if (visible) { 
              allDates.push(date); }
          });
          if (allDates.length > 0) {
            dates.min = new Date(allDates.min());
            dates.max = new Date(allDates.max());            
          }
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
        },
        monthTitle = $('#calendar .month_title'),
        monthScroll = (monthTitle.offset() || {}).top;
      if (monthTitle.length > 0) {        
        $(window).scroll(function(e) {
          var dates = getDateRange($('#calendar'));

          if ($(window).scrollTop() >= monthScroll) {
            monthTitle.addClass('fixed');
          } else {
            monthTitle.removeClass('fixed');
          }
          setTitle(monthTitle.find('.month'), dates.min, dates.max);
        });
      }
    },
    site_accounts: function() {
      go.PaymentForm.init({form: $('ul.form.cc form')});
    },
    site_sweepstakes_show: function() {
      $('#entry_form form').ajaxForm({
        start: function() {
          if ($(this).validate()) {
            $(this).addClass('loading');
            return true;
          } else {
            return false;
          }
        },
        success: function(data) {
          $(this).removeClass('loading');
          if (data.success) {
            $('#entry_description').html(data.html);
            go.Behaviors.train('#entry_description');
            $('.apply').addClass('applied');
            $('#entered_dialog').tmpl(data.entry).modal({
              autoOpen: true,
              width: 340
            });
            addthis.toolbox('.addthis_toolbox');
          } else {
            $(this).find('.errors').text(data.errors.join(', '));
          }
        },
        error: function() {
          $(this).removeClass('loading');
          $(this).find('.errors').text("Something went wrong. Please try again.");
        }
      });
    }
  });
}(Spot));