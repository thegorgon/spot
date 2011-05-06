(function(go) {
  var buildCell = function(date) {
      var cell = $("<td></td>").addClass('date').addClass(((date.getMonth() + 1) % 2 === 0 ? 'even' : 'odd') + "_month");
      if (date.isToday()) {          
        cell.addClass('present');
      } else if (date.isPast()) {
        cell.addClass('past');
      } else {
        cell.addClass('future');
      }
      cell.attr('id', "date_" + date.getMonth() + "_" + date.getDate() + "_" + date.getFullYear()).html(date.getDate()).data('date', date);
      cell.hover(function() {
        var date = $(this).data('date');
        $(this).html(date.toString("ddd, MMM d"));
      }, function() {
        var date = $(this).data('date');
        $(this).html(date.getDate());        
      });
      return cell;
    },
    fillDates = function(tbody, startDate, weekCount) {
      var row, wk, dy;
      tbody.find('tr').removeClass('last');
      for (wk = 0; wk < weekCount; wk++) {
        row = $('<tr></tr>');
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
    updateScroll = function(tbody, title) {
      var rows = tbody.find('tr'), 
        rowHeight = rows.outerHeight(),
        viewHeight = tbody.outerHeight(),
        scrollTop = tbody.scrollTop(),
        rowIndex = Math.round(scrollTop/rowHeight),
        rowCount = Math.round(viewHeight/rowHeight),
        minDate, maxDate,
        endDate = tbody.find('td:last').data('date'),
        daysRendered = Date.now().daysUntil(endDate);
      
      if (tbody[0].scrollHeight - scrollTop - viewHeight < 100 && daysRendered <= 90) {
        fillDates(tbody, endDate.clone().addDays(1), 1);
      }
      minDate = rows.eq(rowIndex).find('td:first').data('date');
      maxDate = rows.eq(rowIndex + rowCount - 1).find('td:last').data('date');
      setTitle(title, minDate, maxDate);
    };
  $.provide(go, 'DealCalendar', {
    init: function(options) {
      
      var calendar = $(options.calendar || '#calendar'),
        startDate = options.startDate || new Date(1000 * calendar.attr('data-start-date')),
        weekCount = options.weekCount || 12,
        tbody = calendar.find('table tbody'),
        title = calendar.find('#monthtitle');
        
      tbody.html("");
      endDate = fillDates(tbody, startDate, weekCount);
      updateScroll(tbody, title);
      tbody.scrollTop(0);
      
      tbody.scroll(function(e) {
        updateScroll(tbody, title);
      });
      return {
        start: startDate
      };
    }
  });
}(Spot));