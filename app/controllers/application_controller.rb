class ApplicationController < ActionController::Base

  def correct_user
    klass = params['controller'].classify.constantize
    record = klass.find_by_id(params['id'])
    unless record.nil?
      @user = record.user
      redirect_to(root_url) unless current_user == @user
    end
  end
end
