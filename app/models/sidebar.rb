class Sidebar
  COMMON_SIDEBAR_ITEMS = ["events", "tickets"].freeze
  CUSTOMER_SIDEBAR_ITEMS =  COMMON_SIDEBAR_ITEMS + [].freeze
  ORGANIZER_SIDEBAR_ITEMS =  COMMON_SIDEBAR_ITEMS + ["bookings"].freeze

  def self.sidebar_items(current_user)
    current_user.role.to_s == "organizer" ? organizer_sidebar_items(current_user) : customer_sidebar_items(current_user)
  end

  def self.common_sidebar_items(current_user)
    {
      "dashboard" => {
        "title" => "Dashboard",
        "icon" => Sidebar.icon_path("home"),
        "path" => "/users/#{current_user.id}/dashboard"
      },
      "events" => {
        "title" => "Events",
        "icon" => Sidebar.icon_path("events"),
        "path" => "/users/#{current_user.id}/events"
      }
    }.freeze
  end

  def self.customer_sidebar_items(current_user)
    common_sidebar_items(current_user).merge({
      "tickets" => {
        "title" => "Tickets",
        "icon" => Sidebar.icon_path("ticket"),
        "path" => "/users/#{current_user.id}/tickets"
      },
      "bookings" => {
        "title" => "Bookings",
        "icon" => Sidebar.icon_path("ticket"),
        "path" => "/users/#{current_user.id}/bookings"
      }
    }).freeze
  end

  def self.organizer_sidebar_items(current_user)
    common_sidebar_items(current_user).freeze
  end

  def self.icon_path(icon_name)
    # these are the icons from heroicons.com
    case icon_name
    when "home"
      "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
    when "calendar"
      "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
    when "ticket"
      "M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"
    when "bookings"
      "M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"
    when "dashboard"
      "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
    else
      "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
    end
  end

end
