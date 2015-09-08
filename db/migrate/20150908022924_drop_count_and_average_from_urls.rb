class DropCountAndAverageFromUrls < ActiveRecord::Migration
  def change
    change_table :urls do |t|
      t.remove :average_response_time
      t.remove :visits_count
    end
  end
end
