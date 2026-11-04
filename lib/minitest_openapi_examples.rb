# frozen_string_literal: true

require_relative "minitest_openapi_examples/version"
require_relative "minitest_openapi_examples/configuration"
require_relative "minitest_openapi_examples/recorded_example"
require_relative "minitest_openapi_examples/registry"
require_relative "minitest_openapi_examples/redactor"
require_relative "minitest_openapi_examples/test_helper"
require_relative "minitest_openapi_examples/openapi_document"
require_relative "minitest_openapi_examples/operation_finder"
require_relative "minitest_openapi_examples/example_writer"
require_relative "minitest_openapi_examples/example_sync"

require_relative "minitest_openapi_examples/railtie" if defined?(Rails::Railtie)

# Records Rails integration test examples for OpenAPI documentation.
module MinitestOpenapiExamples
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def registry
      @registry ||= Registry.new
    end

    def reset_registry!
      @registry = Registry.new
    end
  end
end
