class SignalsController < ApplicationController
  FLUENTD_URL = "http://localhost:24224/signal"

  def create
    data = params.dig(:signal)
    send_signal(data[:x], data[:y])
    render json: JSON.dump(data)
  end

  private

  def send_signal(x, y)
    data = {x: x, y: y}.to_json
    RestClient.post FLUENTD_URL, data, {content_type: :json, accept: :json}
  end
end
