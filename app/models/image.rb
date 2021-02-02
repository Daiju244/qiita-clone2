# 2~3行目を追加しています。2行目はアソシエーションです。3行目はサムネイルの時と同様、imageモデルのimageカラムをアップロードするために必要な記述です。
# 3行目にdraftsテーブルについてのアソシエーションを定義しました。また、2~3行目にoptional: trueという記述を追加しました。これは、外部キーに設定したカラムが空であっても保存を許可するための記述です。外部キーは特に保存条件を設定しなくとも、最初から「存在すること」が保存条件として義務付けられる設定になっています。しかし今回の場合、下書き保存すればarticle_idが、通常の投稿をすればdraft_idが空になり、意図した動作でありながらエラーになってしまいます。こうした場合は、optional: trueを指定してエラーを回避しましょう。
class Image < ApplicationRecord
    belongs_to :article, optional: true
    belongs_to :draft,   optional: true
    # mount_uploader :image, ImageUploader
end
