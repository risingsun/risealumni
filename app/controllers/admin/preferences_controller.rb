class Admin::PreferencesController < ApplicationController
  layout "admin"
  
  def index
    @preferences_groups = PreferenceGroup.find(:all)
  end
  
  def new_preference
    @preference = Preference.new
    render :update do |page|
      page.replace_html "preference_group#{params[:id]}", :partial =>'new'
    end
  end
  
  def create
    @preference = Preference.new(params[:preference])
    if @preference.save
      redirect_to admin_preferences_path
    else
      flash[:notice] = " Not created successfully"
      redirect_to admin_preferences_path
    end
   
  end
  
  def edit_preferences
    @preferences = Preference.find(:all, :conditions => ['preference_group_id =?', params[:id]])
    render :update do |page|
      page.replace_html "preference_group#{params[:id]}", :partial =>'edit'
    end
  end
  
  def  update_preferences
    params[:preferences].values.each do |preference|
      @preference = Preference.find(:first, :conditions => ['id =?',preference[:id]]) 
      @preference.update_attributes(preference) unless preference[:preference_value].blank?
    end
    redirect_to admin_preferences_path
  end
  
  def new_title
    @title = Title.new
    render :update do |page|
      page.replace_html "title", :partial =>'new_title'
    end
  end
  
  def add_title
    @title = Title.new(params[:title])
    unless params[:title][:name].blank?
      unless @title.save 
        flash[:notice] = " Not created successfully"
      end
    end
    redirect_to admin_preferences_path
  end
  
  def new_house_name
    @house_name = HouseName.new
    render :update do |page|
      page.replace_html "house_name", :partial =>'new_house_name'
    end
  end
  
  def add_house_name
    @house_name = HouseName.new(params[:house_name])
    unless params[:house_name][:name].blank?
      unless @house_name.save 
        flash[:notice] = " Not created successfully"
      end
    end
    redirect_to admin_preferences_path
  end
  
  def edit_title
    @titles = Title.find(:all)
    render :update do |page|
      page.replace_html "title", :partial =>'edit_title'
    end
  end
  
  def update_title
    params[:titles].values.each do |title|
      @title = Title.find(:first, :conditions => ['id =?',title[:id]]) 
      @title.update_attributes(title)
    end
    redirect_to admin_preferences_path
  end
  
  def edit_house_name
    @house_names = HouseName.find(:all)
    render :update do |page|
      page.replace_html "house_name", :partial =>'edit_house_name'
    end
  end
  
  def update_house_name
    params[:house_names].values.each do |house_name|
      @house_name = HouseName.find(:first, :conditions => ['id =?',house_name[:id]]) 
      @house_name.update_attributes(house_name)
    end
    redirect_to admin_preferences_path
  end
  
  def destroy
    @preference = Preference.find(params[:id])
    @preference.destroy if @preference 
    render :update do |page|
      page.redirect_to admin_preferences_path
    end
  end
  
  def delete_title
    @title =Title.find(params[:id])
    @title.destroy if @title
    render :update do |page|
      page.redirect_to admin_preferences_path
    end
  end
  
  def delete_house_name
    @housename =HouseName.find(params[:id])
    @housename.destroy if @housename
    render :update do |page|
      page.redirect_to admin_preferences_path
    end
  end
  
  private
  
  def allow_to
    super :admin, :all => true
  end
  
end
