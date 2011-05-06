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
      var cal = Spot.DealCalendar.init({ calendar: '#calendar' });
    }
  });
}(Spot));