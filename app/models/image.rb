# 2~3行目を追加しています。2行目はアソシエーションです。3行目はサムネイルの時と同様、imageモデルのimageカラムをアップロードするために必要な記述です。
class Image < ApplicationRecord
    belongs_to :article
    # mount_uploader :image, ImageUploader
end
