class Photo < ActiveRecord::Base

  belongs_to :profile
  require 'RMagick'
  validates_presence_of :image, :profile_id
  
  attr_accessor :x,:y,:width, :height
  has_attached_file :image,
    :styles => { :original => "975x800>"}
  named_scope :blurb_images,{:conditions => "set_as_blurb = true"}
  named_scope :images,{:conditions => "set_as_blurb != true"}
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  
  def update_attributes(att)
    unless [att[:x], att[:y], att[:width], att[:height] ].reject!(&:blank?)
      scaled_img = Magick::ImageList.new(self.image.path)
      orig_img = Magick::ImageList.new(self.image.path(:original))
      scale = orig_img.columns.to_f / scaled_img.columns
      args = [att[:x], att[:y], att[:width], att[:height] ]
      args = args.collect { |a| a.to_i * scale }
      orig_img.crop!(*args)
      orig_img.write(self.image.path(:original))
      self.image.reprocess!
    end
    self.save
    super(att)
  end

end