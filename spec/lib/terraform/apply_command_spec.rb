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

require 'terraform/apply_command'
require 'support/terraform/command_examples'

RSpec.describe Terraform::ApplyCommand do
  it_behaves_like Terraform::Command do
    let(:command_options) { "-input=false -state=#{state}" }

    let :described_instance do
      described_class.new logger: logger, state: state, plan: target
    end

    let(:name) { 'apply' }

    let(:state) { '<state_pathname>' }

    let(:target) { '<plan_pathname>' }
  end
end
