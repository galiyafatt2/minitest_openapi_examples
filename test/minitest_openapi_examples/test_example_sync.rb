# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class MinitestOpenapiExamples::ExampleSyncTest < Minitest::Test
  def teardown
    MinitestOpenapiExamples.reset_registry!
  end

  def test_writes_recorded_examples_to_file
    Dir.mktmpdir do |dir|
      spec_path = File.join(dir, "openapi.yml")
      File.write(spec_path, File.read(fixture_path("openapi.yml")))

      MinitestOpenapiExamples.registry.add(
        MinitestOpenapiExamples::RecordedExample.new(
          path: "/api/v1/articles/{id}",
          http_method: :get,
          operation_id: "getArticle",
          name: "published_article",
          summary: "Published article response",
          response_status: 200,
          response_content_type: "application/json",
          response_body: {
            "data" => {
              "id" => "123"
            }
          }
        )
      )

      document = MinitestOpenapiExamples::OpenapiDocument.new(path: spec_path)

      MinitestOpenapiExamples::ExampleSync.new(document: document).call

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
            "summary" => "Published article response",
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
