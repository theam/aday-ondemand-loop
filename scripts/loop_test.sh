#!/bin/bash

bundle config path --local vendor/bundle
bundle config set build.nokogiri --use-system-libraries
bundle config set force_ruby_platform true
bundle install

if [ "$1" == "coverage" ]; then
  env RAILS_ENV=test bundle exec rake test:coverage
else
  env RAILS_ENV=test bundle exec rake test
fi
