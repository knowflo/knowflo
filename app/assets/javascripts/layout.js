function popupCenter(url, width, height, name) {
  var left = (screen.width/2)-(width/2);
  var top = (screen.height/2)-(height/2);
  return window.open(url, name, "menubar=no,toolbar=no,status=no,width="+width+",height="+height+",toolbar=no,left="+left+",top="+top);
}

$(document).ready(function() {
  $("a.popup").click(function(e) {
    popupCenter($(this).attr("href"), $(this).attr("data-width"), $(this).attr("data-height"), "authPopup");
    e.stopPropagation(); return false;
  });

  $(window).scroll(function() {
    var sidebar = $('#sidebar .floating');
    var sidebarAllowance = 60 + sidebar.outerHeight();
    var position = $(window).scrollTop();

    if (position >= $('footer').position().top - sidebarAllowance) {
      position = $('footer').position().top - sidebarAllowance;
    }

    sidebar.animate(
      { top: position + 'px' },
      { queue: false, duration: 500, easing: 'easeInOutSine' }
    );
  });

  /*
  $('#sidebar .logo').hover(
    function() { $(this).rotate({ animateTo: 10 }); },
    function() { $(this).rotate({ animateTo: 0 }); }
  );
  */

  wysiwyg($('.wysiwyg:visible'));

  $('.btn-danger').parents('form').submit(function() {
    if (window.confirm("That seems dangerous. Are you sure you want to proceed?")) {
      return true;
    } else {
      return false;
    }
  });

  var algoliaClient = new AlgoliaSearch($('meta[name="algolia-app-id"]').attr('content'), $('meta[name="algolia-api-key"]').attr('content'));
  console.log(algoliaClient);
  var algoliaTemplate = Hogan.compile('{{{_highlightResult.subject.value}}}');

  $('input#search').typeahead({ minLength: 3 }, {
    source: algoliaClient.initIndex($('meta[name="algolia-index-name"]').attr('content')).ttAdapter(),
     displayKey: 'subject',
     templates: {
      suggestion: function(hit) {
        return algoliaTemplate.render(hit);
      }
    }
  });
});

function wysiwyg(e) {
  e.wysiwyg({
    controls : {
      subscript : { visible : false },
      superscript : { visible : false },
      insertTable : { visible : false },
      insertImage : { visible : false },
      code : { visible : false }
    },
    initialContent: ''
  });
}
