class SignalsController < ApplicationController
  def create
    data = params.dig(:signal, :_json)
    Rails.logger.info(data)
    render json: JSON.dump(data)
  end
end
