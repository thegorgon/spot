(function(go) {
  var $ = window.jQuery;
  $.provide(go, 'GMap', {
    init: function(options) {
      options.mapDiv = $(options.mapDiv || options.mapId || '#map')[0];
      var _options = options,
        _geocodeMarkers = [], 
        _geocodeopts = {},
        _geocoder = new google.maps.Geocoder(),
        mapOpts = function(options) {
          return $.extend({ center: _options.position, 
                     zoom: 13, 
                     mapTypeId: google.maps.MapTypeId.ROADMAP }, options);
        },
        _map = new google.maps.Map(_options.mapDiv, mapOpts({center: _options.center})),
        newMarker = function(options) {
          options = $.extend({ map: _map }, options);
          return new google.maps.Marker(options);
        },
        _marker = newMarker({draggable: true, position: _options.center, title: _options.name }),
        setPosition = function(newLL) {
          _marker.setPosition(newLL);
          _map.panTo(newLL);
        },
        clearGeocodeMarkers = function() {
          _map.setZoom(mapOpts().zoom);
          _map.panTo(_marker.getPosition());
          $.each(_geocodeMarkers, function(i) { this.setMap(null); });        
          _geocodeMarkers = [];
        },
        addMarker = function(options) {
          var marker = newMarker(options),
            bounds = _map.getBounds();
          if (bounds) {
            bounds.extend(marker.getPosition());
            _map.fitBounds(bounds);            
          }
          $.each(['click', 'dblclick', 'mouseup', 'mousedown', 'mouseover', 'mouseout'], function(i) {
            if ($.isFunction(options[this])) { google.maps.event.addListener(marker, this, options[this]); }              
          });
          return marker;
        },
        addGeocodeMarker = function(result) {
          var marker = addMarker({clickable: true, position: result.geometry.location});
          _geocodeMarkers.push(marker);
          google.maps.event.addListener(marker, 'click', function(e) {
            if ($.isFunction(_geocodeopts.success)) { _geocodeopts.success.call(this.getPosition()); }
            clearGeocodeMarkers();
          });         
          marker.setMap(_map);
        },
        geocode = function(address) {
          _geocoder.geocode({ 'address': address }, function(results, status) {
            if (status === google.maps.GeocoderStatus.OK) {
              clearGeocodeMarkers();
              $.each(results, function(i) {
                addGeocodeMarker(this);
              });
            } else {
              if ($.isFunction(_geocodeopts.error)) { _geocodeopts.error.call(status); }
              else { alert("Geocode was not successful for the following reason: " + status); }
            }
          });
        };          
      return {
        setPosition: function(lat, lng) {
          newLL = new google.maps.LatLng(lat, lng);
          setPosition(newLL);
        },
        geocode: function(address, options) {
          _geocodeopts = options || {};
          geocode(address);            
        },
        addMarker: function(lat, lng, options) {
          options = options || {};
          var position = new google.maps.LatLng(lat, lng);
          options.position = position;
          addMarker(options);
        },
        bind: function(name, fn) {
          var parts = name.split('.'),
            tgt = _map;
          if (parts[0] === 'marker' && parts.length > 1) { 
            tgt = _marker; 
            name = parts[1];
          }
          google.maps.event.addListener(tgt, name, fn);      
        }
      };
    }
  });  
}(Spot));