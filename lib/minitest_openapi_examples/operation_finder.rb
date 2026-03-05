# frozen_string_literal: true

module MinitestOpenapiExamples
  class OperationFinder
    def initialize(document:)
      @document = document
    end

    def call(example)
      paths = document.data.fetch("paths", {})

      if example.operation_id
        operation = find_by_operation_id(paths, example.operation_id)
        return operation if operation
      end

      find_by_path_and_method(paths, example.path, example.http_method)
    end

    private

    attr_reader :document

    def find_by_operation_id(paths, operation_id)
      paths.each_value do |path_item|
        path_item.each do |http_method, operation|
          next unless http_method.is_a?(String)
          next unless operation.is_a?(Hash)
          next unless operation["operationId"] == operation_id

          return operation
        end
      end

      nil
    end

    def find_by_path_and_method(paths, path, http_method)
      path_item = paths[path]
      return unless path_item.is_a?(Hash)

      path_item[http_method.to_s]
    end
  end
end
