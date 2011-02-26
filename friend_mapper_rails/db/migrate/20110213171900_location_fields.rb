class LocationFields < ActiveRecord::Migration
  def self.up
    add_column(:locations, :country, :string, :limit => 100)
    add_column(:locations, :state, :string, :limit => 40)
    add_column(:locations, :city, :string, :limit => 100)
  end

  def self.down
    remove_column(:locations, :country, :string, :limit => 100)
    remove_column(:locations, :state, :string, :limit => 40)
    remove_column(:locations, :city, :string, :limit => 100)
  end
end
