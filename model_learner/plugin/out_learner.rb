require 'fluent/plugin/output'
require 'fluent/config/error'

require 'arrow'
require 'arrow-pycall'
require 'pycall'

module ModelLearner
  python_dir = File.expand_path('../python', __FILE__)
  PyCall.sys.path.append(python_dir)
  @pymodule = PyCall.import_module('model_learner')

  def self.update_model(model_filename, data)
    @pymodule.update_model(model_filename, data)
  end
end

module Fluent
  module Plugin
    class ModelLearnerOutput < Output
      Fluent::Plugin.register_output('learner', self)

      helpers :formatter

      DEFAULT_MODEL_FILENAME = File.expand_path("~/model.pickle")
      DEFAULT_LINE_FORMAT_TYPE = 'json'
      DEFAULT_FORMAT_TYPE = 'json'
      FIELD_NAMES = %w[x y]

      config_param :model_filename, :string, default: DEFAULT_MODEL_FILENAME

      config_section :format do
        config_set_default :@type, 'csv'
        config_set_default :fields, FIELD_NAMES
      end

      config_section :buffer do
        config_set_default :chunk_keys, ['tag']
        config_set_default :flush_at_shutdown, true
        config_set_default :chunk_limit_size, 10 * 1024
        config_set_default :chunk_limit_records, 50
      end

      attr_accessor :formatter

      def configure(conf)
        super
        @formatter = formatter_create
      end

      NEWLINE = "\n"

      def format(tag, time, record)
        if @formatter.formatter_type == :text_per_line
          @formatter.format(tag, time, record).chomp + NEWLINE
        else
          @formatter.format(tag, time, record)
        end
      end

      def write(chunk)
        data = "#{FIELD_NAMES.join(",")}\n#{chunk.read}"
        table = Arrow::CSVLoader.load(data, column_types: {x: :double, y: :double})
        score = learn(table)
        $log.info("score = #{score}")
      end

      def learn(table)
        ModelLearner.update_model(@model_filename, table.to_python)
      end
    end
  end
end
