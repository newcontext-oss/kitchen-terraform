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

require "kitchen"
require "kitchen/driver/terraform"

::RSpec.shared_examples "Kitchen::Terraform::Configurable" do
  describe "@api_version" do
    subject do
      described_class
    end

    specify "should equal 2" do
      expect(subject.instance_variable_get(:@api_version)).to eq 2
    end
  end

  describe "@plugin_version" do
    subject do
      described_class
    end

    it "equals the gem version" do
      expect(subject.instance_variable_get(:@plugin_version)).to eq "4.3.0"
    end
  end

  describe "#expand_paths!" do
    subject do
      described_instance
    end

    context "when #validate_config! has not been called" do
      specify "should call #validate_config!" do
        is_expected.to receive :validate_config!
      end
    end

    context "when #validate_config! has been called" do
      before do
        subject.instance_variable_set :@validate_config_called, true
      end

      specify "should not call #validate_config!" do
        is_expected.not_to receive :validate_config!
      end
    end

    after do
      subject.send :expand_paths!
    end
  end
end
