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

  def inr_currency(amount)
    number_to_currency(amount, unit: "₹", delimiter: ",", separator: ".", precision: 2)
  end
  
  # Helper method to render modal boxes with consistent parameters
  def render_modal_box(options = {}, &block)
    locals = {
      modal_id: options[:id] || 'default',
      modal_title: options[:title] || '',
      modal_actions: options[:actions] || []
    }
    
    # Only add subtitle if it exists
    locals[:modal_subtitle] = options[:subtitle] if options[:subtitle].present?
    
    # Always use render partial, but handle the block differently
    if block_given?
      # Capture the block content
      block_content = capture(&block)
      render partial: 'shared/modalbox', locals: locals.merge(content: block_content)
    else
      render partial: 'shared/modalbox', locals: locals
    end
  end

  # Helper method to create modal actions array
  def modal_actions(*actions, paths)
    actions.map do |action|
      case action
      when :confirm
        { type: 'primary', text: 'Confirm', action: 'click->modal#confirm', target: 'confirm-button', path: paths[:confirm] }
      when :cancel
        { type: 'secondary', text: 'Cancel', action: 'click->modal#cancel', target: 'cancel-button', path: paths[:cancel] }
      when :delete
        { type: 'danger', text: 'Delete', action: 'click->modal#delete', target: 'delete-button', path: paths[:delete] }
      when :save
        { type: 'primary', text: 'Save', action: 'click->modal#confirm', target: 'save-button', path: paths[:save] }
      when :close
        { type: 'secondary', text: 'Close', action: 'click->modal#close', target: 'close-button', path: paths[:close] }
      else
        action
      end
    end
  end

  # Helper method to create a simple confirmation modal
  def confirmation_modal(id:, title:, message:, confirm_text: 'Confirm', cancel_text: 'Cancel')
    render_modal_box(
      id: id,
      title: title,
      actions: modal_actions(:confirm, :cancel)
    ) do
      content_tag(:p, message, class: 'text-gray-700')
    end
  end

  # Helper method to create a delete confirmation modal
  def delete_confirmation_modal(id:, title:, message:, item_name:)
    render_modal_box(
      id: id,
      title: title,
      subtitle: "This action cannot be undone.",
      actions: modal_actions(:delete, :cancel)
    ) do
      content_tag(:p, message, class: 'text-gray-700')
    end
  end

  # Helper method to create an info modal
  def info_modal(id:, title:, message:)
    render_modal_box(
      id: id,
      title: title,
      actions: modal_actions(:close)
    ) do
      content_tag(:p, message, class: 'text-gray-700')
    end
  end

  # Helper method to create a warning modal
  def warning_modal(id:, title:, message:)
    render_modal_box(
      id: id,
      title: title,
      actions: modal_actions(:confirm, :cancel)
    ) do
      content_tag(:p, message, class: 'text-gray-700')
    end
  end

  # Helper method to create a success modal
  def success_modal(id:, title:, message:)
    render_modal_box(
      id: id,
      title: title,
      actions: modal_actions(:close)
    ) do
      content_tag(:p, message, class: 'text-gray-700')
    end
  end
end
