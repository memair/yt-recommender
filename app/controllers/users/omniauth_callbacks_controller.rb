class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def memair
    @user = User.from_memair_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in(:user, @user)
      flash[:notice] = 'Successfully installed'
      redirect_to root_path
    else
      session['devise.memair_data'] = request.env['omniauth.auth'].except(:extra) # Removing extra as it can overflow some session stores
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    flash[:error] = 'You must authorize YT Recommender so that it can make recommendations in the Memair Player'
    redirect_to root_path
 end
end
