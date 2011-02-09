class User < ActiveRecord::Base
  has_many :friendships
  has_many :friends, :through => :friendships, :foreign_key => :friend_id, :source => :user 
  belongs_to :friendship
end
