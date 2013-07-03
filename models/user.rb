class User < ActiveRecord::Base

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :password_hash
  validates_presence_of :password_salt

  has_one :picture, :as => :item, :dependent => :destroy
  has_many :sales, :dependent => :destroy
  has_many :wants, :dependent => :destroy
end