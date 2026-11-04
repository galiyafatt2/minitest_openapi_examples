# frozen_string_literal: true

module MinitestOpenapiExamples
  # Records examples from Rails integration tests.
  module TestHelper
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Declares the OpenAPI operation exercised by a test class.
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

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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

      configuration = MinitestOpenapiExamples.configuration
      if configuration.check_examples
        document = OpenapiDocument.new
        ExampleWriter.new(document: document).call(sanitized_example, check: true)
      else
        MinitestOpenapiExamples.registry.add(sanitized_example)
        ExampleSync.new.call if configuration.auto_write
      end

      sanitized_example
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    def parsed_response_body
      return response.parsed_body if response.respond_to?(:parsed_body)

      response.body
    end
  end
end
