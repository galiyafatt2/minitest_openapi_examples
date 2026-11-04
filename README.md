# MinitestOpenapiExamples

MinitestOpenapiExamples records real request and response examples from Rails Minitest request tests, sanitizes unstable or sensitive values, and writes them into an existing OpenAPI spec.

It is designed for teams that already maintain an OpenAPI document and want to keep examples in sync with real test coverage, without switching to RSpec or adopting a large DSL.

## Features

- Record response examples from Rails Minitest request tests
- Record request body examples for write actions
- Sanitize tokens, emails, UUIDs, timestamps, and other unstable values
- Write examples into an existing OpenAPI YAML file
- Auto-write examples during test runs, if enabled
- Run sync manually through a Rake task

## Installation

Add the gem to your application's Gemfile:

```ruby
gem "minitest_openapi_examples", "~> 0.2.0"
```

Then run:

```bash
bundle install
```

## Usage

Configure the gem in your Rails application:

```ruby
MinitestOpenapiExamples.configure do |config|
  config.spec_path = Rails.root.join("doc/openapi.yml").to_s
  config.auto_write = false
  config.default_content_type = "application/json"

  config.sanitizers = [
    ->(value) { value.gsub(/Bearer\s+\S+/, "Bearer [FILTERED]") },
    ->(value) { value.gsub(/\b[\w.%+-]+@[\w.-]+\.\w+\b/, "[FILTERED_EMAIL]") }
  ]
end
```

Include the test helper in your request test base class:

```ruby
class ActionDispatch::IntegrationTest
  include MinitestOpenapiExamples::TestHelper
end
```

Annotate a test class with OpenAPI endpoint metadata:

```ruby
class Api::V1::ArticlesTest < ActionDispatch::IntegrationTest
  openapi_examples path: "/api/v1/articles/{id}", method: :get, operation_id: "getArticle"

  test "shows an article" do
    article = articles(:published)

    get api_v1_article_path(article), headers: auth_headers

    assert_response :success

    record_openapi_example!(
      name: "published_article",
      summary: "Published article response",
      path_params: { id: article.id }
    )
  end
end
```

For create or update actions, you can also record a request body example:

```ruby
class Api::V1::ArticlesTest < ActionDispatch::IntegrationTest
  openapi_examples path: "/api/v1/articles", method: :post, operation_id: "createArticle"

  test "creates an article" do
    payload = { title: "Hello" }

    post api_v1_articles_path, params: payload, as: :json

    assert_response :created

    record_openapi_example!(
      name: "create_article",
      summary: "Create article request",
      request_body: payload
    )
  end
end
```

Recorded examples are written into the matching OpenAPI operation by:

1. `operationId`, if provided
2. otherwise `path + method`

Response examples are written under:

* `responses.*.content.*.examples`

Request examples are written under:

* `requestBody.content.*.examples`

## Manual Sync

If `auto_write` is disabled, you can write recorded examples manually:

```bash
bin/rails openapi:examples:write
```

## Check examples in CI

Enable check mode in your Rails test setup, alongside your existing gem configuration.

```ruby
MinitestOpenapiExamples.configure do |config|
  config.check_examples = ENV["OPENAPI_EXAMPLES_CHECK"] == "1"
end
```

Run the request tests that call `record_openapi_example!`.

```sh
OPENAPI_EXAMPLES_CHECK=1 bin/rails test test/integration
```

Each recording compares its sanitized response and any supplied request body with the corresponding examples in the configured spec. A missing or changed example fails the test and identifies the example and endpoint. Update the checked-in example at that key and rerun the test. Check mode takes precedence over `auto_write` and leaves the spec file untouched.

Use distinct, stable example names within each operation, status, and media type. The check compares the exact key, including any suffix you explicitly pass in `name:`. Examples that your test run doesn't record are outside the check.

## Configuration

The gem supports these configuration options:

* `spec_path` - path to the OpenAPI YAML file
* `sanitizers` - array of lambdas used to sanitize string values
* `auto_write` - write examples immediately after recording
* `check_examples` - compare recorded examples against the spec without writing (default: false)
* `default_content_type` - fallback content type for request and response examples

## Development

After checking out the repo, run:

```bash
bin/setup
bundle exec rake test
```

You can also use:

```bash
bin/console
```

to experiment with the gem locally.

To install this gem onto your local machine, run:

```bash
bundle exec rake install
```

## Roadmap

Planned improvements include:

* Better YAML output stability
* Optional request header example support
* Rails auto-inclusion for `ActionDispatch::IntegrationTest`
* Improved duplicate example handling across repeated runs

## Contributing

Bug reports and pull requests are welcome on GitHub:

[https://github.com/galiyafatt2/minitest_openapi_examples](https://github.com/galiyafatt2/minitest_openapi_examples)

Please make sure changes include tests where appropriate.

## License

This gem is available as open source under the terms of the MIT License.

## Code of Conduct

Everyone interacting in the MinitestOpenapiExamples project is expected to follow the code of conduct:

[https://github.com/galiyafatt2/minitest_openapi_examples/blob/main/CODE_OF_CONDUCT.md](https://github.com/galiyafatt2/minitest_openapi_examples/blob/main/CODE_OF_CONDUCT.md)

