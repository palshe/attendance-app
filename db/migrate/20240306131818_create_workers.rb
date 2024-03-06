class CreateWorkers < ActiveRecord::Migration[7.0]
  def change
    create_table :workers do |t|
      t.string :name

      t.timestamps
    end
    add_index :workers, :name, unique: true
  end
end
