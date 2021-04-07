class RoomEquivalence < ApplicationRecord
    belongs_to :user
    belongs_to :room_category
    belongs_to :price_equivalence
end
