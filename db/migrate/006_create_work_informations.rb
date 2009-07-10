class CreateWorkInformations < ActiveRecord::Migration
  def self.up
    create_table :work_informations do |t|
      t.integer :profile_id
      t.string :occupation
      t.string :industry
      t.string :company_name
      t.string :company_website
      t.text :job_description
      t.timestamps
    end
    i = 0
    Profile.find_each do |p|
      unless [p.occupation,p.industry,p.company_name,p.company_website,p.job_description].reject!(&:blank?)
        i += 1
        work = p.work_informations.new()
        work.occupation = p.occupation
        work.industry = p.industry
        work.company_name = p.company_name
        work.company_website = p.company_website
        work.job_description = p.job_description
        work.save!
      end
    end
    puts "#{i} record moved"
    remove_column :profiles, :occupation
    remove_column :profiles, :industry
    remove_column :profiles, :company_name
    remove_column :profiles, :company_website
    remove_column :profiles, :job_description
  end

  def self.down
    add_column :profiles, :occupation, :string
    add_column :profiles, :industry, :string  
    add_column :profiles, :company_name, :string
    add_column :profiles, :company_website, :string  
    add_column :profiles, :job_description, :text
    i = 0
    WorkInformation.find_each do |w|
        p = w.profile
        if p
          i += 1
          p.occupation = w.occupation
          p.industry = w.industry 
          p.company_name = w.company_name 
          p.company_website = w.company_website 
          p.job_description = w.job_description 
          p.save!
        end
    end
    puts "#{i} record moved"
    drop_table :work_informations
  end
end
