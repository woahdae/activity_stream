class CreateQualifiedLeads < ActiveRecord::Migration
  def create
    create_table :activity_stream_activities do |t|
      t.integer  "actor_id"
      t.string   "actor_type"
      t.string   "verb"
      t.integer  "obj_id"
      t.string   "obj_type"
      t.integer  "target_id"
      t.string   "target_type"
      t.text     "data"
      t.datetime "created_at"
    end

    add_index "activity_stream_activities",
      ["created_at"],
      name: "index_activity_stream_activities_on_created_at",
      using: :btree
  end
end
