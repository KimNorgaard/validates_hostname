class CreateZones < ActiveRecord::Migration
  def self.up
    create_table :zones do |t|
      t.string :origin,    :null => false
      t.string :master,    :null => false
      t.string :ns,        :null => false
      t.string :mbox,      :null => false
      t.integer :serial,   :null => false, :default => 1
      t.integer :refresh,  :null => false, :default => 10800
      t.integer :retry,    :null => false, :default => 3600
      t.integer :expire,   :null => false, :default => 604800
      t.integer :ttl,      :null => false, :default => 3600
      t.boolean :active,   :null => false, :default => 1

      t.timestamps

      t.references :zone_type
    end

    add_index :zones, :origin
  end

  def self.down
    drop_table :zones
  end
end
