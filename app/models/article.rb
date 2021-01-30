# さらに内部のシステムを作り込みます。まずはarticleモデルを編集しましょう。
# 3~4行目を追加しました。3行目ではimageモデルとのアソシエーションを定義しています。4行目は新らしく出てきた記述で、これを書くことで先ほどのfields_forという記述が有効になります。

# はい、エラーでした。原因は「外部キー」です。外部キーとは、imagesテーブルに存在するarticle_idというカラムのことです。ブログ記事の情報を保存している「articlesテーブル」があったと思いますが、このテーブルは、記事本文の画像を保存するための「imagesテーブル」と外部キーを通してつながってます。

# そんな状態の最中、articlesテーブルのレコードが突然削除されてしまうとどうなるでしょうか。imagesテーブルのレコードは「存在しない記事」を参照することになりますが、これはできません。なので、エラーを発生させて「articlesテーブルのレコードは削除させないぞ！」と言ってくるわけです。ならば、imagesテーブルのレコードごと消し去ってやりましょう。

# 4~5行目を追加しました。1つの記事には、複数のタグを設定できます。なのでhas_manyです。through: :tag_articleという記述が新たに出てきましたが、これについてはあとで説明します。続けてtagモデルを編集です。

class Article < ApplicationRecord
    # mount_uploader :thumbnail, ImageUploader
    has_many :images, dependent: :destroy
    has_many :tags, through: :tag_article
    has_many :tag_articles, dependent: :destroy
    # accepts_nested_attributes_for :images, allow_destroy: true
end
