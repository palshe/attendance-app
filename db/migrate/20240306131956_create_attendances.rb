class CreateAttendances < ActiveRecord::Migration[7.0]
  def change
    create_table :attendances do |t|
      t.date :date
      t.datetime :arrived_at
      t.datetime :left_at
      t.time :overtime
      t.references :worker, null: false, foreign_key: true

      t.timestamps
    end
  end
end
