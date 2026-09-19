module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :session_id

    def connect
      session = Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
      reject_unauthorized_connection unless session
      self.session_id = session.id
    end

    def current_user
      Session.find(session_id).user
    end
  end
end
