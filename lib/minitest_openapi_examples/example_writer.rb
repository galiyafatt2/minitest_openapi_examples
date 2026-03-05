# frozen_string_literal: true

module MinitestOpenapiExamples
  class ExampleWriter
    def initialize(document:)
      @document = document
      @operation_finder = OperationFinder.new(document: document)
    end

    def call(example)
      operation = operation_finder.call(example)
      raise Error, "OpenAPI operation not found for #{example.http_method.upcase} #{example.path}" unless operation

      write_response_example(operation, example)
      write_request_example(operation, example)
    end

    private

    attr_reader :document, :operation_finder

    def write_response_example(operation, example)
      response_node = response_node_for(operation, example.response_code)
      content_type = example.response_content_type || MinitestOpenapiExamples.configuration.default_content_type

      content_node = response_node["content"] ||= {}
      media_type_node = content_node[content_type] ||= {}
      examples_node = media_type_node["examples"] ||= {}

      example_name = next_example_name(
        examples_node: examples_node,
        preferred_name: example.name,
        fallback_name: default_response_example_name(example)
      )

      examples_node[example_name] = build_example_payload(
        summary: example.summary,
        value: example.response_body
      )
    end

    def write_request_example(operation, example)
      return if example.request_body.nil?

      request_body_node = operation["requestBody"] ||= {}
      content_node = request_body_node["content"] ||= {}

      content_type = MinitestOpenapiExamples.configuration.default_content_type
      media_type_node = content_node[content_type] ||= {}
      examples_node = media_type_node["examples"] ||= {}

      example_name = next_example_name(
        examples_node: examples_node,
        preferred_name: example.name,
        fallback_name: default_request_example_name(example)
      )

      examples_node[example_name] = build_example_payload(
        summary: example.summary,
        value: example.request_body
      )
    end

    def response_node_for(operation, response_code)
      responses = operation["responses"] ||= {}
      responses[response_code] ||= { "description" => "Recorded response" }
    end

    def build_example_payload(summary:, value:)
      payload = { "value" => value }
      payload["summary"] = summary if summary
      payload
    end

    def next_example_name(examples_node:, preferred_name:, fallback_name:)
      base_name = (preferred_name || fallback_name).to_s
      return base_name unless examples_node.key?(base_name)

      suffix = 2

      loop do
        candidate_name = "#{base_name}_#{suffix}"
        return candidate_name unless examples_node.key?(candidate_name)

        suffix += 1
      end
    end

    def default_response_example_name(example)
      case example.response_code
      when "200" then "success"
      when "201" then "created"
      when "204" then "no_content"
      when "401" then "unauthorized"
      when "404" then "not_found"
      when "422" then "validation_error"
      else
        "response_#{example.response_code}"
      end
    end

    def default_request_example_name(example)
      case example.http_method
      when "post" then "create_request"
      when "patch" then "update_request"
      when "put" then "replace_request"
      else
        "request"
      end
    end
  end
end
