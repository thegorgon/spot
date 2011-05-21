(function(go) {
  $.provide(go, 'Views', {
    biz_businesses_new: function() {
      $('#search_location').autogeocode({
        ll: $("#search_ll"),
        select: function() {
          if ($('#search_query').val().length > 0) {
            $('#search_form').submit();            
          }
        },
        autocomplete: {
          delay: 0,
          position: {
            offset: "5 -1"
          }
        }
      }).data("autocomplete")._resizeMenu = function() {
        var ul = this.menu.element;
          width = Math.max(ul.width( "" ).outerWidth(), this.element.outerWidth()) - 10;
        ul.outerWidth( width );
      };
      
      $('#search_form').attr('novalidate', 'novalidate').change(function() {
        $(this).validate();
      }).ajaxForm({
        start: function() {
          var popover = $('#search_results'),
            loadingMsg = popover.find('.loading_msg'),
            query = $(this).find('input#search_query').val().replace(' ', '&nbsp;'),
            location = $(this).find('input#search_location').val().replace(' ', '&nbsp;'),
            errorMsg = popover.find('.error_msg'), msg;
          $(this).find('input').blur();
          if ($(this).validate()) {
            popover.setClass('loading', ['empty', 'error']);
            msg = "Searching for '" + query + "'";
            if (location && location.length > 0) { msg += " near " + location; }
            loadingMsg.html(msg);
            $.popover.resize(popover, loadingMsg, {animateT: 1000});            
            return true;
          } else {
            popover.setClass('error', ['empty', 'loading']);
            errorMsg.html("<p>What should we search for?</p>Search for your business using the form on the left.");
            $.popover.resize(popover, errorMsg, {animateT: 1000});            
            return false;
          }
        }, success: function(data) {
          var bd = $(data.html),
            popover = $('#search_results');
          popover.find('.content .results').html(bd);
          popover.setClass(null, ['loading', 'empty', 'error']);
          $.popover.resize(popover, bd, {animateT: 1000});
        }
      });
    },
    biz_businesses_calendar: function() {
      var cal = go.DealCalendar.init({ calendar: '#calendar' });
    },
    biz_businesses_edit: function() {
      go.PlaceForm.init({mapDiv: $('.map')});
    },
    biz_home_widgets: function() {
      var setBusiness = function() {
        var widget = $('#business_select option:selected').val();
        $('.widget .preview .content').html(widget);
        $('.widget .source textarea').val(widget);
      };
      setBusiness();
      $('#business_select').bind('change', function(e) {
        setBusiness();
      });
    },
    biz_discount_codes_index: function() {
      var dateForm = $('#change_date_form'), 
        dateInput = dateForm.find('input.text'),
        bindDynamicContent = function() {
          $('.code_redeem_form').ajaxForm({
            start: function() {
              $(this).parents('.code').addClass('loading');
            }, success: function(data) {
              $(this).parents('.code').removeClass('loading');              
              $('#event_' + data.event_id).html(data.event);
              $('#code_' + data.code_id).html(data.code);
              bindDynamicContent();
            }
          });
        };
      $('#lookup_code_form').ajaxForm({
        start: function() {
          if ($(this).validate()) {
            $(this).parents('ul.form').addClass('loading');            
            return true;
          } else {
            return false;
          }
        },
        success: function(data) {
          $(this).parents('ul.form').removeClass('loading');
          $('.lookup .code').html(data.html);
          bindDynamicContent();
        }
      });
      dateInput.datepicker({dateFormat: 'DD, MM d, yy'});
      dateInput.change(function(e) {
        dateForm.submit();
      });
      dateForm.ajaxForm({
        start: function() {
          $(this).parents('ul.form').addClass('loading');
        }, success: function(data) {
          $(this).parents('ul.form').removeClass('loading');
          $('.codes .data').html(data.html);
          bindDynamicContent();
        }
      });
      bindDynamicContent();
    }
  });
}(Spot));