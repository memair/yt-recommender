class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user

  def profile
    @user = current_user
    @preferences = @user.preferences.includes(:channel).sort_by{ |pref| pref.channel.title.downcase }
  end

  def update
    updates = []
    params['preferences'].each do |preference_id, frequency|
      preference = current_user.preferences.find_by(id: preference_id)
      return redirect_to(user_path) if preference.nil?
      preference.frequency = frequency
      if preference.changed?
        preference.save
        updates.append(preference.channel.title)
      end
    end      
    
    flash[:success] = "Frequencies of #{updates.to_sentence} updated" unless updates.empty?
    redirect_to(user_path)
  end
end