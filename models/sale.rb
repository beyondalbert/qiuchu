class Sale < ActiveRecord::Base
  validates_presence_of :subject
end