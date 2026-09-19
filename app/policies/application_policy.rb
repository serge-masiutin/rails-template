class ApplicationPolicy < ActionPolicy::Base
  # Неизвестное правило — ошибка контракта, а не неявный переход к manage?.
  default_rule nil
end
