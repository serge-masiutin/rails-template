class HomeController < ApplicationController
  def index
    authorize! Current.user, to: :show?
  end
end
