class SignalsController < ApplicationController
  def create
    data = params.dig(:signal)
    Rails.logger.info(data)
    render json: JSON.dump(data)
  end
end
