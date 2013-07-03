class Want <ActiveRecord::Base
  validates_presence_of :subject

  has_many :pictures, :as => :item, :dependent => :destroy
  belongs_to :user
end