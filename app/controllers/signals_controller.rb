class SignalsController < ApplicationController
  FLUENTD_URL = "http://localhost:24224/signal"

  def create
    data = params.dig(:signal)
    send_signal(data[:x], data[:y])
    render json: JSON.dump(data)
  end

  private

  def send_signal(x, y)
    RestClient.post FLUENTD_URL, {x: x, y: y}
  end
end
