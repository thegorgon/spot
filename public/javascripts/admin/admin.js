(function(go) {
  $.provide(go, 'Views', {
    admin_places: function() {
      go.ImageSelector.init('.place_image');
    },
    admin_search: function() {
      go.SearchEmulator.init();
    },
    admin_duplicates: function() {
      $('.ignore a.ajax').ajaxLink({
        start: function() {
          $(this).parents('.duplicate').slideUp();
        }, success: function(data) {
        }
      });
      $('.resolve').ajaxForm({
        start: function() {
          $(this).parents('.duplicate').slideUp();
        }, success: function(data) {
        }
      });
    },
    admin_places_edit: function() {
      go.PlaceForm.init({mapDiv: $('.map')});
    },
    admin_places_new: function() {
      go.PlaceForm.init({mapDiv: $('.map')});
    },
    admin_businesses_index: function() {
      var bindRow = function(row) {
        $('a.verification', row).ajaxLink({
          start: function() {
            $(this).parents('tr').addClass('loading');
          }, success: function(data) {
            var html = $(data.html);
            bindRow(html);
            $(this).parents('tr').replaceWith(html);
          }
        });
      };
      bindRow();
    },
    admin_deals_index: function() {
      var bind = function() {
        $('.deal form').ajaxForm({
          start: function() {
            $(this).parents('.deal').addClass('loading');
          }, success: function(data) {
            $(this).parents('.deal').removeClass('loading');
            if (data.success) {
              $('#bd').fadeOut(function() { 
                $('#bd').html(data.html).fadeIn(); 
                bind();
              });
            } else {
              $('.manager .message').addClass('error').html(data.message);
            }
          }, error: function() {
            $(this).parents('.deal').removeClass('loading');
            $('.manager .message').addClass('error').html("Something went wrong");
          }
        });
      };
      bind();
    },
    admin_home_analysis: function() {
      google.load("visualization", "1", {packages:["corechart"]});
      $('.dateinput').datepicker({dateFormat: 'DD, MM d, yy'});
      
      google.setOnLoadCallback(function() {
        var url = window.location.href;
        $('.chart').addClass('loading');
        $('.chart').each(function(i) {
          var chartDiv = $(this), 
            scope = chartDiv.attr('data-scope');
          $.ajax({
            url: url,
            data: {scope: scope},
            type: "GET",
            dataType: 'json',
            success: function(data) {
              var dt = new google.visualization.DataTable(data),
                chart = new google.visualization[chartDiv.attr('data-type')](chartDiv[0]);
              $.each(data.analysis[scope].cols, function(i) { 
                var col = data.analysis[scope].cols[i];
                dt.addColumn(col.type, col.label, col.id);
              });
              dt.addRows(data.analysis[scope].rows);
              chart.draw(dt, { width: chartDiv.width(), height: chartDiv.height(), title: chartDiv.attr('title'), legend: 'none' });
              chartDiv.removeClass('loading');
            }
          })
        });
      });
    }
  });
}(Spot));