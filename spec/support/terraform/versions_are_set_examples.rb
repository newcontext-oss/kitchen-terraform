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

require 'terraform/version'

RSpec.shared_examples 'versions are set' do
  describe '@api_version' do
    subject :api_version do
      described_class.instance_variable_get :@api_version
    end

    it('equals 2') { is_expected.to eq 2 }
  end

  describe '@plugin_version' do
    subject :plugin_version do
      described_class.instance_variable_get :@plugin_version
    end

    it('equals the gem version') { is_expected.to be Terraform::VERSION }
  end
end
