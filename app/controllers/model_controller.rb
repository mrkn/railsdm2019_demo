class ModelController < ApplicationController
  def show
    image = visualize_model
    send_data image, type: 'image/png', disposition: 'inline'
  end

  private

  def visualize_model
    model = load_model
    xs = 0.upto(1000).map {|x| 2 * x / 100.0 - 10 }
    xs = Numpy.array(xs)
    ys = model.predict(xs.reshape([-1, 1]))
    Matplotlib::Pyplot.figure()
    Matplotlib::Pyplot.plot(xs, ys, '-')

    buf = PyCall.import_module('io').BytesIO.new
    Matplotlib::Pyplot.savefig(buf, format: 'png')
    buf.seek(0)
    image_data = buf.getvalue()

  end

  MODEL_FILENAME = Rails.root.join('tmp/model.pickle').to_s

  def load_model
    pickle = PyCall.import_module('pickle')
    fcntl = PyCall.import_module('fcntl')
    model = PyCall.with(PyCall.builtins.open(MODEL_FILENAME, "rb")) do |f|
      fcntl.flock(f, fcntl[:LOCK_SH])
      return pickle.load(f)
    ensure
      fcntl.flock(f, fcntl[:LOCK_UN])
    end
  end
end
