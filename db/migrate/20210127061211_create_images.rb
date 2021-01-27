class CreateImages < ActiveRecord::Migration[6.1]
  def change
    create_table :images do |t|
      t.string     :image
      t.references :article, foregin_key: true

      t.timestamps
    end
  end
end
