class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.text :name
      t.integer :source_id
    end
  end
end
