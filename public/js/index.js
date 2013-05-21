var map;
var markersArray = [];

$(function() {

    $('#query-form').submit(function() {
        $.ajax({url:'/query/' + $('#index_select').val() + '/' + $('#zip_input').val(), dataType:"json"}).done(function(data) {
//            $('#query-results').html(data);
            populateTable(data);
            addZombies(data);
        });

        return false;
    });
});

function initialize() {
    var groundZero = new google.maps.LatLng(40.294155, -83.002662);
    var mapOptions = {
        zoom: 12,
        center: groundZero,
        mapTypeId: google.maps.MapTypeId.TERRAIN
    };
    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);

    google.maps.event.addListener(map, 'click', function(event) {
        getZombies(event.latLng);
    });
}

function getZombies(latLng) {
    lat = latLng.lat();
    lon = latLng.lng();
    $.ajax({url:"/query/geo?lat=" + lat + "&lon=" + lon, dataType:"json"}).done(function (data) {
        populateTable(data);
        addZombies(data);
    });
}

function populateTable(data) {
    $('#query_results').empty();

    var header = ['dna','sex','name','address','city','state','zip','phone',
        'birthdate','ssn','job','bloodtype','weight','height'];

    var header_row= $('<tr>');
    $.each(header, function(i, head) {
        header_row.append($('<th>').text(head));
    });
    header_row.appendTo($('#query_results'));

    $.each(data, function(i, row) {
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

function addZombies(zombies) {
    clearOverlays();

    var bounds = new google.maps.LatLngBounds();

    $.each(zombies, function() {
        lat = parseFloat(this['latitude']);
        lon = parseFloat(this['longitude']);

        var position = new google.maps.LatLng(lat, lon);

        bounds.extend(position);

        addMarker(position);
    })

    map.fitBounds(bounds);
}

function addMarker(location) {
    marker = new google.maps.Marker({
        position: location,
        map: map
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