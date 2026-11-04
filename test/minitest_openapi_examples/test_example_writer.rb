# frozen_string_literal: true

require "test_helper"

module MinitestOpenapiExamples
  class ExampleWriterTest < Minitest::Test
    def test_writes_response_example
      document = MinitestOpenapiExamples::OpenapiDocument.new(path: fixture_path("openapi.yml"))
      writer = MinitestOpenapiExamples::ExampleWriter.new(document: document)

      example = MinitestOpenapiExamples::RecordedExample.new(
        path: "/api/v1/articles/{id}",
        http_method: :get,
        operation_id: "getArticle",
        name: "published_article",
        summary: "Published article response",
        response_status: 200,
        response_content_type: "application/json",
        response_body: {
          "data" => {
            "id" => "123",
            "title" => "Example"
          }
        }
      )

      writer.call(example)

      operation = document.data.dig("paths", "/api/v1/articles/{id}", "get")
      examples = operation.dig("responses", "200", "content", "application/json", "examples")

      assert_equal(
        {
          "published_article" => {
            "summary" => "Published article response",
            "value" => {
              "data" => {
                "id" => "123",
                "title" => "Example"
              }
            }
          }
        },
        examples
      )
    end

    def test_appends_suffix_when_response_example_name_already_exists
      document = MinitestOpenapiExamples::OpenapiDocument.new(path: fixture_path("openapi_with_examples.yml"))
      writer = MinitestOpenapiExamples::ExampleWriter.new(document: document)

      example = MinitestOpenapiExamples::RecordedExample.new(
        path: "/api/v1/articles/{id}",
        http_method: :get,
        name: "success",
        response_status: 200,
        response_content_type: "application/json",
        response_body: { "data" => { "id" => "456" } }
      )

      writer.call(example)

      examples = document.data.dig(
        "paths",
        "/api/v1/articles/{id}",
        "get",
        "responses",
        "200",
        "content",
        "application/json",
        "examples"
      )

      assert examples.key?("success")
      assert examples.key?("success_2")
    end

    def test_writes_request_body_example
      document = MinitestOpenapiExamples::OpenapiDocument.new(path: fixture_path("openapi_post.yml"))
      writer = MinitestOpenapiExamples::ExampleWriter.new(document: document)

      example = MinitestOpenapiExamples::RecordedExample.new(
        path: "/api/v1/articles",
        http_method: :post,
        name: "create_article",
        summary: "Create article request",
        request_body: {
          "title" => "Hello"
        },
        response_status: 201,
        response_content_type: "application/json",
        response_body: {
          "data" => {
            "id" => "123"
          }
        }
      )

      writer.call(example)

      request_examples = document.data.dig(
        "paths",
        "/api/v1/articles",
        "post",
        "requestBody",
        "content",
        "application/json",
        "examples"
      )

      assert_equal(
        {
          "create_article" => {
            "summary" => "Create article request",
            "value" => {
              "title" => "Hello"
            }
          }
        },
        request_examples
      )
    end

    private

    def fixture_path(file_name)
      File.join(__dir__, "..", "fixtures", file_name)
    end
  end
end
