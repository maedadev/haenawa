module CurrentUser
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  private

  def current_user
    if @_current_user.nil?
      @_current_user = User.new
    end
    @_current_user
  end

end