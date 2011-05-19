(function(go) {
  var buildCell = function(date) {
      var cell = $("<div></div>").addClass("td").addClass('date').addClass(((date.getMonth() + 1) % 2 === 0 ? 'even' : 'odd') + "_month").addClass("dow_" + date.getDay()),
        datenumber = $('<div></div>').addClass('datenumber').html(date.getDate()).appendTo(cell);
      if (date.isToday()) {          
        cell.addClass('present');
        $('<div></div>').addClass('todaynote').html('today').appendTo(cell);
      } else if (date.isPast()) {
        cell.addClass('past');
      } else {
        cell.addClass('future');
      }
      cell.attr('id', "date_" + date.getMonth() + "_" + date.getDate() + "_" + date.getFullYear()).data('date', date);
      cell.hover(function() {
        var date = $(this).data('date');
        $(this).find('.datenumber').html(date.toString("ddd, MMM d"));
      }, function() {
        var date = $(this).data('date');
        $(this).find('.datenumber').html(date.getDate());        
      });
      return cell;
    },
    fillDates = function(tbody, startDate, weekCount) {
      var row, wk, dy;
      tbody.find('.tr').removeClass('last');
      for (wk = 0; wk < weekCount; wk++) {
        row = $('<div></div>').addClass('tr');
        for (dy = 0; dy < 7; dy++) {
          buildCell(startDate.clone().addDays(7 * wk + dy)).appendTo(row);
        }
        if (wk === 0) {
          row.addClass('first');
        } else if (wk === weekCount - 1) {
          row.addClass('last');
        }
        row.appendTo(tbody);
      }
    },
    setTitle = function(title, minDate, maxDate) {
      var text;
      if (minDate && maxDate) {
        text = minDate.getMonthName();
        if (minDate.getFullYear() != maxDate.getFullYear()) {
          text = text + " " + minDate.getFullYear();
        }
        if (minDate.getFullYear() != maxDate.getFullYear() || minDate.getMonth() != maxDate.getMonth()) {
          text = text + " - ";
          text = text + maxDate.getMonthName();
        }
        text = text + " " + maxDate.getFullYear();        
        title.html(text);        
      }
    },
    updateScroll = function(grid) {
      var tbody = grid.find('.tbody'),
        title = grid.parent('.section').find('h1'),
        rows = tbody.find('.tr'), 
        rowHeight = rows.outerHeight(),
        viewHeight = tbody.outerHeight(),
        scrollTop = tbody.scrollTop(),
        rowIndex = Math.round(scrollTop/rowHeight),
        rowCount = Math.round(viewHeight/rowHeight),
        minDate, maxDate,
        endDate = tbody.find('.td:last').data('date'),
        daysRendered = Date.now().daysUntil(endDate);

      if (tbody[0].scrollHeight - scrollTop - viewHeight < 100 && daysRendered <= 90) {
        fillDates(tbody, endDate.clone().addDays(1), 1);
      }
      minDate = rows.eq(rowIndex).find('.td:first').data('date');
      maxDate = rows.eq(rowIndex + rowCount - 1).find('.td:last').data('date');
      setTitle(title, minDate, maxDate);
    };
    
    
  $.provide(go, 'DealCalendar', {
    init: function(options) {
      
      var calendar = $(options.calendar || '#calendar'),
        gridtitle = calendar.find('.gridtitle'),
        grid = calendar.find('.grid'),
        list = calendar.find('ul.templates'),
        newtplform = $('form.newtplform'),
        tbody = grid.find('.tbody'),
        templates = [], events = {},
        messaging = calendar.find('#messages'),
        currentTemplate,
        processMessage = $('#processmessage');

        processing = function(msg, to) {
          var retain = processMessage.data("retainCount") || 0;
          to = to || 5000;
          clearTimeout(processMessage.data("timeout"));
          if (msg) {
            processMessage.hide();
            setTimeout(function() {
              processMessage.find('span').html(msg);
              processMessage.show();
            }, 1);
            processMessage.data("retainCount", retain + 1);
            processMessage.data("timeout", setTimeout(function() {
              processMessage.data("retainCount", 0);
              processMessage.fadeOut(250);
            }, to));
          } else {
            processMessage.data("retainCount", Math.max(retain - 1, 0));              
            if (retain - 1 <= 0) {
              processMessage.fadeOut(250, function() {              
                processMessage.find('span').html('');
              });              
            }
          }
        },
        pendingTemplate = function() {
          var params = newtplform.serializeObject(),
            tpl = buildTemplate({name : params["template[name]"], summary: 'saving...', color: '#fff', id: -1});
          list.removeClass('empty');
          return tpl.addClass('pending').appendTo(list);
        },
        buildTemplate = function(json) {
          return $('.jstpl.template').tmpl(json).removeClass('jstpl');
        },
        previewEvent = function(cell) {
          var data = $.slice(currentTemplate, ['name', 'color', 'timeframe', 'start_time', 'end_time']);
          data.deal_template_id = currentTemplate.id;
          displayCellEvent(cell, data);
        },
        hideEventPreview = function(cell) {
          $('.event.preview').remove();
          $.jstooltip.hide();
          if (cell) { setCellClass(cell); }
        },
        buildEvent = function(json) {
          var event = $('.jstpl.event').tmpl(json).removeClass('jstpl');
          if (!json.id) { event.addClass(json.saving ? 'saving' : 'preview'); }
          else if (json.removed_at) { event.addClass('removed'); }
          else { event.addClass('saved'); }
          event.data('eventdata', json);
          return event;
        },
        addTemplate = function(json) {
          var tpl = buildTemplate(json);
          bindTemplate(tpl);
          tpl.data('template', json);
          templates.push(json);
          tpl.appendTo(list);
          bindDeleteTemplateForms(tpl);
          $.jstooltip.bind(list);
          return tpl;
        },
        selectTemplate = function(tpl) {
          $('body').addClass('lightsout');
          currentTemplate = $(tpl).data('template');
          message("Click dates on the calendar to offer '" + currentTemplate.name + "' on those dates.");
          $('.cancel', messaging).click(function(e) {
            unselectTemplates();
          });
          $('.dow').addClass('selectable').each(function(i) {
            $(this).unbind('mouseenter.applydeal').bind('mouseenter.applydeal', function(e) {
              $.jstooltip.show("Click to offer '" + currentTemplate.name + "' every " + $.capitalize($(this).attr('data-dayname')) + " for the next 90 days.");
              $('.date.dow_' + $(this).attr('data-dayindex')).each(function(i) {
                if (canPlace(currentTemplate, this, false)) {
                  previewEvent(this);
                }
              });
            }).unbind('mouseleave.applydeal').bind('mouseleave.applydeal', function(e) {
              $('.date.dow_' + $(this).attr('data-dayindex')).each(function(i) {
                hideEventPreview(this);
              });
            }).unbind('click.applydeal').bind('click.applydeal', function(e) {
              $('.date.dow_' + $(this).attr('data-dayindex')).each(function(i) {
                if (canPlace(currentTemplate, this, false)) {
                  createEvent(this);
                }
              });
            });
          });
          $('li.template').removeClass('active').addClass('inactive');
          $(tpl).removeClass('inactive').addClass('active');          
        },
        unselectTemplates = function() {
          removeMessage();
          hideEventPreview();
          $('li.template').removeClass('active').removeClass('inactive');
          currentTemplate = null;
          $('body').removeClass('lightsout');
          $.jstooltip.hide();
        },
        bindTemplate = function(tpl) {
          $(tpl).unbind('click.selectTemplate').bind('click.selectTemplate', function(e) {
            if ($(this).is('.active')) {
              unselectTemplates();
            } else {
              selectTemplate(this);
            }
          });
          $('.lightscreen').click(function(e) {
            unselectTemplates();
          });
        },
        getCellEvents = function(cell) {
          var cellEvents = [];
          $(cell).find('.event').each(function(i) {
            cellEvents.push($(this).data('eventdata'));
          });
          return cellEvents;
        },
        message = function(msg, klass) {
          var content = messaging.find('.content');
          messaging.hide().removeAttr('class');
          content.html(msg);
          messaging.addClass(klass).addClass('visible').fadeIn(250);
        },
        removeMessage = function() {
          messaging.removeClass('visible').find('.content').html('');
        },
        displayCellEvent = function(cell, event) {
          var cellEvents = getCellEvents(cell);
          cellEvents.push(event);
          cellEvents.sort(function(a, b) { return a.start_time - b.start_time; });
          $(cell).find('.event').remove();
          setCellClass(cell, cellEvents);
          $.each(cellEvents, function(i) {
            buildEvent(cellEvents[i]).appendTo(cell);
          });
        },
        setCellClass = function(cell, cellEvents) {
          cell = $(cell);
          cellEvents = cellEvents || getCellEvents(cell);
          if (cellEvents.length > 2) {
            cell.addClass('smallevents');
          } else if (cellEvents.length > 5) {
            cell.addClass('tinyevents');
          } else {
            cell.removeClass('smallevents').removeClass('tinyevents');
          }
        },
        showDateSummary = function(cell) {
          var template = $('.jstpl.eventdetails'), 
            datetpl = $('.jstpl.datedetail'), 
            date = $(cell).data('date'),
            content = datetpl.tmpl({events: "<div class='eventlist'></div>", date: date.toString('yyyy-MM-dd')}),
            eventlist = content.find('.eventlist'),
            popover, eventDetail;
          $(cell).find('.event').each(function(i) {
            eventDetail = template.tmpl($(this).data('eventdata'));
            eventDetail.data('calendarevent', $(this));
            eventlist.append(eventDetail);
          });
          grid.find('.tbody').css('overflow', 'hidden');
          content.find('.sendcodes').ajaxForm({
            start: function() {
              $.popover.hide();
              processing("Sending Codes...");
            }, success: function(data) {
              processing(data.flash);
            }, error: function() {
              processing(null);
              processing("There was an error. Please try again.")
            }
          })
          popover = $.popover.init(date.toString("ddd, MMM d"), content);
          bindDeleteEventForms(popover);
          $.popover.reveal($(cell), popover, {orient: 'horizontal'});
          $(window).unbind('popoverhide.returnscroll').bind('popoverhide.returnscroll', function(e) {
            grid.find('.tbody').css('overflow-y', 'scroll');
            $(window).unbind('popoverhide.returnscroll');
          });
        },
        createEvent = function(cell) {
          cell = $(cell);
          var date = cell.data('date'),
            eventContainer = cell.find('.event.preview').removeClass('preview').addClass('saving'),
            data = eventContainer.data('eventdata');
          if (data) {
            data.saving = true;
            eventContainer.data('eventdata', data);
            processing("Saving...");
            $.ajax({
              type: 'POST',
              url: grid.attr('data-src'),
              dataType: 'json',
              data: {event: {deal_template_id: currentTemplate.id, date: date.toString('yyyy-MM-dd')}},
              success: function(data) {
                if (data.success) {
                  var dateString = date.toString('yyyy-MM-dd');
                  cell.find('.event.saving[data-template-id=' + data.event.deal_template_id + ']').remove();
                  events[dateString] = events[dateString] || [];
                  events[dateString].push(data.event);
                  displayCellEvent(cell, data.event);                  
                  processing(null);
                } else {
                  processing(null);
                  message("Sorry, we encountered an error applying that deal on that date : " + data.error, 'error');
                }
              }
            });
          }
        },
        fillEvents = function() {
          grid.find('.date').each(function(i) {
            var cell = $(this), 
              dateString = cell.data('date').toString('yyyy-MM-dd'),
              dateEvents = (events[dateString] || []).sort(function(a, b) { return a.start_time - b.start_time; });
            setCellClass(cell, dateEvents);
            $.each(dateEvents, function(i) {
              buildEvent(dateEvents[i]).appendTo(cell);
            });
          });
        },
        canPlace = function(tpl, cell, showMessage) {
          cell = $(cell);
          var date, msg = false;
            msg = false;
          if (tpl) {
            date = cell.data('date').clone()
            date.setHours(tpl.end_time);
            if (tpl.start_time > tpl.end_time) {
              date.addDays(1);
            }
            if (date.isPast()) {
              msg = "Cannot apply deals in the past.";
            } else if (cell.find('.event.saved[data-template-id=' + tpl.id + ']').length > 0) {
              msg = "Cannot apply deals multiple times per day.";
            } else {
              if (showMessage) { $.jstooltip.hide(); }
              return true;
            }
          }
          
          if (showMessage && msg) { $.jstooltip.show(msg, "error"); }
          return false;
        },
        bindDates = function(){
          grid.find('.date').unbind('mouseenter.eventpreview').bind('mouseenter.eventpreview', function() {
            $('.event.preview').remove();
            if (canPlace(currentTemplate, this, true)) {
              previewEvent(this);
            }
          }).unbind('mouseleave.eventpreview').bind('mouseleave.eventpreview', function() {
            hideEventPreview(this);
          }).unbind('click.saveevent').bind('click.saveevent', function(e) {
            e.preventDefault();
            if (canPlace(currentTemplate, this, true)) {
              createEvent(this);
            } else if (!currentTemplate && $(this).find('.event.saved, .event.removed').length > 0) {
              showDateSummary(this);
            }
          });
        },
        loadData = function() {
          var tplUrl = list.attr('data-src'),
            eventUrl = grid.attr('data-src');

          processing("Loading...");
          $.ajax({
            url: tplUrl,
            dataType: 'json',
            data: {},
            success: function(data) {
              list.removeClass('loading');
              templates = data.templates;
              if (data.templates.length === 0) {
                list.addClass('empty');
              } else {
                $.each(data.templates, function(i) {
                  addTemplate(data.templates[i]);
                });
              }
              processing(null);              
            }, error: function() {
              processing(null);
              message("Sorry, the system encountered an error. Please refresh this page to continue.", "error");
            }
          });

          processing("Loading...");
          $.ajax({
            url: eventUrl,
            dataType: 'json',
            data: {},
            success: function(data) {
              var tbody = grid.find('.tbody'),
                startDate = new Date(Date.parse(calendar.attr('data-start-date'))),
                endDate = new Date(Date.parse(calendar.attr('data-end-date')));
              events = data.events;
              grid.removeClass('loading');
              tbody.html("");
              fillDates(tbody, startDate, Date.weeksBetween(startDate, endDate));
              fillEvents();
              updateScroll(grid);
              tbody.scrollTop(0);
              bindDates();
              processing(null);
            }, error: function() {
              processing(null);
              message("Sorry, the system encountered an error. Please refresh this page to continue.", "error");
            }
          });
        },
        bindNewForm = function() {
          newtplform.ajaxForm({
            start: function() {
              if ($(this).validate()) {
                $.popover.hide();
                pendingTemplate();
                removeMessage();
                processing("Saving...");
                return true;
              } else {
                return false;
              }
            }, success: function(data) {
              if (data.success) {
                $('li.template.pending').remove();
                selectTemplate(addTemplate(data.template));                
                $(this).clear();
                processing(null);
              } else {
                $('li.template.pending').remove();
                processing(null);
                message("Sorry, there were errors with your submission : " + data.error + ". Please try again.", "error");
              }
            }, error: function() {
              processing(null);
              message("Something went wrong, please try again.", "error");
            }
          });
        },
        bindDeleteTemplateForms = function(tpl) {
          $('form.remove', tpl).ajaxForm({
            start: function() {
              var tpl = $(this).parents('.template');
              tpl.addClass('deleting');
              processing("Deleting...");
            },
            success: function(data) {
              var tpl = $(this).parents('.template');
              tpl.slideUp(function() {
                tpl.remove();
              });
              processing(null);
            }, error: function() {
              message("Sorry, something went wrong, please try again.", "error");
              $(this).parents('.template').removeClass('deleting');
              processing(null);
            }
          });
        },
        bindDeleteEventForms = function(container) {
          $('form.remove', container).ajaxForm({
            start: function() {
              $.popover.hide();
              $(this).parents('.event').data('calendarevent').addClass('deleting');
              removeMessage();
              processing("Deleting...");
            }, success: function(data) {
              var event = $(this).parents('.event').data('calendarevent'),
                cell = event.parent('.td.date');
              event.removeClass('saved').removeClass('deleting');
              if (data.event) {
                event.data('eventdata', data.event).addClass('removed');
              } else {
                event.remove();
              }
              setCellClass(cell);
              processing(null);
            }, error: function() {
              message("Sorry, something went wrong, please try again.", "error");
              $(this).parents('.event').data('calendarevent').removeClass('deleting');
              processing(null);
            }
          });
        };
      
      loadData();
      bindNewForm();
      
      tbody.scroll(function(e) {
        updateScroll(grid);
        bindDates();
      });
      
      return {
      };
    }
  });
}(Spot));