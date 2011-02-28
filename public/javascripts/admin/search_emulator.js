(function(go) {
  var map,
    setLatLng = function(ll) {
      var lat, lng;
      if (typeof(ll) === 'string') {
        ll = ll.split(',');
        lat = parseFloat(ll[0]);
        lng = parseFloat(ll[1]);
      } else if (ll.lat && ll.lng) {
        lat = ll.lat();
        lng = ll.lng();
      }
      lat = (!lat || lat > 90 || lat < -90 ? 0 : lat);
      lng = (!lng || lng > 180 || lng < -180 ? 0 : lng);
      $('#search_ll').val(lat + ',' + lng);
      map.setPosition(lat, lng);
    },
    initMap = function() {
      map = go.GMap.init({mapDiv: $('.map'), center: new google.maps.LatLng(0, 0), name: 'Search Location' });
      setLatLng($('#search_ll').val());
      map.bind('marker.drag', function(e) { setLatLng(e.latLng); });
      $('.results .place').each(function(i) {
        var $this = $(this);
        var ll = $this.attr('data-ll').split(',');
        map.addMarker(ll[0], ll[1], {
          title: $this.attr('data-name'),
          mouseout: function() { $('.place').removeClass('hover'); },
          mouseover: function() { 
            $('.place').removeClass('hover'); 
            $this.addClass('hover'); 
          }
        });
      });
    },
    bindActions = function() {
      $('#search_form').ajaxForm({
        start: function() {
          $(this).addClass('loading');
        }, success: function(data) {
          $(this).removeClass('loading');
          $('.results').html(data.html);
          initMap();
          go.ImageSelector.init('.place_image');
        }
      });
      $('.location').click(function(e) {
        e.preventDefault();
        setLatLng($(this).attr('data-ll'));
      });
      $('.geocode').click(function(e) {
        map.geocode($('#search_ll').val(), { 
          success: function() {  setLatLng(this);  }
        });
      });
      $('.geolocate').click(function(e) {
        var lnk = $(this);
        e.preventDefault();
        lnk.addClass('loading');
        $.geolocate({
          success: function(position) {
            var ll = position.coords.latitude + "," + position.coords.longitude;
            setLatLng(ll);
            lnk.removeClass('loading');
          }, error: function() {
            lnk.removeClass('loading');
            alert("Sorry, we couldn't get your location.");
          }
        });
      });
    };  
  $.provide(go, 'SearchEmulator', {
    init: function() {
      initMap();
      bindActions();
    }
  });
}(Spot));