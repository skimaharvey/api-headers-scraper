class User < ApplicationRecord
    has_secure_password

    validates_presence_of :email
    validates_uniqueness_of :email
    has_one :hotel_owner
    has_one :hotel, through: :hotel_owner
    has_many :hotel_competitors
    has_many :hotels, through: :hotel_competitors

end

#TODAY EACH USER HAS_ONE HOTEL AND HAS_MANY COMPETITOR