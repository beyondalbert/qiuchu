class CreateWants < ActiveRecord::Migration
  def up
    create_table :wants do |t|
      t.string :subject
      t.text :description
      t.integer :phone
      t.integer :user_id
      t.integer :seller
      t.integer :status
      t.float :longitude
      t.float :latitude
      t.string :location
      t.timestamps
    end
  end

  def down
    drop_table :wants
  end
end
