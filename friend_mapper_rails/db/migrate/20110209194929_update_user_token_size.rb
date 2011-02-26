class UpdateUserTokenSize < ActiveRecord::Migration
  def self.up
    change_column(:users, :fb_token, :string, :limit => 120)
  end

  def self.down
    change_column(:users, :fb_token, :string, :limit => 50)
  end
end
