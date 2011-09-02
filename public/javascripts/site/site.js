(function(go) {
  $.provide(go, 'Views', {
    site: function() {
      var explain = $('#explain_designed_by_spot').hide().removeClass('hidden'),
        showDesignedBySpot = function(self) {
          clearTimeout(self.data('popover-timeout'));
          explain.css({left: 1000}).show()
          var offset = self.offset(),
            left = offset.left - explain.outerWidth() * 0.5 + self.outerWidth() * 0.5,
            top = offset.top - explain.outerHeight();
          explain.css({left: left, top: top});          
          
        },
        lock = $('#applicationform').find('#application_lock'),
        invitationCode = $('#applicationform').find('#application_invitation_code'),
        unlock = $('#applicationform').find('.unlock');
      $('#applicationform').find('.wanttoapply').unbind('click.apply').bind('click.apply', function(e) {
        e.preventDefault();
        var form = $(this).parents('ul.form:first');
        form.removeClass('unlocking').removeClass('unlocked').removeClass('unlockable').addClass('applying');
        lock.attr('disabled', 'disabled').val('');
        form.find('.vouched').html('');
      });
      $('#applicationform').find('.haveaninvite').unbind('click.apply').bind('click.apply', function(e) {
        e.preventDefault();
        var form = $(this).parents('ul.form:first');
        form.removeClass('applying').removeClass('unlocked').removeClass('unlockable');
        lock.removeAttr('disabled').val('')
        form.find('.vouched').html('');
      });
      lock.unbind('keyup.updatecode').bind('keyup.updatecode', function(e) {
        var self = this, 
          timeout = $(self).data('change-timeout'),
          li = $(self).parents('li:first');
        if (e.keyCode == 13) {
          e.preventDefault();
          $(self).change();
        } else {
          li.removeClass('valid').removeClass('invalid');
          if ($(self).val() == '') {
            li.removeClass('loading');
          } else {
            li.addClass('loading');
          }
          clearTimeout(timeout);
          $(self).data('change-timeout', setTimeout(function() {
            $(self).change();
          }, 1000));
        }
      });
      unlock.unbind('click.unlock').bind('click.unlock', function(e) {
        e.preventDefault();
        var form = $(this).parents('ul.form:first');
        if (invitationCode.val() != '') {
          form.addClass('unlocking');
          setTimeout(function(e) {
            lock.attr('disabled', 'disabled');
            form.removeClass('unlocking').addClass('unlocked')
          }, 1000);          
        }
      });
      lock.unbind('change.updatecode').bind('change.updatecode', function(e) {
        var self = $(this),
          form = self.parents('ul.form:first'),
          li = self.parents('li:first'); 
        if (self.data('lastsent') != self.val() && self.val().toString().length > 0) {            
          self.parents('li:first').removeClass('valid').removeClass('invalid').addClass('loading');
          self.data('lastsent', self.val());
          $.get('/codes/invitation/' + self.val(), function(data) {
            if (data.code && data.code.available) {
              form.addClass('unlockable');
              li.removeClass('loading').removeClass('invalid').addClass('valid');
              invitationCode.val(lock.val());
              form.find('.vouched').html(data.code.voucher + " has vouched for you.").slideDown();
            } else {
              form.find('.vouched').slideUp();
              lock.removeAttr('disabled');
              form.removeClass('unlockable');
              unlock.unbind('click.unlock');
              li.removeClass('loading').removeClass('valid').addClass('invalid');
            }
          });
        }
      });
      $('#aboutmembership').modal({
        trigger: '.btnmemabout', 
        width: 840,
        open: function() {
          go.Events.pageView('/membership/about')
          go.Events.analytics('Acquisition', 'Membership Dialog Launch')
        }
      });   
      $('.designed_by_spot').unbind('mouseenter.show-explain').bind('mouseenter.show-explain', function(e) {
        var self = $(this);
        self.data('popover-timeout', setTimeout(function() { showDesignedBySpot(self) }, 500));
      }).unbind('mouseleave.hide-expain').bind('mouseleave.hide-explain', function(e) {
        clearTimeout($(this).data('popover-timeout'));
        explain.hide();
      });
      $('.designed_by_spot').unbind('click.show-explain').bind('click.show-explain', function(e) {
        e.preventDefault();
        e.stopPropagation();
        showDesignedBySpot($(this));
      });
      $('#applydialog').modal({
        trigger: '.btnmembership', 
        width: 800,
        open: function() {
          go.Events.pageView('/application/new')
          go.Events.analytics('Acquisition', 'Apply Dialog Launch')
        }
      });
      if ($('#applydialog').hasClass('autoopen')) {
        $('#applydialog').dialog("open");
      }      
    },
    site_home_index: function() {
      var slideshow = $("#slidedeck").slideshow({
          title: '#slidetitle',
          start: Math.floor(Math.random()* $("#slidedeck").find('.slide').length),
          slides: [
            {slide: '/images/assets/slideshow/slide1.jpg', size: '2292x1524', title: 'Sommelier Wine Pairing at Credo', gravity: '0.5x0.5'},
            {slide: '/images/assets/slideshow/slide2.jpg', size: '2292x1524', title: 'Complimentary Beer with Dinner at Schmidt\'s', gravity: '1.0x1.0'},
            {slide: '/images/assets/slideshow/slide3.jpg', size: '2292x1524', title: 'Six Course Tasting Menu & VIP Kitchen Tour at Spruce', gravity: '0.5x0.5'},
            {slide: '/images/assets/slideshow/slide4.jpg', size: '2292x1524', title: "Chef's Evening at Epic Roasthouse", gravity: '1.0x1.0'},
            {slide: '/images/assets/slideshow/slide5.jpg', size: '2292x1524', title: "Free Bonus Cupcake at Mission Mini's", gravity: '0.5x0.5'}
          ]
        }), 
        top = $('#toplayer'), 
        scenes = top.find('.scene'),
        initMap = function(fn) {
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
      
      slideshow.start();
      $('#email_form').unbind('submit.continue').bind('submit.continue', function(e) {
        e.preventDefault();
        if ($(this).validate()) {
          var sxnForm = $('#subscription_form');
          sxnForm.find('#email_subscription_email').val($(this).find('#email_email').val());
          go.Events.analytics('Acquisition', 'Email Entered')
          initMap(function() {
            sxnForm.find('#email_subscription_city_id').val($(this).attr('data-id'));
            go.Events.analytics('Acquisition', 'City Selected')
            sxnForm.submit();
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
    }
  });
}(Spot));