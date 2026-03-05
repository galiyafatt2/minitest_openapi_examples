# frozen_string_literal: true

require "test_helper"

class MinitestOpenapiExamples::TestHelperTest < Minitest::Test
  FakeResponse = Struct.new(:status, :media_type, :body, keyword_init: true) do
    def parsed_body
      body
    end
  end

  class FakeIntegrationTest
    include MinitestOpenapiExamples::TestHelper

    attr_reader :response

    openapi_examples path: "/api/v1/articles/{id}", method: :get, operation_id: "getArticle"

    def initialize(response:)
      @response = response
    end
  end

  def teardown
    MinitestOpenapiExamples.reset_configuration!
    MinitestOpenapiExamples.reset_registry!
  end

  def test_records_a_normalized_example
    response = FakeResponse.new(
      status: 200,
      media_type: "application/json",
      body: {
        "data" => {
          "id" => "123",
          "title" => "Example"
        }
      }
    )

    test_case = FakeIntegrationTest.new(response: response)

    test_case.record_openapi_example!(
      name: "published_article",
      summary: "Published article response",
      path_params: { id: 123 }
    )

    example = MinitestOpenapiExamples.registry.all.first

    assert_instance_of MinitestOpenapiExamples::RecordedExample, example
    assert_equal "/api/v1/articles/{id}", example.path
    assert_equal "get", example.http_method
    assert_equal "getArticle", example.operation_id
    assert_equal "published_article", example.name
    assert_equal "Published article response", example.summary
    assert_equal({ id: 123 }, example.path_params)
    assert_equal 200, example.response_status
    assert_equal "200", example.response_code
    assert_equal "application/json", example.response_content_type
    assert_equal(
      {
        "data" => {
          "id" => "123",
          "title" => "Example"
        }
      },
      example.response_body
    )
  end

  def test_raises_when_metadata_is_missing
    klass = Class.new do
      include MinitestOpenapiExamples::TestHelper

      attr_reader :response

      def initialize(response:)
        @response = response
      end
    end

    response = FakeResponse.new(status: 200, media_type: "application/json", body: {})
    test_case = klass.new(response: response)

    error = assert_raises(MinitestOpenapiExamples::Error) do
      test_case.record_openapi_example!
    end

    assert_equal "Missing openapi_examples metadata", error.message
  end

  def test_applies_sanitizers_to_recorded_examples
    MinitestOpenapiExamples.configure do |configuration|
      configuration.sanitizers = [
        ->(value) { value.gsub(/\b[\w.%+-]+@[\w.-]+\.\w+\b/, "[FILTERED_EMAIL]") }
      ]
    end

    response = FakeResponse.new(
      status: 200,
      media_type: "application/json",
      body: {
        "email" => "person@example.com"
      }
    )

    test_case = FakeIntegrationTest.new(response: response)

    test_case.record_openapi_example!(summary: "Contact person@example.com")

    example = MinitestOpenapiExamples.registry.all.first

    assert_equal "Contact [FILTERED_EMAIL]", example.summary
    assert_equal({ "email" => "[FILTERED_EMAIL]" }, example.response_body)
  end

  def test_auto_writes_when_enabled
    Dir.mktmpdir do |directory|
      spec_path = File.join(directory, "openapi.yml")
      File.write(spec_path, File.read(fixture_path("openapi.yml")))

      MinitestOpenapiExamples.configure do |configuration|
        configuration.auto_write = true
        configuration.spec_path = spec_path
      end

      response = FakeResponse.new(
        status: 200,
        media_type: "application/json",
        body: { "data" => { "id" => "123" } }
      )

      test_case = FakeIntegrationTest.new(response: response)
      test_case.record_openapi_example!(name: "published_article")

      updated_document = YAML.safe_load(File.read(spec_path), aliases: true)
      examples = updated_document.dig(
        "paths",
        "/api/v1/articles/{id}",
        "get",
        "responses",
        "200",
        "content",
        "application/json",
        "examples"
      )

      assert_equal(
        {
          "published_article" => {
            "value" => {
              "data" => {
                "id" => "123"
              }
            }
          }
        },
        examples
      )
    end
  end

  private

  def fixture_path(file_name)
    File.join(__dir__, "..", "fixtures", file_name)
  end
end
