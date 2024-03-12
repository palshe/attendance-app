class CreateAttendances < ActiveRecord::Migration[7.0]
  def change
    create_table :attendances do |t|
      t.date :date
      t.datetime :arrived_at
      t.datetime :left_at
      t.float :overtime
      t.references :worker, null: false, foreign_key: true

      t.timestamps
    end
    add_index :attendances, [:date, :worker_id], unique: true
  end
end
