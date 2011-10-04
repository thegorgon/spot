(function(go) {
  var lock, unlock, invitationCode,
  bind = function() {
    lock.unbind('keyup.updatecode').bind('keyup.updatecode', function(e) {
      var self = this, 
        timeout = $(self).data('change-timeout'),
        li = $(self).parents('li:first');
      if (e.keyCode == 13) {
        e.preventDefault();
        $(self).change();
      } else {
        li.removeClass('valid').removeClass('invalid');
        if ($(self).val() == '') {
          li.removeClass('loading');
        } else {
          li.addClass('loading');
        }
        clearTimeout(timeout);
        $(self).data('change-timeout', setTimeout(function() {
          $(self).change();
        }, 1000));
      }
    });
    lock.unbind('change.updatecode').bind('change.updatecode', function(e) {
      var self = $(this),
        form = $(this).parents('ul.form:first'),
        li = self.parents('li:first'); 
      if (self.data('lastsent') != self.val() && self.val().toString().length > 0) {            
        self.parents('li:first').removeClass('valid').removeClass('invalid').addClass('loading');
        self.data('lastsent', self.val());
        $.get('/codes/invitation/' + self.val(), function(data) {
          if (data.code && data.code.available) {
            invitationCode.val(lock.val());
            form.addClass('unlockable');
            self.blur();
            li.removeClass('loading').removeClass('invalid').removeClass('valid');
          } else {
            form.find('.vouched').slideUp();
            lock.removeAttr('disabled');
            form.removeClass('unlockable');
            li.removeClass('loading').removeClass('valid').addClass('invalid');
          }
        });
      }
    });
    unlock.unbind('click.unlock').bind('click.unlock', function(e) {
      e.preventDefault();
      var form = $(this).parents('ul.form:first');
      if (invitationCode.val() != '') {
        form.addClass('unlocking');
        setTimeout(function(e) {
          lock.attr('disabled', 'disabled');
          onUnlock.call(form, invitationCode.val());
        }, 1000);          
      }
    });
  }
  $.provide(go, 'Lock', {
    init: function(options) {
      lock = options.lock;
      unlock = options.unlock;
      invitationCode = options.invitationCode;
      onUnlock = options.onUnlock;
      bind();
    }
  });
}(Spot));