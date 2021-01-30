class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      # 指定したカラムに空の状態で保存させるのを防ぎます。
      t.string :name, null: false

      t.timestamps
    end
  end
end
