function setEditable(e) {
  $(e).hover(
    function() {
      $(this).addClass('highlight');
      var label = $('<div/>').text('Update').addClass('prompt');
      $(this).append(label);
    },
    function() {
      $(this).removeClass('highlight');
      $(this).find('.prompt').remove();
    }
  );

  $(e).click(function() {
    $(this).removeClass('highlight');
    var container = $(this);
    var editable = $(this).find('.editable');
    var content = $(this).find('.content');
    content.hide();
    editable.show();

    wysiwyg($(this).find('.editable textarea'));
    $(this).unbind('click').unbind('hover');
    $(this).find('.prompt').remove();

    $(this).find('button.cancel').unbind('click').click(function() {
      editable.hide();
      content.show();
      setEditable(container);
      return false;
    });
  });
}

$(function() {
  $('.add-comment').click(function() {
    var target = $(this).parent().find('ul.comments');
    target.slideToggle();
    wysiwyg(target.find('.new_comment textarea'));
    return false;
  });

  $('.vote a').click(function() {
    var self = $(this);
    if (!self.hasClass('disabled')) {
      var el = self.parents('.answer');
      var path = el.find('.vote').attr('data-url');
      var val = self.attr('data-value');
      $.post(path, { value : val }, function(data, status, xhr) {
        var text = el.find('.points').text();
        el.find('.points').text(data.points);
        el.find('.vote a').removeClass('active');
        self.addClass('active');
      }, 'json');
    }
    return false;
  });

  $('a.accept-answer').click(function() {
    if (confirm('Are you sure you want to mark this answer as the solution?')) {
      // temporary
      $(this).parents('form').submit();
    }
    return false;
  });

  setEditable($('.bodytext').has('.editable'));
});
