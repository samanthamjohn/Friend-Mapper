class UniqueFbId < ActiveRecord::Migration
  def self.up
    change_column(:users, :fb_id, :string, :limit => 40, :null => false, :unique => true)
  end

  def self.down
    change_column(:users, :fb_id, :string, :limit => 40, :null => false)
  end
end
