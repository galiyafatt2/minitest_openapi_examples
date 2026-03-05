# frozen_string_literal: true

module MinitestOpenapiExamples
  class Redactor
    def initialize(scrubbers: MinitestOpenapiExamples.configuration.scrubbers)
      @scrubbers = Array(scrubbers)
    end

    def call(value)
      case value
      when Hash
        value.to_h do |key, nested_value|
          [key, call(nested_value)]
        end
      when Array
        value.map { |nested_value| call(nested_value) }
      when String
        scrub_string(value)
      else
        value
      end
    end

    private

    attr_reader :scrubbers

    def scrub_string(value)
      scrubbers.reduce(value) do |current_value, scrubber|
        scrubber.call(current_value)
      end
    end
  end
end
