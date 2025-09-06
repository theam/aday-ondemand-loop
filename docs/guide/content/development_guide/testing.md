# Testing

## Overview
The Rails test suite lives under `application/test` and is organized by component:

- `models/` – Active Record models
- `controllers/` – controller actions
- `services/` – application services and helpers
- `connectors/` – repository integrations
- `integration/` and `system/` – higher level flows
- `views/`, `helpers/`, `lib/`, and `utils/` for other layers
- `fixtures/` provides sample data for tests

Tests use Rails' built‑in [Minitest](https://guides.rubyonrails.org/testing.html) framework. Each test file is named with the
`*_test.rb` suffix and defines classes such as `ActiveSupport::TestCase` or `ActionDispatch::IntegrationTest`.
Fixtures in `application/test/fixtures` supply reusable records for fast and deterministic tests.

## Running tests
Tests are executed inside a Docker container using Make targets defined in the project's `Makefile`.

- `make test_bash` – start an interactive shell inside the test container.
- `make test_exec` – run one or more commands non‑interactively by piping them to the target.

### Run all tests
```bash
echo 'bundle exec rake test' | make test_exec
```

### Run a single test file
```bash
echo 'bundle exec rake test TEST=test/models/application_disk_record_test.rb' | make test_exec
```

### Run a specific test method
```bash
echo 'bundle exec rake test TEST=test/models/application_disk_record_test.rb TESTOPTS="--name=test_saved"' | make test_exec
```

### Run tests in a directory
```bash
echo 'bundle exec rake test TEST="test/services/**/*_test.rb"' | make test_exec
```

### Useful options
```bash
echo 'bundle exec rake test TESTOPTS="--verbose --stop-on-failure --seed=1234"' | make test_exec
```

For multiple commands or custom setup, chain commands with `echo -e` or launch `make test_bash` and run tests manually inside the container.
