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

require "fileutils"

::RSpec.shared_context "Kitchen::Terraform::CreateDirectories.call" do
  let :file_utils do
    class_double(::FileUtils).as_stubbed_const
  end
end

::RSpec.shared_context "Kitchen::Terraform::CreateDirectories.call failure" do
  include_context "Kitchen::Terraform::CreateDirectories.call"

  before do
    allow(file_utils)
      .to(
        receive(:makedirs)
          .and_raise(
            ::SystemCallError,
            "mocked error"
          )
      )
  end
end

::RSpec.shared_context "Kitchen::Terraform::CreateDirectories.call success" do
  include_context "Kitchen::Terraform::CreateDirectories.call"

  before do
    allow(file_utils).to receive :makedirs do |list|
      list
    end
  end
end
