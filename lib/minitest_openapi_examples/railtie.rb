# frozen_string_literal: true

require "rails/railtie"

module MinitestOpenapiExamples
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("tasks/minitest_openapi_examples_tasks.rake", __dir__)
    end
  end
end
