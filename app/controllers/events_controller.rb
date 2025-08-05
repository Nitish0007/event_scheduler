class EventsController < BaseController
  before_action :allow_organizer_only, only: [:new, :create]

  def new
    super
  end

  def create
    super
  end
end