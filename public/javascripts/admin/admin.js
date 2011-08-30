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
    admin_promotions_index: function() {
      var bind = function() {
        $('.promotion .reject').unbind('click.rejection').bind('click.rejection', function(e) {
          e.preventDefault();
          $('#rejection_dialog').tmpl({url: $(this).attr('href'), name: $(this).attr('data-name')}).dialog({
            width: 400,
            closeText: '',
            title: "But Why?"
          });
        });
        $('.promotion .submit').unbind('click.rejection').bind('click.rejection', function(e) {
          e.preventDefault();
          var status = $(this).attr('data-status'),
            form = $(this).parents('form'),
            confirmMsg = $(this).attr('data-confirm');
          if (status) {
            form.find('input.promo_status').val(status);
          }
          if ((!confirmMsg || confirm(confirmMsg)) && form.validate()) {
            form.submit();            
          }
        });
        $('.promotion form, ul.reject form').ajaxForm({
          start: function() {
            $(this).parents('.promotion').addClass('loading');
          }, success: function(data) {
            $(this).parents('.promotion').removeClass('loading');
            if (data.success) {
              $('#bd').fadeOut(function() { 
                $('#bd').html(data.html).fadeIn(); 
                bind();
              });
            } else {
              $('.manager .message').addClass('error').html(data.message);
            }
          }, error: function() {
            $(this).parents('.promotion').removeClass('loading');
            $('.manager .message').addClass('error').html("Something went wrong");
          }
        });
      };
      bind();
    },
    admin_acquisition_sources_index: function() {
      $('#urlbuilder').modal({
        title: "Use This URL For Tracking",
        trigger: '.urllink',
        width: 500,
        open: function(target) {
          var url = $(target).attr('href');
          $('#url_builder_base_url').val(url);
          $('#url_builder_value').val(url);
          $(this).find('input.text').unbind('keyup').bind('keyup', function(e) {
            var url = $('#url_builder_base_url').val();
            $('.url_builder_param').each(function(i) {
              if ($(this).val().toString().length > 0) {
                url = url + '&' + $(this).attr('data-q-value') + '=' + $(this).val();                
              }
            });
            $('#url_builder_value').html(url);
          });
        }
      });
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
          });
        });
      });
    }
  });
}(Spot));