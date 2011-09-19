(function(go) {
  $.provide(go, 'Views', {
    admin: function() {
      $('#search_query_text').autocomplete({
        source: $('#places_search_form').attr('action'),
        minLength: 2,
        focus: function(event, ui) {  
          if (ui.item) {
            $('#search_query_text').val(ui.item.name);
            return false;
          }
          return true;
        },
        search: function(event, ui) {
          $('#search_query_text').parents('.accept_focus').addClass('loading');
        },
        open: function(event, ui) {
          $('#search_query_text').parents('.accept_focus').removeClass('loading');          
        },
        select: function( event, ui ) {
          if (ui.item) {
            window.location = "/admin" + ui.item.path;
            return false;
          }
          return true;
        },
        position: {of: "#places_search_form", my: "left top", at: "left bottom"}
      });
      $('#search_query_text').data( "autocomplete" )._renderItem = function( ul, item ) {
        return $( "<li></li>" )
          .data( "item.autocomplete", item )
          .append( "<a>" + item.name  + "</a>" )
          .appendTo( ul );
      };
      $('#search_query_text').data( "autocomplete" )._resizeMenu = function() {
        var ul = this.menu.element;
        ul.css({width: this.element.outerWidth()});
      };
    },
    admin_places: function() {
      go.ImageSelector.init('.place_image');
    },
    admin_activity_items: function() {
      go.ImageSelector.init('.place_image');
      go.EmulatorForm.init();
    },
    admin_search: function() {
      go.EmulatorForm.init();
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
    admin_membership_codes: function() {
      $('#code_form').find('#membership_code_promo_code').bind('click', function(e) {
        var inputs = $('#promo_code_fields').find('input, textarea');
        if ($(this).is(':checked')) {
          inputs.removeAttr('disabled')
        } else {
          inputs.attr('disabled', 'disabled');
          inputs.removeAttr('aria-invalid');
          $(this).removeAttr('disabled');
        }
      });
      $('#code_form').find('#membership_code_invite_code').bind('click', function(e) {
        var inputs = $('#invite_code_fields').find('input, textarea');
        if ($(this).is(':checked')) {
          inputs.removeAttr('disabled')
        } else {
          inputs.attr('disabled', 'disabled');
          inputs.removeAttr('aria-invalid');
          $(this).removeAttr('disabled');
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
        $('.tinymce textarea').tinymce({
          script_url : '/javascripts/vendor/tiny_mce/tiny_mce.js',
          theme: "advanced",
          plugins : "autolink,lists,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,advlist",
          theme_advanced_buttons1 : "bold,bullist,numlist,link,unlink",
          theme_advanced_buttons2 : "",
          theme_advanced_buttons3 : "",
          theme_advanced_buttons4 : "",
          theme_advanced_toolbar_location : "top",
          theme_advanced_toolbar_align : "left",
          theme_advanced_statusbar_location : "none",
          theme_advanced_resizing : true
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
                url = url + '&' + $(this).attr('data-q-value') + '=' + encodeURIComponent($(this).val());
              }
            });
            $('#url_builder_value').val(url);
          });
        }
      });
    },
    admin_acquisition_sweepstakes: function() {
      $('li.dateinput input').datepicker({dateFormat: 'DD, MM d, yy'});
      $('.tinymce textarea').tinymce({
        script_url : '/javascripts/vendor/tiny_mce/tiny_mce.js',
        theme: "advanced",
        plugins : "autolink,lists,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,advlist",
        theme_advanced_buttons1 : "bold,bullist,numlist,link,unlink",
        theme_advanced_buttons2 : "",
        theme_advanced_buttons3 : "",
        theme_advanced_buttons4 : "",
        theme_advanced_toolbar_location : "top",
        theme_advanced_toolbar_align : "left",
        theme_advanced_statusbar_location : "none",
        theme_advanced_resizing : true
      });
      $('#sweepstake_place_name').autocomplete({
        source: '/admin/places/search',
        minLength: 2,
        focus: function(event, ui) {  
          if (ui.item) {
            $('#sweepstake_place_name').val(ui.item.name);
            return false;
          }
          return true;
        },
        search: function(event, ui) {
          $('#sweepstake_place_name').parents('.accept_focus').addClass('loading');
        },
        open: function(event, ui) {
          $('#sweepstake_place_name').parents('.accept_focus').removeClass('loading');          
        },
        select: function( event, ui ) {
          if (ui.item) {
            $('#sweepstake_place_id').val(ui.item.id)
            $('#sweepstake_place_name').val(ui.item.name)
            $.validations.validity($('#sweepstake_place_name'), true, "");
          } else {
            $.validations.validity($('#sweepstake_place_name'), false, "is not a valid place");
          }
          return false;
        }
      });
      $('#sweepstake_place_name').data( "autocomplete" )._renderItem = function( ul, item ) {
        return $( "<li></li>" )
          .data( "item.autocomplete", item )
          .append( "<a>" + item.name  + "</a>" )
          .appendTo( ul );
      };
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