require "test_helper"

class AuthorizationProbeController < ApplicationController
  allow_unauthenticated_access

  def show
    Current.session = User.find(params.expect(:actor_id)).sessions.build
    authorize! User.find(params.expect(:id))
    head :ok
  end

  def unchecked
    head :ok
  end
end

class AuthorizationTest < ActionController::TestCase
  tests AuthorizationProbeController

  test "общий контроллер отвечает 403 при запрете policy" do
    with_routing do |routes|
      routes.draw { get "/probe", to: "authorization_probe#show" }
      get :show, params: { actor_id: users(:one).id, id: users(:two).id }
      assert_response :forbidden
    end
  end

  test "забытый authorize! вызывает ошибку" do
    with_routing do |routes|
      routes.draw { get "/probe", to: "authorization_probe#unchecked" }
      assert_raises(ActionPolicy::UnauthorizedAction) { get :unchecked }
    end
  end
end
