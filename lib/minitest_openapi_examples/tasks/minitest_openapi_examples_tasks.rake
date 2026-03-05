# frozen_string_literal: true

namespace :openapi do
  namespace :examples do
    desc "Write recorded Minitest OpenAPI examples into the configured spec file"
    task write: :environment do
      MinitestOpenapiExamples::ExampleSync.new.call
      puts "Updated OpenAPI examples in #{MinitestOpenapiExamples.configuration.spec_path}"
    end
  end
end
