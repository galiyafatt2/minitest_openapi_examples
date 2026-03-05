# frozen_string_literal: true

require_relative "minitest_openapi_examples/version"
require_relative "minitest_openapi_examples/configuration"
require_relative "minitest_openapi_examples/redactor"

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
  end
end
