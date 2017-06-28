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

[
  :failure,
  :success
].each do |status|
  ::RSpec::Matchers.define "result_in_#{status}" do
    match do |result|
      result.send "#{status}?" and value.nil? or values_match? value, result.value
    end

    chain :with_the_value, :value

    failure_message do |result|
      ::String.new("expected result\n  #{result}\nto be a #{status}").tap do |message|
        value.nil? or message.concat " with the value\n  #{value}"
      end
    end
  end
end
