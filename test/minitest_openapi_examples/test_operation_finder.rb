# frozen_string_literal: true

require "test_helper"

module MinitestOpenapiExamples
  class OperationFinderTest < Minitest::Test
    def test_finds_operation_by_operation_id
      document = MinitestOpenapiExamples::OpenapiDocument.new(path: fixture_path("openapi.yml"))
      finder = MinitestOpenapiExamples::OperationFinder.new(document: document)

      example = MinitestOpenapiExamples::RecordedExample.new(
        path: "/wrong/path",
        http_method: :get,
        operation_id: "getArticle",
        response_status: 200,
        response_content_type: "application/json",
        response_body: {}
      )

      operation = finder.call(example)

      assert_equal "getArticle", operation["operationId"]
    end

    def test_finds_operation_by_path_and_method
      document = MinitestOpenapiExamples::OpenapiDocument.new(path: fixture_path("openapi.yml"))
      finder = MinitestOpenapiExamples::OperationFinder.new(document: document)

      example = MinitestOpenapiExamples::RecordedExample.new(
        path: "/api/v1/articles/{id}",
        http_method: :get,
        response_status: 200,
        response_content_type: "application/json",
        response_body: {}
      )

      operation = finder.call(example)

      assert_equal "getArticle", operation["operationId"]
    end

    private

    def fixture_path(file_name)
      File.join(__dir__, "..", "fixtures", file_name)
    end
  end
end
