# 多対多のアソシエーションを定義するためには、代わりに子モデルになってくれるモデルを別で作るのです。tag_articlesテーブルには、2つのモデルを参照するために、2つの外部キーを持たせます。
class TagArticle < ApplicationRecord
    belongs_to :article
    belongs_to :tag
end
