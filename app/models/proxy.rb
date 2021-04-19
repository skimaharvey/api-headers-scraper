class Proxy < ApplicationRecord
    validates :proxy_body, :presence => true
    validates :port, :presence => true
end
