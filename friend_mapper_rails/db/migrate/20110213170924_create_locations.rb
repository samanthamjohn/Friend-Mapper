class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.float     :latitude
      t.string    :name, :limit => 100, :unique => true, :null => false
      t.float     :longitude
      t.timestamps
    end
    add_index :locations, :name, :name => 'name_ix', :unique => true
  end


  def self.down
    drop_table :locations
  end
end
