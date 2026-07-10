class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.datetime :created_at, null: false
    end

    add_index :users, :username, unique: true
  end
end
