class OperationsUpdatesChannel < Turbo::StreamsChannel
  def subscribed
    user = connection.current_user
    if user.admin? && verified_stream_name_from_params == Realtime::OperationsUpdates::STREAM
      stream_from Realtime::OperationsUpdates::STREAM
      stream_from Realtime::OperationsUpdates.access_stream(user.id)
    else
      reject
    end
  end
end
