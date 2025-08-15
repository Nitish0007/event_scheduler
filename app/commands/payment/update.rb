class Payment::Update < UpdateCommand
  def run
    begin
      ActiveRecord::Base.transaction do
        Rails.logger.info "Payment::Update params: #{@params.inspect}"
        payment = Payment.find_by(id: @params[:id], user_id: @user.id)
        payment.update!(status: :processing, payment_method: payment_params[:payment_method].to_sym)
        ProcessPaymentJob.perform_async(payment.id)
        return {
          success: true, 
          message: 'Payment is being processed.', 
          client_secret: payment.client_secret,
          payment_id: payment.id
        }
      rescue StandardError => e
        raise BaseCommand::CommandError.new(e.message)
      end
    rescue BaseCommand::CommandError => e
      raise e
    rescue => e
      raise e
    end
  end

  private
  def payment_params
    @params.require(:payment).permit(:payment_method)
  end
end