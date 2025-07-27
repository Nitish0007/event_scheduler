class Booking::Index < IndexCommand
  private
  def base_query
    @klass.where(user_id: @user.id)
  end
end