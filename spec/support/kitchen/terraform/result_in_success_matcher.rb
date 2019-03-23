# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
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

::RSpec::Matchers.define :result_in_success do
  supports_block_expectations

  chain(
    :with_message,
    :message
  )

  match notify_expectation_failures: true do |actual|
    actual_message = nil
    call_actual =
      proc do
        actual_message = actual.call
      end

    expect(call_actual).to_not raise_error
    values_match?(
      message,
      actual_message
    )
  end

  failure_message do |actual|
    "expected #{actual} to result in a success with the message #{message.inspect}"
  end
end
