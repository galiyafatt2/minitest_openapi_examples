# frozen_string_literal: true

require "test_helper"

class MinitestOpenapiExamples::RedactorTest < Minitest::Test
  def teardown
    MinitestOpenapiExamples.reset_configuration!
  end

  def test_returns_value_unchanged_when_there_are_no_scrubbers
    payload = {
      "email" => "person@example.com",
      "token" => "Bearer secret-token"
    }

    redactor = MinitestOpenapiExamples::Redactor.new

    assert_equal payload, redactor.call(payload)
  end

  def test_redacts_strings_with_configured_scrubbers
    MinitestOpenapiExamples.configure do |configuration|
      configuration.scrubbers = [
        ->(value) { value.gsub(/Bearer\s+\S+/, "Bearer [FILTERED]") },
        ->(value) { value.gsub(/\b[\w.%+-]+@[\w.-]+\.\w+\b/, "[FILTERED_EMAIL]") }
      ]
    end

    payload = {
      "email" => "person@example.com",
      "token" => "Bearer secret-token",
      "nested" => {
        "message" => "Contact person@example.com with Bearer secret-token"
      }
    }

    redactor = MinitestOpenapiExamples::Redactor.new

    assert_equal(
      {
        "email" => "[FILTERED_EMAIL]",
        "token" => "Bearer [FILTERED]",
        "nested" => {
          "message" => "Contact [FILTERED_EMAIL] with Bearer [FILTERED]"
        }
      },
      redactor.call(payload)
    )
  end

  def test_redacts_nested_arrays
    MinitestOpenapiExamples.configure do |configuration|
      configuration.scrubbers = [
        ->(value) { value.gsub(/\b\d{4}-\d{2}-\d{2}\b/, "[FILTERED_DATE]") }
      ]
    end

    payload = {
      "items" => [
        "2026-03-05",
        {
          "created_at" => "2026-03-05"
        }
      ]
    }

    redactor = MinitestOpenapiExamples::Redactor.new

    assert_equal(
      {
        "items" => [
          "[FILTERED_DATE]",
          {
            "created_at" => "[FILTERED_DATE]"
          }
        ]
      },
      redactor.call(payload)
    )
  end

  def test_leaves_non_string_values_unchanged
    payload = {
      "count" => 3,
      "active" => true,
      "meta" => nil
    }

    redactor = MinitestOpenapiExamples::Redactor.new

    assert_equal payload, redactor.call(payload)
  end
end
