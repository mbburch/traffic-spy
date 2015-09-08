class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.text :name
      t.integer :source_id
    end

    create_table :registered_events do |t|
      t.text :event_name
      t.integer :campaign_id
    end
  end
end
