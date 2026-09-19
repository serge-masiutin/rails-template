class Ui::NoticeComponent < ApplicationComponent
  VARIANTS = {
    notice: "border-success/30 bg-success/10 text-ink",
    alert: "border-danger/30 bg-danger/10 text-ink"
  }.freeze

  def initialize(message:, variant: :notice)
    @message = message
    @classes = VARIANTS.fetch(variant)
    @role = variant == :alert ? "alert" : "status"
  end
end
