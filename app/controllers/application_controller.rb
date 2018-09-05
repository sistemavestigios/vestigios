class ApplicationController < ActionController::Base
  include Pundit
  # after_action :verify_authorized
  before_action :authenticate_user!
  protect_from_forgery with: :exception

  rescue_from StandardError do |error|
    Rollbar.error(error)
    flash[:alert] = 'Isso gerou um erro, o administrador foi notificado'
    redirect_to root_path
  end

  rescue_from ActionController::RoutingError do |error|
    Rollbar.error(error)
    flash[:alert] = 'Página não encontrada'
    redirect_to root_path
  end

  rescue_from Pundit::NotAuthorizedError do
    raise if Rails.env.test?
    flash[:alert] = t('authorization.not_authorized')
    redirect_to(request.referrer || root_path)
  end

  private

  def current_rollbar_user
    OpenStruct.new(
      id: current_user.id,
      email: current_user.email,
      name: current_user.name
    )
  end
end
