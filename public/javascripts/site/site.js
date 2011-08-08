(function(go) {
  $.provide(go, 'Views', {
    site: function() {
      $('#applydialog').modal({
        trigger: '.btnmembership', 
        width: 800,
        onClose: function() {
          alert("ON CLOSE");
          $(this).find('ul.form').removeClass("unlocked").removeClass('unlocking').removeClass("applying").removeClass('unlockable');
        }
      });
      $('#aboutmembership').modal({
        trigger: '.btnmemabout', 
        width: 840,
        
        onClose: function() {
          alert("ON CLOSE");
        }
      });
      var lock = $('#applicationform').find('#application_lock'),
        invitationCode = $('#applicationform').find('#application_invitation_code');
      $('#applicationform').find('.wanttoapply').unbind('click.apply').bind('click.apply', function(e) {
        e.preventDefault();
        var form = $(this).parents('ul.form:first');
        form.addClass('applying');
        lock.attr('disabled', 'disabled');
      });
      lock.unbind('keydown.updatecode').bind('keydown.updatecode', function(e) {
        if (e.keyCode == 13) {
          e.preventDefault();
          $(this).change();
        }
      });
      lock.unbind('change.updatecode').bind('change.updatecode', function(e) {
        var self = $(this),
          form = self.parents('ul.form:first'),
          li = self.parents('li:first'), 
          unlock = $('.unlock');
        if (self.data('lastsent') != self.val() && self.val().toString().length > 0) {            
          self.parents('li:first').removeClass('valid').removeClass('invalid').addClass('loading');
          self.data('lastsent', self.val());
          $.get('/codes/invitation/' + self.val(), function(data) {
            if (data.code && data.code.available) {
              form.addClass('unlockable');
              form.find('.survey input.required').removeAttr('required');
              li.removeClass('loading').removeClass('invalid').addClass('valid');
              form.find('.vouched').html(data.code.voucher + " has vouched for you.").slideDown();
              unlock.unbind('click.unlock').bind('click.unlock', function(e) {
                e.preventDefault();
                unlock.unbind('click.unlock');
                form.removeClass('unlockable').addClass('unlocking');
                setTimeout(function(e) {
                  invitationCode.val(lock.val());
                  lock.attr('disabled', 'disabled');
                  form.removeClass('unlocking').addClass('unlocked')
                }, 1000);
              });
            } else {
              form.find('.vouched').slideUp();
              lock.removeAttr('disabled');
              form.removeClass('unlockable');
              unlock.unbind('click.unlock');
              li.removeClass('loading').removeClass('valid').addClass('invalid');
              form.find('.survey input.required').attr('required', 'required');
            }
          });
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
          scenes.eq(0).animate({left: '-100%'}, 1000);
          scenes.eq(1).animate({left: '0%'}, 500);
        }
        slideshow.stop();
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
      go.PaymentForm.init({form: $('form.new_membership')});
    },
    site_memberships_endpoint: function() {
      go.PaymentForm.init({form: $('form.new_membership')});      
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
        monthScroll = monthTitle.offset().top;
        
      $(window).scroll(function(e) {
        var dates = getDateRange($('#calendar'));
          
        if ($(window).scrollTop() >= monthScroll) {
          monthTitle.addClass('fixed');
        } else {
          monthTitle.removeClass('fixed');
        }
        setTitle(monthTitle.find('.month'), dates.min, dates.max);
      })
    },
    site_accounts: function() {
      go.PaymentForm.init({form: $('ul.form.cc form')});
    }
  });
}(Spot));