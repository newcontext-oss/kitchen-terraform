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
require "kitchen/terraform/version"
require "support/terraform/configurable_context"
require "terraform/configurable"

::RSpec.shared_examples ::Terraform::Configurable do
  let :attr do instance_double ::Object end

  let :formatted_config do "#{described_class}#{instance.to_str}#config[:#{attr}]" end

  describe "@api_version" do
    subject :api_version do described_class.instance_variable_get :@api_version end

    it "equals 2" do is_expected.to eq 2 end
  end

  describe "@plugin_version" do
    subject :plugin_version do described_class.instance_variable_get :@plugin_version end

    it "equals the gem version" do
      is_expected.to eq ::Kitchen::Terraform::VERSION
    end
  end

  describe "#debug_logger" do
    subject do described_instance.debug_logger end

    it "is a debug logger" do is_expected.to be_instance_of ::Terraform::DebugLogger end
  end

  describe "#driver" do
    subject do described_instance.driver end

    it "returns the driver of the instance" do is_expected.to be instance.driver end
  end

  describe "#instance_pathname" do
    let :filename do "filename" end

    subject do described_instance.instance_pathname filename: filename end

    it "returns a pathname under the hidden instance directory" do
      is_expected.to eq "/kitchen/root/.kitchen/kitchen-terraform/suite-platform/filename"
    end
  end

  describe "#provisioner" do
    subject do described_instance.provisioner end

    it "returns the provisioner of the instance" do is_expected.to be instance.provisioner end
  end

  describe "#transport" do
    subject do described_instance.transport end

    it "returns the transport of the instance" do is_expected.to be instance.transport end
  end
end
