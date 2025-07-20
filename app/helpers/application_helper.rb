module ApplicationHelper
  def notice
    flash[:notice] if flash[:notice].present?
  end

  def alert
    flash[:alert] if flash[:alert].present?
  end
end
