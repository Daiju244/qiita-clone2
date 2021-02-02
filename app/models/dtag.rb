class Dtag < ApplicationRecord
    has_many :drafts, through: :tag_draft
end
