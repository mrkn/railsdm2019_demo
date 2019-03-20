require 'fluent/plugin/output'
require 'fluent/config/error'

require 'arrow'

module Fluent
  module Plugin
    class ModelLearnerOutput < Output
      Fluent::Plugin.register_output('learner', self)

      helpers :formatter

      DEFAULT_LINE_FORMAT_TYPE = 'json'
      DEFAULT_FORMAT_TYPE = 'json'
      FIELD_NAMES = %w[x y]

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

      def try_write(chunk)
        data = "#{FIELD_NAMES.join(",")}\n#{chunk.read}"
        table = Arrow::CSVLoader.load(data, column_types: {x: :double, y: :double})
        $log.puts(table.inspect)
      end
    end
  end
end
