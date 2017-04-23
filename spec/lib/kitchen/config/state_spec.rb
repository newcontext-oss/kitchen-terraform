# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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

require "kitchen/config/state"
require "terraform/configurable"

::RSpec.describe ::Kitchen::Config::State do
  describe ".call" do
    let :plugin do plugin_class.new end

    let :plugin_class do
      ::Class.new do
        include ::Kitchen::Configurable

        include ::Terraform::Configurable
      end
    end

    describe "value validation" do
      before do
        allow(plugin_class).to receive(:required_config).with(:state).and_yield :state, value, plugin
      end

      shared_examples "the configuration is invalid" do
        subject do proc do described_class.call plugin_class: plugin_class end end

        it "raises a user error" do is_expected.to raise_error ::Kitchen::UserError, error_message end
      end

      shared_examples "the configuration is valid" do
        subject do proc do described_class.call plugin_class: plugin_class end end

        it "permits the configuration" do is_expected.to_not raise_error end
      end

      context "when the configuration associates :state with a nonstring" do
        let :value do 123 end

        it_behaves_like "the configuration is invalid" do let :error_message do /state.*must be a string/ end end
      end

      context "when the configuration associates :cli with a string" do
        context "when the string is empty" do
          let :value do "" end

          it_behaves_like "the configuration is invalid" do let :error_message do /state.*must be filled/ end end
        end

        context "when the string is nonempty" do
          let :value do "abc" end

          it_behaves_like "the configuration is valid"
        end
      end
    end

    describe "defining the default value" do
      before do
        allow(plugin_class).to receive(:required_config).with :state

        allow(plugin_class).to receive(:default_config).with(:state).and_yield plugin
      end

      after do described_class.call plugin_class: plugin_class end

      subject do plugin end

      it "defines the default value as terraform.tfstate under the Test Kitchen suite directory" do
        is_expected.to receive(:instance_pathname).with filename: "terraform.tfstate"
      end
    end
  end
end
