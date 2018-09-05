class UsersController < ApplicationController
  def index
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Usuários'
    @users = authorize User.all
    @roles = Role.all
  end

  def update
    @user = User.find(params[:id])
    role = Role.find(params[:user][:roles_attributes][:id])
    @user.add_role role.name
    @user.save
    redirect_to users_path
  end
end
