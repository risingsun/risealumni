module PreferencesHelper
  
  def group(id)
    PreferenceGroup.find(:first,:conditions => ['id =?',id]).group.titlecase
  end
  
  
end
