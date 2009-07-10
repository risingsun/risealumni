class AddColumnMarkerToProfile < ActiveRecord::Migration
 def self.up
    add_column :profiles, :marker_id, :integer
    Marker.all.each  do |m|
      p = Profile.find(m.profile_id)
      p.update_attribute('marker_id', m.id)
    end
    remove_column :markers, :profile_id
  end

  def self.down
    add_column :markers, :profile_id, :integer
    Marker.all.each do |m|
      p = Profile.find_by_marker_id(m.id)
      m.update_attribute('profile_id', p.id)
    end
    remove_column:profiles, :marker_id
  end
end
