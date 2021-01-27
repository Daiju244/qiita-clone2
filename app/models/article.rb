# さらに内部のシステムを作り込みます。まずはarticleモデルを編集しましょう。
# 3~4行目を追加しました。3行目ではimageモデルとのアソシエーションを定義しています。4行目は新らしく出てきた記述で、これを書くことで先ほどのfields_forという記述が有効になります。
class Article < ApplicationRecord
    # mount_uploader :thumbnail, ImageUploader
    has_many :images
    accepts_nested_attributes_for :images, allow_destroy: true
end
