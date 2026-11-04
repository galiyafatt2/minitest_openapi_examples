# frozen_string_literal: true

module MinitestOpenapiExamples
  # Holds settings for recording, writing, and checking examples.
  class Configuration
    attr_accessor :spec_path, :sanitizers, :auto_write, :check_examples, :default_content_type

    def initialize
      @spec_path = "doc/openapi.yaml"
      @sanitizers = []
      @auto_write = false
      @check_examples = false
      @default_content_type = "application/json"
    end
  end
end
