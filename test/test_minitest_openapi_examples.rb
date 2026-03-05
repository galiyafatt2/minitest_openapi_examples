# frozen_string_literal: true

require "test_helper"

class MinitestOpenapiExamplesTest < Minitest::Test
  def teardown
    MinitestOpenapiExamples.reset_configuration!
  end

  def test_has_a_version_number
    refute_nil MinitestOpenapiExamples::VERSION
  end

  def test_exposes_configuration
    configuration = MinitestOpenapiExamples.configuration

    assert_instance_of MinitestOpenapiExamples::Configuration, configuration
    assert_equal "doc/openapi.yaml", configuration.spec_path
    assert_equal [], configuration.scrubbers
    assert_equal false, configuration.auto_write
    assert_equal "application/json", configuration.default_content_type
  end

  def test_yields_configuration
    MinitestOpenapiExamples.configure do |configuration|
      configuration.spec_path = "doc/mobile_api.yaml"
      configuration.auto_write = true
    end

    assert_equal "doc/mobile_api.yaml", MinitestOpenapiExamples.configuration.spec_path
    assert_equal true, MinitestOpenapiExamples.configuration.auto_write
  end
end
