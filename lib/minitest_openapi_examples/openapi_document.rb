# frozen_string_literal: true

require "yaml"

module MinitestOpenapiExamples
  class OpenapiDocument
    attr_reader :path, :data

    def initialize(path: MinitestOpenapiExamples.configuration.spec_path)
      @path = path
      @data = load_data
    end

    def write!
      File.write(path, YAML.dump(data))
    end

    private

    def load_data
      return {} unless File.exist?(path)

      YAML.safe_load(File.read(path), aliases: true) || {}
    end
  end
end
