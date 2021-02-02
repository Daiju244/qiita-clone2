class CreateTagDrafts < ActiveRecord::Migration[6.1]
  def change
    create_table :tag_drafts do |t|
      t.references :draft, null: false, foregin_key: true
      t.references :dtag,  null: false, foregin_key: true

      t.timestamps
    end
  end
end
