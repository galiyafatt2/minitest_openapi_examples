# frozen_string_literal: true

module MinitestOpenapiExamples
  class Configuration
    attr_accessor :spec_path, :scrubbers, :auto_write, :default_content_type

    def initialize
      @spec_path = "doc/openapi.yaml"
      @scrubbers = []
      @auto_write = false
      @default_content_type = "application/json"
    end
  end
end
