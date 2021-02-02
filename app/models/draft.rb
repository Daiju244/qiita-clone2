class Draft < ApplicationRecord
    # mount_uploader :thumbnail, ImageUploader
    has_many :images, dependent: :destroy
    has_many :dtags, through: :tag_drafts
    has_many :tag_drafts, dependent: :destroy
    accepts_nested_attributes_for :images, allow_destroy: true
  end
