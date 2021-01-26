class Users::RegistrationsController < Devise::RegistrationsController

  def new
    @user = User.new
  end

  def create
    @user = User.new(sign_up_params)
    if @user.valid?
      session["devise.regist_data"] = {user: @user.attributes}
      session["devise.regist_data"][:user]["password"] = params[:user][:password]
      redirect_to profiles_path
    else
      render :new
    end
  end

  def new_profile
    @user = User.new(session["devise.regist_data"]["user"])
    @profile = Profile.new
  end

  def create_profile
    @user = User.new(session["devise.regist_data"]["user"])
    @profile = Profile.new(profile_params)
    if @profile.valid?
      @user.save
      @profile = Profile.new(profile_params.merge(user_id: @user.id))
      @profile.save
      session["devise.regist_data"]["user"].clear
      sign_in(:user, @user)
    else
      render :new_profile
    end
  end

  protected

  def profile_params
    params[:profile].permit(:email_publish, :nickname, :site, :company, :residence, :profile, :twitter, :facebook)
  end

end