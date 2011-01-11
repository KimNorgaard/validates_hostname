class CreateZoneTypes < ActiveRecord::Migration
  def self.up
    create_table :zone_types do |t|
      t.string :name, :null => false

      t.timestamps
    end

    add_index :zone_types, :name
  end

  def self.down
    drop_table :zone_types
  end
end
