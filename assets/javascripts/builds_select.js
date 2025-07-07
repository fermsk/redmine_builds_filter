$.ajaxSetup({
  beforeSend: function(xhr) {
    var token = $('meta[name="csrf-token"]').attr('content');
    if (token) xhr.setRequestHeader('X-CSRF-Token', token);
  }
});

$(document).ready(function() {
  $('.builds-select').each(function() {
    var select = $(this);
    
    select.select2({
      theme: "classic",
      allowClear: true,
      placeholder: "",
      minimumInputLength: 0,
      width: '20%',
      ajax: {
        url: select.data('url'),
        dataType: 'json',
        delay: 250,
        data: function(params) {
          return {
            term: params.term || '',
            page: params.page || 1
          };
        },
        processResults: function(data, params) {
          params.page = params.page || 1;
          return {
            results: data.builds.map(function(build) {
              return {
                id: build.id,
                text: build.name
              };
            }),
            pagination: {
              more: (params.page * 30) < data.total_count
            }
          };
        },
        error: function() {
          return { results: [] };
        },
        cache: true
      },
      templateResult: formatBuild,
      templateSelection: formatBuildSelection
    });

    select.on('select2:open', function(e) {
      $('.select2-search__field').attr('placeholder', 'Search...');
    });
  });
  $('#created_at_from, #created_at_to, #updated_at_from, #updated_at_to').each(function() {
    $(this).datepicker({
      dateFormat: 'yy-mm-dd',
      showOn: 'button',
      buttonImageOnly: true,
      buttonImage: '/images/calendar.png'
    });
  });
});

function formatBuild(build) {
  if (build.loading) {
    return build.text;
  }
  return build.text || build.name;
}

function formatBuildSelection(build) {
  return build.text || build.name;
}