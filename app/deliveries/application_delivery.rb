class ApplicationDelivery < ActiveDelivery::Base
  self.abstract_class = true
  register_line :notifier, ActiveDelivery::Lines::Notifier
end
