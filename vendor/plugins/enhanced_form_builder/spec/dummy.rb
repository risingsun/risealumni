class Dummy < ActiveRecord::Base
  class << self

    def create_fake_column(name, null = true, limit = nil)
      sql_type = limit ? "varchar (#{limit})" : nil
      col = ActiveRecord::ConnectionAdapters::Column.new(name, nil, sql_type, null)
      col
    end

    def columns
      [
       create_fake_column('col0'),
       create_fake_column('col1'),
       create_fake_column('col2', false),
       create_fake_column('col3', false, 100),
       create_fake_column('col4')
      ]
    end
  end
  
  has_one :nothing
  
  validates_presence_of :col1
  validates_format_of :col4, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
end