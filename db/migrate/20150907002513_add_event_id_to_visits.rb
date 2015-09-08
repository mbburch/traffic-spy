class AddEventIdToVisits < ActiveRecord::Migration
  def change
    change_table :visits do |t|
      t.remove :event_name
      t.integer :event_id
    end
  end
end
