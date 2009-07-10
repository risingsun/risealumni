module EventsHelper
  
  def show_event_map
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)
    @map.set_map_type_init(GMapType::G_HYBRID_MAP)
    marker = GMarker.new([@event.marker.lat,@event.marker.lng],
      :title => "#{@event.place}",
      :info_window => " Event Location.")
    centre = @event.marker
    @map.center_zoom_init([centre.lat,centre.lng],centre.zoom)
    @map.overlay_global_init(marker,"Event_location")
   end
   
end
