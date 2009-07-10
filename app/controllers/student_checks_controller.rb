class StudentChecksController < ApplicationController
  layout 'admin'
  # GET /student_checks
  # GET /student_checks.xml
  def index
    if params[:year] || params[:all]
      @student_checks = StudentCheck.get_students(params).group_by(&:name)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @student_checks }
    end
  end

  # GET /student_checks/new
  # GET /student_checks/new.xml
  def new
    @student_check = StudentCheck.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @student_check }
    end
  end

  # GET /student_checks/1/edit
  def edit
    @student_check = StudentCheck.find(params[:id])
  end

  # POST /student_checks
  # POST /student_checks.xml
  def create
    @student_check = StudentCheck.new(params[:student_check])

    respond_to do |format|
      if @student_check.save
        flash[:notice] = 'StudentCheck was successfully created.'
        format.html { redirect_to(next_dest) }
        format.xml  { render :xml => @student_check, :status => :created, :location => @student_check }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @student_check.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /student_checks/1
  # PUT /student_checks/1.xml
  def update
    @student_check = StudentCheck.find(params[:id])

    respond_to do |format|
      if @student_check.update_attributes(params[:student_check])
        flash[:notice] = 'StudentCheck was successfully updated.'
        format.html { redirect_to(next_dest) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @student_check.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /student_checks/1
  # DELETE /student_checks/1.xml
  def destroy
    @student_check = StudentCheck.find(params[:id])
    @student_check.destroy

    respond_to do |format|
      format.html { redirect_to(student_checks_url) }
      format.xml  { head :ok }
    end
  end

  def send_bulk_invite
    @students = StudentCheck.with_emails
    @students.each {|s| ArNotifier.deliver_invite(s) unless s.emails.empty?}
    flash[:notice] = 'Bulk Invites sent.'
    redirect_back_or_default('/admin')
  end

  def send_invite
    @student = StudentCheck.find(params[:id])
    ArNotifier.deliver_invite(@student) unless @student.emails.empty?
    flash[:notice] = 'Invite sent.'
    redirect_back_or_default('/admin')
  end
  
  def view_year_students
    year = params[:year]
    @student_check = StudentCheck.new
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html "profile_field", 
                            :partial => 'profile', 
                            :locals => {:year => year}
        end
      end
    end
  end


  private
  
  def allow_to
    super :admin, :all => true
  end

  def next_dest
    case params[:commit]
    when "Update and Return"
      student_checks_path
    when "Update and Add Another"
      new_student_check_path
    when "Update and Edit"
      edit_student_check_path(@student_check)
    else
      student_checks_path
    end
  end
end
