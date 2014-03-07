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
  var algoliaTemplate = '{{{_highlightResult.subject.value}}}';
  var algoliaGroup = $('meta[name="group-id"]').attr('content');
  var algoliaOptions = {};

  if (algoliaGroup != undefined) {
    algoliaOptions['tagFilters'] = ['group_' + algoliaGroup];
  } else {
    algoliaOptions['tagFilters'] = ['status_public'];
    algoliaTemplate += " ({{{_highlightResult.group_name.value}}})"
  }

  algoliaTemplate = Hogan.compile(algoliaTemplate);

  $('input#search').typeahead({ minLength: 3 }, {
    source: algoliaClient.initIndex($('meta[name="algolia-index-name"]').attr('content')).ttAdapter(algoliaOptions),
     displayKey: 'subject',
     templates: {
      suggestion: function(hit) {
        return algoliaTemplate.render(hit);
      }
    }
  });

  $('input#search').on('typeahead:selected', function(event, obj) {
    if (algoliaGroup == obj.group_id) {
      window.location.pathname = "/questions/" + obj.url;
    } else {
      var parts = window.location.host.split('.').slice(-2);
      var pathPattern = new RegExp(window.location.pathname + '$');
      var url = window.location.href.
        replace(window.location.host, obj.group_url + '.' + parts.join('.')).
        replace(pathPattern, '/questions/' + obj.url);
      window.location = url;
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
