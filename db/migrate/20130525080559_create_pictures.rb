class CreatePictures < ActiveRecord::Migration
  def up
    create_table :pictures do |t|
      t.integer :item_id
      t.string :item_type
      t.string :name
      t.string :path
      t.integer :size
      t.timestamps
    end
  end

  def down
    drop_table :pictures
  end
end
