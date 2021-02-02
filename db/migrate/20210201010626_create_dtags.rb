class CreateDtags < ActiveRecord::Migration[5.2]
  def change
    create_table :dtags do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
