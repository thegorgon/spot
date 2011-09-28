(function(go) {
  $.provide(go, "ClaimForm", {
    init: function(options) {
      var form = $(options.form),
        dialog = $(options.dialog),
        calendar = $(options.calendar);
        
      form.ajaxForm({
        start: function(){
          dialog.addClass('loading');
        },
        success: function(data) {
          dialog.removeClass('loading').addClass('claimed');
          if (data.error) {
            dialog.find('.code').html($("<div class='error'></div>").html(data.error));
          } else {
            dialog.find('.code').html(data.code);
            go.Behaviors.train(dialog.find('.code'));
            if (calendar.length > 0) {
              calendar.html(data.calendar);              
            }
            if ($.isFunction(options.complete)) { options.complete.call(); }
          }
        },
        error: function() {
          dialog.find('.code').html($("<div class='error'></div>").html("Sorry, something went wrong, please refresh this page and try again."));
          dialog.removeClass('loading').addClass('claimed');          
        }
      });
    }
  });
}(Spot));