# 多対多のアソシエーションを定義するためには、代わりに子モデルになってくれるモデルを別で作るのです。tag_articlesテーブルには、2つのモデルを参照するために、2つの外部キーを持たせます。
class CreateTagArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :tag_articles do |t|
      t.references :article, null: false, foregin_key: true
      t.references :tag,     null: false, foregin_key: true

      t.timestamps
    end
  end
end

# これで、articlesテーブルとtagsテーブルがtag_articlesテーブルを通して多対多で繋がりました。このように、多対多を繋ぐためのテーブルを「中間テーブル」と呼んだりします。多対多は中間テーブルで繋ぐことができる、という事を是非覚えておきましょう。

# あとは、記事作成(create)のアクションにtagsテーブル・tag_articlesテーブルそれぞれのレコードを追加する処理を与えればOKです。