class User < ApplicationRecord
  has_one :profile
  has_one  :card,  dependent: :destroy
  has_many :likes, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end