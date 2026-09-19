class OperationsUpdatesChannel < Turbo::StreamsChannel
  def subscribed
    user = connection.current_user
    if user.admin? && verified_stream_name_from_params == Operations::Updates::STREAM
      stream_from Operations::Updates::STREAM
      stream_from Operations::Updates.access_stream(user.id)
    else
      reject
    end
  end
end
