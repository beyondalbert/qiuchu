class CreateSales < ActiveRecord::Migration
  def up
    create_table :sales do |t|
      t.string :subject
      t.text :description
      t.integer :price
      t.integer :user_id, :null => false
      t.integer :condition
      t.integer :phone
      t.integer :buger
      t.integer :status
      t.float :longitude
      t.float :latitude
      t.string :location
      t.timestamps
    end
  end

  def down
    drop_table :sales
  end
end
