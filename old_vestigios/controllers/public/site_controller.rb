class Public::SiteController < ApplicationController
  skip_before_action :authenticate_user!

  # respond_to :html
  def index
    add_breadcrumb 'Homepage', '/'
    if user_signed_in?
      redirect_to dashboard_path if params[:homepage].nil?
    end
  end

  def forbidden
    add_breadcrumb 'Área Restrita', '/'
    # render :layout => "forbidden"
    render 'public/site/forbidden'
  end
end
