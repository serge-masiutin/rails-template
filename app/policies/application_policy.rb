class ApplicationPolicy < ActionPolicy::Base
  # An unknown rule is a contract error, not an implicit fallback to manage?.
  default_rule nil
end
