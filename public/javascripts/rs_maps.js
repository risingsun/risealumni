function create_draggable_editable_marker()
{
  // intialize the values in form fields to 0
  document.getElementById("map_lng").value = 0;
  document.getElementById("map_lat").value = 0;
  var currMarker;
  // if the user click on an existing marker remove it
  GEvent.addListener(map, "click", function(marker, point) {
    if (marker) {
      if (confirm("Do you want to delete marker?")) {
        map.removeOverlay(marker);
      }
    }
    // if the user clicks somewhere other than existing marker
    else {
      // remove the previous marker if it exists
      if (currMarker) {
        map.removeOverlay(currMarker);
      }
      currMarker = new GMarker(point, {draggable: true});
      map.addOverlay(currMarker);
      // update the form fields
      document.getElementById("map_lng").value = point.x;
      document.getElementById("map_lat").value = point.y;
      document.getElementById("map_zoom").values = map.getZoom();
    }
    // Similarly drag event is used to update the form fields
    GEvent.addListener(currMarker, "drag", function() {
      document.getElementById("map_lng").value = currMarker.getLatLng().lng();
      document.getElementById("map_lat").value = currMarker.getLatLng().lat();
    });
    
    GEvent.addListener(map,"zoomend", function(oldzoom,newzoom) {
      document.getElementById("map_zoom").value = newzoom;
    });
    
  });
}

function create_draggable_marker_for_edit(lat, lng,zoom) {
  // initalize form fields
  document.getElementById('map_lng').value = lng;
  document.getElementById('map_lat').value = lat;
  document.getElementById("map_zoom").values = zoom;
  // initalize marker
  var currMarker = new GMarker( new GLatLng(lat, lng), {draggable: true} );
  map.addOverlay(currMarker);
  // Handle drag events to update the form text fields
  GEvent.addListener(currMarker, 'drag', function() {
    document.getElementById('map_lng').value = currMarker.getLatLng().lng();
    document.getElementById('map_lat').value = currMarker.getLatLng().lat();
  });
  GEvent.addListener(map,"zoomend", function(oldzoom,newzoom) {
    document.getElementById("map_zoom").value = newzoom;
  });
}

