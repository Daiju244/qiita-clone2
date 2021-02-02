class CreateDrafts < ActiveRecord::Migration[5.2]
  def change
    create_table :drafts do |t|
      t.string     :title,     null: false
      t.string     :thumbnail, null: false
      t.string     :abstract,  null: false
      t.text       :body,      null: false#, limit: 4294967295
      t.references :user,      null: false, foreign_key: true

      t.timestamps
    end
  end
end
