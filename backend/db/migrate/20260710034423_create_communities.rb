class CreateCommunities < ActiveRecord::Migration[8.1]
  def change
    create_table :communities do |t|
      t.string :name, null: false
      t.text :description
      t.datetime :created_at, null: false
    end

    add_index :communities, :name, unique: true
  end
end
