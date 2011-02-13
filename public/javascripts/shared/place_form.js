(function(go) {
  var _options,
      _geocoder,
      _geocodeMarkers = [],
      _map,
      mapOpts = function(options) {
        return $.extend({ center: _options.position, 
                   zoom: 15, 
                   mapTypeId: google.maps.MapTypeId.ROADMAP }, options);
      },
      newMarker = function(options) {
        options = $.extend({map: _map}, options);
        return new google.maps.Marker(options);
      },
      getFormPosition = function() {
        return new google.maps.LatLng($('#place_lat').val(), $('#place_lng').val());
      },
      setFormPosition = function(newLL) {
        $('#place_lat').val(newLL.lat());
        $('#place_lng').val(newLL.lng());
        $('.latlng').html("@" + newLL.lat() + ',' + newLL.lng());
        _marker.setPosition(newLL);
        _map.panTo(newLL);
        return newLL;
      },
      getAddress = function() {
        return $('#place_address_lines_0').val() + ' ' + $('#place_address_lines_1').val();
      },
      getName = function() {
        return $('#place_full_name').val();
      },
      getCity = function() {
        return $('#place_city').val();
      },
      clearGeocodeMarkers = function() {
        _map.setZoom(mapOpts().zoom);
        _map.panTo(_marker.getPosition());
        $.each(_geocodeMarkers, function(i) { this.setMap(null) });        
        _geocodeMarkers = [];
      },
      addGeocodeMarker = function(result) {
        var marker = newMarker({clickable: true, position: result.geometry.location}),
          bounds = _map.getBounds();
        bounds.extend(marker.getPosition());
        _map.fitBounds(bounds);
        _geocodeMarkers.push(marker);     
        google.maps.event.addListener(marker, 'click', function(e) {
          setFormPosition(this.getPosition());
          $.logger.debug(this);
          clearGeocodeMarkers();
        });         
        marker.setMap(_map);
      },
      geocode = function(address) {
        _geocoder.geocode({ 'address': address }, function(results, status) {
          if (status == google.maps.GeocoderStatus.OK) {
            clearGeocodeMarkers();
            $.each(results, function(i) {
              addGeocodeMarker(this);
            });
          } else {
            alert("Geocode was not successful for the following reason: " + status);
          }
        });
      },
      validateNumber = function(fields) {
        fields.each(function(i) {
          var field = $(this),
            max = parseInt(field.attr('max'), 10),
            min = parseInt(field.attr('min'), 10),
            val = parseInt(field.val(), 10);
          if (val > max || val < min) {
            field.parents('li').addClass('error');
          } else {
            field.parents('li').removeClass('error');
          }
        });
      },
      validateImage = function(field) {
        var img = new Image(),
          val = field.val();
        if (val.length > 0) {
          img.src = field.val();
          img.onerror = function() { field.parents('li').addClass('error'); };
          img.onload = function() { field.parents('li').removeClass('error'); };
        } else {
          field.parents('li').removeClass('error');
        }
      },
      updateDetail = function() {
        var detail = $('.place.detail');
        detail.find('.name').html(getName());
        detail.find('.address').html(getAddress());
      },
      bindActions = function() {
        $('.locate').bind('click', function(e) {
          var lnk = $(this);
          e.preventDefault();
          lnk.addClass('loading');
          $.geolocate({
            success: function(position) {
              var ll = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
              setFormPosition(ll);
              lnk.removeClass('loading');
            }
          });
        });
        $('.mapdisplay').bind('click', function(e) {
          setFormPosition(getFormPosition());
        });
        $('.geocode').bind('click', function(e) {
          e.preventDefault();
          geocode(getAddress());
        });
        $('#place_lat, #place_lng').bind('keyup', function(e) {
          validateNumber($(this));
        });
        $('#place_full_name,.address_field').bind('keyup', updateDetail)
        $('#place_external_image_url').bind('blur', function(e) {
          validateImage($(this))
        });
      };
  $.provide(go, "PlaceForm", {
    init: function(options) {
      options.mapDiv = $(options.mapDiv || options.mapId || '#map')[0];
      _options = options;
      _geocoder = new google.maps.Geocoder();
      _map = new google.maps.Map(_options.mapDiv, mapOpts({center: getFormPosition()}));
      _marker = newMarker({draggable: true, position: getFormPosition(), title: getName()});
      google.maps.event.addListener(_marker, 'drag', function(e) { setFormPosition(e.latLng); });      
      bindActions();
      updateDetail();
      validateImage($('#place_external_image_url'));
      validateNumber($('#place_lat, #place_lng'));
    }
  })
}(Spot));