class ApplicationPolicy < ActionPolicy::Base
  # Unknown rules must fail instead of falling back to manage?.
  default_rule nil
end
