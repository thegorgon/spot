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
        return $('#place_address_lines_0').val() + ' ' + $('#place_address_lines_1').val();
      },
      getName = function() {
        return $('#place_full_name').val();
      },
      getCity = function() {
        return $('#place_city').val();
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
        $('.updatemap').bind('click', function(e) {
          setFormPosition(getFormPosition());
        });
        $('.geocode').bind('click', function(e) {
          e.preventDefault();
          _map.geocode(getAddress(), {
            success: function() {
              setFormPosition(this);
            }
          });
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
      _map = Spot.GMap.init({ mapDiv : options.mapDiv, center: getFormPosition(), name: getName() });
      _map.bind('marker.drag', function(e) { setFormPosition(e.latLng); })
      bindActions();
      updateDetail();
      validateImage($('#place_external_image_url'));
      validateNumber($('#place_lat, #place_lng'));
    }
  })
}(Spot));