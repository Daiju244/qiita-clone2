class Tag < ApplicationRecord
    has_many :articles, through: :tag_article
end
