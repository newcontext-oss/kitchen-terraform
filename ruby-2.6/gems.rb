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
  gemspec path: ".."

  group :development do
    gem "gh", git: "https://github.com/travis-ci/gh", ref: "e0ca0d28d6533d5b9ee8ba18dff0a62346ff49d2"
  end

  group :runtime do
    gem "inspec", ">= 4.18.0"
  end

  group :test do
    gem "rake", "~> 12.3"
  end
end
