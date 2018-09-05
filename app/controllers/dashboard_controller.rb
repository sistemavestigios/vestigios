class DashboardController < ApplicationController
  def catch_404
    raise ActionController::RoutingError, params[:path]
  end

  def index; end
end
