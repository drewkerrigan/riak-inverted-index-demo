$(function() {

    $('#query-form').submit(function() {
        $.get('/query/' + $('#index_select').val() + '/' + $('#zip_input').val(), function(data) {
            $('#query-results').html(data);
        });
        return false;
    });
});