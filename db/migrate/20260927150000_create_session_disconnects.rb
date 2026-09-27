class CreateSessionDisconnects < ActiveRecord::Migration[8.1]
  def change
    create_table :session_disconnects do |t|
      t.bigint :session_ids, array: true, null: false
      t.datetime :created_at, null: false
      t.check_constraint "cardinality(session_ids) > 0 AND array_position(session_ids, NULL) IS NULL AND 0 < ALL(session_ids)",
        name: "session_disconnects_valid_ids"
    end
  end
end
