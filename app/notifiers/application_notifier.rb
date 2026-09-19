class ApplicationNotifier < AbstractNotifier::Base
  self.async_adapter = AbstractNotifier::AsyncAdapters::ActiveJob.new(job: NotifierDeliveryJob)
end
