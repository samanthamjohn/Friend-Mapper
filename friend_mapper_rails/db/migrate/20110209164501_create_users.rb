class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :fb_id,          :string, :limit => 40, :null => false 
      t.column :first_name,     :string, :limit => 100
      t.column :last_name,      :string, :limit => 100
      t.column :location,       :string, :limit => 100
      t.column :latitude,       :float
      t.column :longitude,      :float
      t.column :fb_token,       :string, :limit => 50
      t.column :token_expires,  :datetime
      t.timestamps
    end
    
    add_index :users, :fb_id, :name => 'fb_id_ix', :unique => true
    add_index :users, :location, :name => 'location_id_ix'
  end

  def self.down
    drop_table :users
  end
end
