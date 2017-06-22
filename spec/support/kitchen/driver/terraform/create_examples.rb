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

require "kitchen/driver/terraform/create"
require "support/kitchen/terraform/create_directories_context"

::RSpec.shared_examples "::Kitchen::Driver::Terraform::Create" do
  subject do
    lambda do
      described_method.call instance_double ::Object
    end
  end

  context "when the operation to create directories is a failure" do
    include_context "::Kitchen::Terraform::CreateDirectories :failure"

    it "raises an action failed error" do
      is_expected.to raise_error ::Kitchen::ActionFailed, kind_of(::String)
    end
  end

  context "when the operation to create directories is a success" do
    include_context "::Kitchen::Terraform::CreateDirectories :success"

    it "does not raise an error" do
      is_expected.to_not raise_error
    end
  end
end
