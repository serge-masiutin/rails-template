class CreateAgentTraces < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_traces do |t|
      t.string :trace_id, null: false
      t.datetime :started_at, null: false
      t.jsonb :document, null: false
    end
    add_index :agent_traces, :trace_id, unique: true
    add_index :agent_traces, :started_at
  end
end
