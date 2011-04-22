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
      
      $('#search_form').ajaxForm({
        start: function() {
          var popover = $('#search_results'),
            loadingMsg = popover.find('.loading_msg'),
            query = $(this).find('input#search_query').val(),
            location = $(this).find('input#search_location').val();
          $('#search_results').removeClass('empty').addClass('loading');
          loadingMsg.html("Searching for '" + query + "' near " + location);
          $.popover.resize(popover, loadingMsg, {animateT: 1000});
        }, success: function(data) {
          var bd = $(data.html),
            popover = $('#search_results');
          popover.find('.content .results').html(bd);
          popover.removeClass('loading').removeClass('empty');
          $.popover.resize(popover, bd, {animateT: 1000});
        }
      });
    }
  });
}(Spot));