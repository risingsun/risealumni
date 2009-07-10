 
module GlobalModule
begin
Preference.find_all_preferences.keys.each do |key|  # => For the time being cause error running rake task. TODO
    p = Preference.find_all_preferences
    klass =Class.new
    class_name = Object.const_set key, klass
    p[key].keys.each do |p_key|
      class_name.class_eval do
        ws_notify = <<-EOF
            def self.#{p_key}
              return "#{(p[key][p_key])}"
            end
        EOF
        class_eval ws_notify, __FILE__, __LINE__
      end
    end
  end
rescue
end
end

def house_names
  house_name = []
  HouseName.find(:all,:order => 'name').each do|housename|
    house_name << [housename.name]
  end
  house_name
end
  
def titles
  titles = []
  Title.find(:all, :order => 'name').each do |title|
    titles << [title.name]
  end
  titles
end
