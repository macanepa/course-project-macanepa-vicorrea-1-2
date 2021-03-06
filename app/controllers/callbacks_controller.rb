class CallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env['omniauth.auth'])
    is_in_blacklist = @user.is_in_blacklist
    is_blocked = @user.is_in_block_list
    if !is_in_blacklist && !is_blocked
      if @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
        @user.update(last_access: Time.now)
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.google_data'] = request.env['omniauth.auth'].except(:extra) # Removing extra as it can overflow some session stores
        redirect_to new_user_registration_url, notice: @user.errors.full_messages.join("\n")
      end
    else
      if is_in_blacklist
        exit_date = @user.get_blacklist_entry_date + 1.week.to_i
        if Time.now < exit_date
          redirect_to root_path, alert: "Your account has been suspended until " + exit_date.to_s
        else
          black_to_remove = Blacklist.where(user_id: @user.id, exit_date: nil).first
          black_to_remove.update(exit_date: Time.now)
          flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
          @user.update(last_access: Time.now)
          sign_in_and_redirect @user, event: :authentication
        end
      elsif is_blocked
        redirect_to root_path, alert: "Your account has been blocked."
      end
    end
  end
end