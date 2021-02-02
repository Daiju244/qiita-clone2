class TagDraft < ApplicationRecord
    belongs_to :draft
    belongs_to :dtag
end

# これで一通りの設定は完了です。ただし、imagesテーブルとの関わりがarticlesテーブルのものとは一部異なりますので、ここから続けて設定していきます。