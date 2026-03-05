# frozen_string_literal: true

module MinitestOpenapiExamples
  module TestHelper
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def openapi_examples(path:, method:, operation_id: nil)
        @openapi_examples_metadata = {
          path: path,
          http_method: method.to_s,
          operation_id: operation_id
        }
      end

      def openapi_examples_metadata
        if instance_variable_defined?(:@openapi_examples_metadata)
          @openapi_examples_metadata
        elsif superclass.respond_to?(:openapi_examples_metadata)
          superclass.openapi_examples_metadata
        end
      end
    end

    def record_openapi_example!(
      name: nil,
      summary: nil,
      path_params: {},
      query_params: {},
      request_body: nil
    )
      metadata = self.class.openapi_examples_metadata
      raise MinitestOpenapiExamples::Error, "Missing openapi_examples metadata" unless metadata

      example = RecordedExample.new(
        path: metadata.fetch(:path),
        http_method: metadata.fetch(:http_method),
        operation_id: metadata[:operation_id],
        name: name,
        summary: summary,
        path_params: path_params,
        query_params: query_params,
        request_body: request_body,
        response_status: response.status,
        response_content_type: response.media_type || MinitestOpenapiExamples.configuration.default_content_type,
        response_body: parsed_response_body
      )

      sanitized_example = MinitestOpenapiExamples::Redactor.new.call(example)

      MinitestOpenapiExamples.registry.add(sanitized_example)
      MinitestOpenapiExamples::ExampleSync.new.call if MinitestOpenapiExamples.configuration.auto_write

      sanitized_example
    end

    private

    def parsed_response_body
      return response.parsed_body if response.respond_to?(:parsed_body)

      response.body
    end
  end
end
