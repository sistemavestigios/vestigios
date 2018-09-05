class DashboardController < ApplicationController
  def index
    add_breadcrumb 'Dashboard', dashboard_path
  end
end
