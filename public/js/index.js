var map;
var markersArray = [];
var start = 1;
var lat = 0;
var lon = 0;
var method = "zip";

function initialize() {
    $("#alert").hide();
    $('#query_results').hide();
    $('#pagination').hide();

    var groundZero = new google.maps.LatLng(38.956160, -77.397262);
    var mapOptions = {
        zoom: 15,
        center: groundZero,
        mapTypeId: google.maps.MapTypeId.TERRAIN
    };
    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);

    google.maps.event.addListener(map, 'click', function(event) {
        lat = event.latLng.lat();
        lon = event.latLng.lng();
        method = "latlng";
        getZombies(1);
    });

    $('#query-form').submit(function() {
        method = "zip";
        getZombies(1);
        return false;
    });
}

function getZombies(index) {

    start = index;
    if (method == "zip") {
        queryZip();
    } else {
        queryLatlng();
    }

    return false;
}

function queryZip() {
    $("#loading").show();
    $.ajax({url:'/query/' + $('#index_select').val() + '/' + $('#zip_input').val() + '?start=' + start, dataType:"json"}).done(function(data) {
        $("#loading").hide();
        if (data.zombies.length > 0) {
            populateTable(data);
            addZombies(data);
            $("#alert").hide();
        } else {
            clearOverlays();
            $("#alert").show();
            $('#query_results').hide();
            $('#pagination').hide();
        }
    });
}

function queryLatlng() {
    $("#loading").show();
    $.ajax({url:"/query/geo?lat=" + lat + "&lon=" + lon + "&start=" + start, dataType:"json"}).done(function (data) {
        $("#loading").hide();
        if (data.zombies.length > 0) {
            populateTable(data);
            addZombies(data);
            $("#alert").hide();
        } else {
            clearOverlays();
            $("#alert").show();
            $('#query_results').hide();
            $('#pagination').hide();
        }
    });
}

// Autocomplete for zip field
$("#zip_input").autocomplete({
    source: function (request, response) {
        $.ajax({
            url:"/query/zip3/" + request.term,
            dataType:"json",
            success: function(data) {
                response($.map(data, function(item) { return {label: item, value: item}}) )
            }
        });
    },
    minLength: 3,
    open: function() {
        $( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
    },
    close: function() {
        $( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
    }
});

function populateTable(data) {
    $('#query_results').empty();
    $('#pagination').empty();
    $('#pagination').show();
    $('#query_results').show();

    //TODO: finish prev and next

    // Pagination
    if(data.total_count > data.zombies.length) {
        $('#pagination').append($('<ul>').append($('<li/>')
            .html('<a href="#" onclick="return getZombies(' + data.prev_index + ');">Prev</a>')));

        for (var i=1;i<=data.pages;i++)
        {
            if (data.current_page == i) {
                active = 'class="current"'
            } else {
                active = ''
            }

            $('<li />').appendTo('#pagination ul')
                .html('<a ' + active + ' href="#" onclick="return getZombies(' + ((i - 1) * data.increment + 1) + ');">' + i + '</a>');
        }

        $('<li/>').appendTo('#pagination ul')
            .html('<a href="#" onclick="return getZombies(' + data.next_index + ');">Next</a>');
        $('<li/>').appendTo('#pagination ul')
            .html('<span>Showing zombies ' + data.start + '-' + (data.start + data.zombies.length - 1) + ' of ' + data.total_count) + '</span>';
    }

    // Table
    var header = ['dna','sex','name','address','city','state','zip','phone',
        'birthdate','ssn','job','bloodtype','weight','height'];

    var header_row= $('<tr>');
    $.each(header, function(i, head) {
        header_row.append($('<th>').text(head));
    });
    header_row.appendTo($('#query_results'));

    $.each(data.zombies, function(i, row) {
        $('#query_results')
            .append($('<tr>')
                .append($('<td>').text(row['dna'].substring(0, 10) + "..."))
                .append($('<td>').text(row['sex']))
                .append($('<td>').text(row['name']))
                .append($('<td>').text(row['address']))
                .append($('<td>').text(row['city']))
                .append($('<td>').text(row['state']))
                .append($('<td>').text(row['zip']))
                .append($('<td>').text(row['phone']))
                .append($('<td>').text(row['birthdate']))
                .append($('<td>').text(row['ssn']))
                .append($('<td>').text(row['job']))
                .append($('<td>').text(row['bloodtype']))
                .append($('<td>').text(row['weight']))
                .append($('<td>').text(row['height']))

            );
    });
}

function addZombies(data) {
    clearOverlays();

    var boundsChanged = false;
    var bounds = new google.maps.LatLngBounds();

    $.each(data.zombies, function() {
        lat = parseFloat(this['latitude']);
        lon = parseFloat(this['longitude']);

        var position = new google.maps.LatLng(lat, lon);

        bounds.extend(position);
        boundsChanged = true;

        addMarker(position);
    })

    if (boundsChanged) map.fitBounds(bounds);
}

function addMarker(location) {
    marker = new google.maps.Marker({
        position: location,
        map: map,
        icon:"img/zombie-outbreak1.png"
    });
    markersArray.push(marker);
}

// Removes the overlays from the map, but keeps them in the array
function clearOverlays() {
    if (markersArray) {
        for (i in markersArray) {
            markersArray[i].setMap(null);
        }
    }
}

// Shows any overlays currently in the array
function showOverlays() {
    if (markersArray) {
        for (i in markersArray) {
            markersArray[i].setMap(map);
        }
    }
}

// Deletes all markers in the array by removing references to them
function deleteOverlays() {
    if (markersArray) {
        for (i in markersArray) {
            markersArray[i].setMap(null);
        }
        markersArray.length = 0;
    }
}
google.maps.event.addDomListener(window, 'load', initialize);