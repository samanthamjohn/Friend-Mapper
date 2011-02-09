class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer :user_id, :null => false
      t.integer :friend_id, :null => false
      t.timestamps
    end
    add_index :friendships, :user_id, :name => :user_id_ix
  end

  def self.down
    drop_table :friendships
  end
end
