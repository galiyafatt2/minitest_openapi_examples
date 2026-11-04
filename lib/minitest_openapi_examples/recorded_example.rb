# frozen_string_literal: true

module MinitestOpenapiExamples
  # Stores request and response data for one OpenAPI example.
  class RecordedExample
    attr_reader :path,
                :http_method,
                :operation_id,
                :name,
                :summary,
                :path_params,
                :query_params,
                :request_body,
                :response_status,
                :response_content_type,
                :response_body

    # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
    def initialize(
      path:,
      http_method:,
      response_status:, response_content_type:, response_body:, operation_id: nil,
      name: nil,
      summary: nil,
      path_params: {},
      query_params: {},
      request_body: nil
    )
      @path = path
      @http_method = http_method.to_s
      @operation_id = operation_id
      @name = name
      @summary = summary
      @path_params = path_params || {}
      @query_params = query_params || {}
      @request_body = request_body
      @response_status = response_status
      @response_content_type = response_content_type
      @response_body = response_body
    end
    # rubocop:enable Metrics/MethodLength, Metrics/ParameterLists

    def response_code
      response_status.to_s
    end
  end
end
