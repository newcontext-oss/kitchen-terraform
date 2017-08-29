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

require "dry/monads"
require "kitchen/terraform/clear_directory"
require "support/dry/monads/either_matchers"
require "support/kitchen/terraform/clear_directory_context"

::RSpec.describe ::Kitchen::Terraform::ClearDirectory do
  describe ".call" do
    include ::Dry::Monads::Either::Mixin

    subject do
      described_class.call(
        directory: "directory",
        files: [
          "file_1",
          "file_2"
        ]
      )
    end

    include_context "Kitchen::Terraform::ClearDirectory"

    it do
      is_expected
        .to result_in_success.with_the_value "Cleared directory \"directory\" of files [\"file_1\", \"file_2\"]"
    end
  end
end
