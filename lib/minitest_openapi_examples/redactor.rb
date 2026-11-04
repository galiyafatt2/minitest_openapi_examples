# frozen_string_literal: true

module MinitestOpenapiExamples
  # Applies the configured sanitizers to recorded example data.
  class Redactor
    def initialize(sanitizers: MinitestOpenapiExamples.configuration.sanitizers)
      @sanitizers = Array(sanitizers)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def call(value)
      case value
      when RecordedExample
        RecordedExample.new(
          path: value.path,
          http_method: value.http_method,
          operation_id: value.operation_id,
          name: value.name,
          summary: sanitize_string_or_value(value.summary),
          path_params: call(value.path_params),
          query_params: call(value.query_params),
          request_body: call(value.request_body),
          response_status: value.response_status,
          response_content_type: value.response_content_type,
          response_body: call(value.response_body)
        )
      when Hash
        value.to_h do |key, nested_value|
          [key, call(nested_value)]
        end
      when Array
        value.map { |nested_value| call(nested_value) }
      when String
        sanitize_string(value)
      else
        value
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    attr_reader :sanitizers

    def sanitize_string_or_value(value)
      return value unless value.is_a?(String)

      sanitize_string(value)
    end

    def sanitize_string(value)
      sanitizers.reduce(value) do |current_value, sanitizer|
        sanitizer.call(current_value)
      end
    end
  end
end
