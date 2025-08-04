class ShowCommand < BaseCommand
  def run
    resource = @klass.find_by_id(params[:id])
    if resource.present?
      return {data: resource}
    else
      raise BaseCommand::CommandError.new({message: "#{@klass.to_s} not found", status_code: :not_found})
    end
  end
end