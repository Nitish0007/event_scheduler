module ApplicationHelper
  def notice
    flash[:notice] if flash[:notice].present?
  end

  def alert
    flash[:alert] if flash[:alert].present?
  end

  def show_link(path, id)
    path.gsub(":id", id.to_s).to_s
  end
end
