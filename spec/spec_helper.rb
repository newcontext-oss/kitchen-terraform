# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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

require "support/coverage"

::RSpec.configure do |configuration|
  configuration.color = true

  configuration.disable_monkey_patching!

  configuration.expect_with :rspec do |expect_configuration|
    expect_configuration.include_chain_clauses_in_custom_matcher_descriptions = true
    expect_configuration.max_formatted_output_length = nil
  end

  configuration.fail_fast = false

  configuration.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true

    mocks.verify_partial_doubles = true
  end

  configuration.profile_examples = 10
end

module RSpec
  module Mocks
    # This is a patch to work around an issue that is fixed by rspec-mocks 3.12.2.
    # SEE: https://github.com/rspec/rspec-mocks/pull/1514
    class VerifyingMethodDouble
      ruby2_keywords :proxy_method_invoked if respond_to?(:ruby2_keywords, true)
    end
  end
end
