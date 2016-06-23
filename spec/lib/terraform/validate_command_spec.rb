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

require 'terraform/validate_command'
require 'support/terraform/command_examples'

RSpec.describe Terraform::ValidateCommand do
  it_behaves_like Terraform::Command do
    let(:command_options) { '' }

    let(:described_instance) { described_class.new dir: target }

    let(:name) { 'validate' }

    let(:target) { '<directory>' }
  end
end
