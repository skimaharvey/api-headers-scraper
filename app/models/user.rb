class User < ApplicationRecord
    has_secure_password

    validates_presence_of :email
    validates_uniqueness_of :email
end

#TODAY EACH USER HAS_ONE HOTEL AND HAS_MANY COMPETITOR