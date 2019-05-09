class ApplicationController < ActionController::Base

  $user_type = 0

  def update_type_admin
    $user_type = 1
    redirect_to 'http://localhost:3000'
  end

  def update_type_regular_user
    $user_type = 2
    redirect_to 'http://localhost:3000'
  end

  def update_type_guest_user
    $user_type = 3
    redirect_to 'http://localhost:3000'
  end

end
