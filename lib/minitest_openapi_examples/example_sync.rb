# frozen_string_literal: true

module MinitestOpenapiExamples
  # Writes the recorded examples to the configured OpenAPI document.
  class ExampleSync
    def initialize(
      registry: MinitestOpenapiExamples.registry,
      document: OpenapiDocument.new
    )
      @registry = registry
      @document = document
      @writer = ExampleWriter.new(document: document)
    end

    def call
      registry.all.each do |example|
        writer.call(example)
      end

      document.write!
      registry.clear
    end

    private

    attr_reader :registry, :document, :writer
  end
end
