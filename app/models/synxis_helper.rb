class SynxisHelper < ApplicationRecord
  belongs_to :hotel, optional: true
  after_initialize :init
  serialize :body_request, Hash

  def init
    self.url  ||= "https://be.synxis.com/gw/product/v1/getProductAvailability"  
    self.body_request =  {"Paging":{"Size":200},"ProductAvailabilityQuery":{"OnlyCheckRequested":false,"ReturnFullContentDetails":true,"Chain":{"Id":"18985"},"Hotel":{"Id":"68208"},"AccessCode":{},"Currency":{"currencyCode":"EUR"},"ChannelList":{"PrimaryChannel":{"Code":"WEB"},"SecondaryChannel":{"Code":"GC"}},"LoyaltyList":[],"NumRooms":1,"ProductSortingType":"RoomsThenRates","RoomStay":{"EndDate":"2021-04-16","StartDate":"2021-04-15","GuestCount":[{"AgeQualifyingCode":"Adult","NumGuests":1},{"AgeQualifyingCode":"Child","NumGuests":0,"Ages":[]}],"RateFilterList":[]},"Template":{"Code":"CHAIN_CONFIGS","Level":"chain"}},"UserDetails":{"Preferences":{"Language":{"code":"fr-FR"},"ResponseOptions":"IncludeMealPlan"}},"Version":1}.to_hash
  end

end
