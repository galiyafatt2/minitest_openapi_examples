# frozen_string_literal: true

module MinitestOpenapiExamples
  # Writes or checks the examples for a recorded request and response.
  class ExampleWriter
    def initialize(document:)
      @document = document
      @operation_finder = OperationFinder.new(document: document)
    end

    def call(example, check: false)
      operation = operation_finder.call(example)
      raise Error, "OpenAPI operation not found for #{example.http_method.upcase} #{example.path}" unless operation

      write_response_example(operation, example, check: check)
      write_request_example(operation, example, check: check)
    end

    private

    attr_reader :document, :operation_finder

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def write_response_example(operation, example, check:)
      response_node = response_node_for(operation, example.response_code)
      content_type = example.response_content_type || MinitestOpenapiExamples.configuration.default_content_type

      content_node = response_node["content"] ||= {}
      media_type_node = content_node[content_type] ||= {}
      examples_node = media_type_node["examples"] ||= {}

      name = (example.name || default_response_example_name(example)).to_s
      payload = build_example_payload(summary: example.summary, value: example.response_body)
      sync_example(examples_node, name, payload, check: check) do
        endpoint = "#{example.http_method.upcase} #{example.path}"
        "response example #{name.inspect} for #{endpoint} (#{example.response_code}, #{content_type})"
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def write_request_example(operation, example, check:)
      return if example.request_body.nil?

      request_body_node = operation["requestBody"] ||= {}
      content_node = request_body_node["content"] ||= {}

      content_type = MinitestOpenapiExamples.configuration.default_content_type
      media_type_node = content_node[content_type] ||= {}
      examples_node = media_type_node["examples"] ||= {}

      name = (example.name || default_request_example_name(example)).to_s
      payload = build_example_payload(summary: example.summary, value: example.request_body)
      sync_example(examples_node, name, payload, check: check) do
        "request example #{name.inspect} for #{example.http_method.upcase} #{example.path} (#{content_type})"
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def response_node_for(operation, response_code)
      responses = operation["responses"] ||= {}
      responses[response_code] ||= { "description" => "Recorded response" }
    end

    def build_example_payload(summary:, value:)
      payload = { "value" => value }
      payload["summary"] = summary if summary
      payload
    end

    def sync_example(examples_node, name, payload, check:)
      if check
        return if examples_node[name] == payload

        raise Error, "OpenAPI drift in #{yield}. Update the example in #{document.path}."
      end

      examples_node[next_example_name(examples_node, name)] = payload
    end

    def next_example_name(examples_node, base_name)
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
