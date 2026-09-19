class AccountsController < ApplicationController
  def show
    authorize! Current.user
  end
end
