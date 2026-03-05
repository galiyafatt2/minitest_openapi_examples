# frozen_string_literal: true

module MinitestOpenapiExamples
  class Registry
    def initialize
      @examples = []
    end

    def add(example)
      examples << example
    end

    def all
      examples.dup
    end

    def clear
      examples.clear
    end

    private

    attr_reader :examples
  end
end
