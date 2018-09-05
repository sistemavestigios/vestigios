class UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy]

  def index
    authorize @users = User.all
  end

  def new
    @user = User.new
  end

  def edit; end

  def create
    authorize @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: t('success.create', model: User.model_name.human)
    else
      render :new
    end
  end

  def update
    if @user.update(user_params.delete_if { |k| user_params[k].empty? })
      redirect_to root_path, notice: t('success.update', model: User.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: t('success.destroy', model: User.model_name.human)
  end

  private

  def set_user
    authorize @user = User.find(params[:id])
  end

  def user_params
    permitted_params = %i[email name password]
    permitted_params.push(:role_id) if current_user.can_change_role_for_user?(@user)
    params
      .require(:user)
      .permit(*permitted_params)
  end
end
