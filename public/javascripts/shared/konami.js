(function($) {
  // up is 38, down is 40, left is 37, right is 39, b is 66, a is 65, enter is 13
  // Up Up Down Down Left Right Left Right B A Enter
  var keys = [38, 38, 40, 40, 37, 39, 37, 39, 66, 65, 13],
    elems = $([]);
  $.event.special.konami = {
    setup: function(data, namespaces) {
      elems = elems.add( this );
      if ( elems.length === 1 ) {
        $(document).bind('keydown.konami', function(e) {
          var idx = $(document).data('konami-idx') || 0;
          if (e.keyCode === keys[idx]) {
            idx += 1;
            if (idx === keys.length) {
              elems.trigger( 'konami' );
              idx = 0;
            }
            $(document).data('konami-idx', idx);
          } else {
            $(document).data('konami-idx', 0);
          }
        });
      }
    },
    teardown: function(namespaces) {
      elems = elems.not( this );
      if ( elems.length === 0 ) {
        $(document).unbind( 'keydown.konami' );
      }
    }
  };
}(jQuery));