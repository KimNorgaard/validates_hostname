class CreateZones < ActiveRecord::Migration
  def self.up
    create_table :zones do |t|
      t.string  :name,     :null => false
      t.string  :master,   :null => true
      t.string  :mname,    :null => false
      t.string  :rname,    :null => false
      t.integer :serial,   :null => false
      t.integer :refresh,  :null => false, :default => 10800
      t.integer :retry,    :null => false, :default => 3600
      t.integer :expire,   :null => false, :default => 604800
      t.integer :minimum,  :null => false, :default => 3600
      t.boolean :active,   :null => false, :default => 1

      t.timestamps

      t.references :zone_type, :null => false, :default => 1
    end

    add_index :zones, :name
  end

  def self.down
    drop_table :zones
  end
end
