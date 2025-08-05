class Sidebar
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
      },
      "tickets" => {
        "title" => "Tickets",
        "icon" => Sidebar.icon_path("ticket"),
        "path" => "/users/#{current_user.id}/tickets"
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
        "icon" => Sidebar.icon_path("bookings"),
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
      "M16.5 6v.75m0 3v.75m0 3v.75m0 3V18m-9-5.25h5.25M7.5 15h3M3.375 5.25c-.621 0-1.125.504-1.125 1.125v3.026a2.999 2.999 0 0 1 0 5.198v3.026c0 .621.504 1.125 1.125 1.125h17.25c.621 0 1.125-.504 1.125-1.125v-3.026a2.999 2.999 0 0 1 0-5.198V6.375c0-.621-.504-1.125-1.125-1.125H3.375Z"
    when "bookings"
      "M2.25 18.75a60.07 60.07 0 0 1 15.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 0 1 3 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 0 0-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 0 1-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 0 0 3 15h-.75M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm3 0h.008v.008H18V10.5Zm-12 0h.008v.008H6V10.5Z"
    when "dashboard"
      "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
    else
      "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
    end
  end

end


