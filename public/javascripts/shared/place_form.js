(function(go) {
  var _options,
      _map,
      getFormPosition = function() {
        return new google.maps.LatLng($('#place_lat').val(), $('#place_lng').val());
      },
      setFormPosition = function(newLL) {
        $('#place_lat').val(newLL.lat());
        $('#place_lng').val(newLL.lng());
        $('.latlng').html("@" + newLL.lat() + ',' + newLL.lng());
        _map.setPosition(newLL.lat(), newLL.lng());
        return newLL;
      },
      getAddress = function() {
        return $('.address_field:eq(0)').val() + ' ' + $('.address_field:eq(1)').val();
      },
      getName = function() {
        return $('.name_field').val();
      },
      getCity = function() {
        return $('#place_city').val();
      },
      updateDetail = function() {
        var detail = $('.place.detail');
        detail.find('.name').html(getName());
        detail.find('.address').html("<p>" + $('.address_field:eq(0)').val() + "</p>" + "<p>" + $('.address_field:eq(1)').val() + "</p>");
      },
      bindActions = function() {
        $('.name_field').unbind('keyup.placeform').bind('keyup.placeform', updateDetail);
        $('.address_field').unbind('keyup.placeform').bind('keyup.placeform', updateDetail);
        $('#place_lat, #place_lng').unbind('change.remap').bind('change.remap', function() {
          setFormPosition(getFormPosition())
        });
        $('.address_field').unbind('change.geocode').bind('change.geocode', function(e) {
          _map.geocode(getAddress(), {
            uncertain: function(results) {
              $('.map_message').html("We found a few possible matches for that address. Please clarify by clicking the right pin on the map.")
            },
            success: function() {
              setFormPosition(this);
            }
          });
        });
      };
  $.provide(go, "PlaceForm", {
    init: function(options) {
      options = options || {};
      if (options.mapDiv) {
        _map = Spot.GMap.init({ mapDiv : options.mapDiv, center: getFormPosition(), name: getName() });
        _map.bind('marker.drag', function(e) { setFormPosition(e.latLng); });        
      }
      bindActions();
      updateDetail();
    }
  });
}(Spot));