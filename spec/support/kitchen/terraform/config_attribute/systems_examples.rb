# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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

::RSpec.shared_examples "Kitchen::Terraform::ConfigAttribute::Systems" do
  subject do
    described_class.new config
  end

  let :config do
    {
      kitchen_root: "kitchen_root",
    }
  end

  describe "the basic schema" do
    context "when the config omits :systems" do
      specify "should associate :systems with an empty array" do
        allow(subject).to receive :load_needed_dependencies!

        subject.finalize_config! kitchen_instance

        expect(subject[:systems]).to match []
      end
    end
  end

  describe "#doctor_config_systems" do
    context "when the configured systems are empty" do
      before do
        config.store :systems, []
      end

      specify "should return true" do
        expect(subject.doctor_config_systems).to be_truthy
      end
    end

    context "when the configured systems are not empty" do
      before do
        config.store :systems, [::Kitchen::Terraform::System.new(configuration_attributes: {}, logger: logger)]
      end

      specify "should return false" do
        expect(subject.doctor_config_systems).to be_falsey
      end
    end
  end
end
