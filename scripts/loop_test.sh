#!/bin/bash

bundle config path --local vendor/bundle
bundle config set build.nokogiri --use-system-libraries
bundle config set force_ruby_platform true
bundle install
env RAILS_ENV=test bundle exec rails assets:precompile
env RAILS_ENV=test bundle exec rake test
