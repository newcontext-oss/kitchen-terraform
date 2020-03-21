# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ruby "~> 2.6"

source "https://rubygems.org/" do
  gemspec path: "."

  group :development_auxiliary do
    gem "gh", git: "https://github.com/travis-ci/gh", ref: "e0ca0d28d6533d5b9ee8ba18dff0a62346ff49d2"
    gem "guard-bundler", "~> 2.1"
    gem "guard-rspec", "~> 4.7"
    gem "guard-yard", "~> 2.2"
    gem "guard", "~> 2.14"
    gem "middleman-autoprefixer", "~> 2.7"
    gem "middleman-favicon-maker", "~> 4.1"
    gem "middleman-livereload", "~> 3.4"
    gem "middleman-syntax", "~> 3.0"
    gem "middleman", "~> 4.2"
    gem "mini_racer", "~> 0.2.0"
    gem "pry-coolline", "~> 0.2"
    gem "pry", "~> 0.10"
    gem "reek", "~> 5.5"
    gem "rufo", "~> 0.7"
    gem "travis", "~> 1.8"
    gem "yard", "~> 0.9"
  end
end
