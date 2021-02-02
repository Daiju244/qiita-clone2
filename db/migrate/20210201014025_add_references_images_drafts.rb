class AddReferencesImagesDrafts < ActiveRecord::Migration[5.2]
  def change
    add_reference :images, :draft, foreign_key: true
  end
end