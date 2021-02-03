class AddInpressionsCountToArticle < ActiveRecord::Migration[6.1]
  def change
    # articlesテーブルにimpressions_countというカラムを追加です。このカラムにPV数が自動的に集計されます。それでは、マイグレーションを実行しましょう。
    add_column :articles, :impressions_count, :integer, null: false, default: 0
  end
end
