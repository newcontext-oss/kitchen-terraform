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

require "kitchen/instance"

::RSpec.shared_context "Kitchen::Terraform::ConfigAttribute" do |attribute:|
  let :kitchen_instance do
    instance_double ::Kitchen::Instance
  end

  shared_examples "the value is invalid" do |error_message:, value:|
    subject do
      described_class.new kitchen_root: "kitchen_root", attribute => value
    end

    before do
      allow(subject).to receive :load_needed_dependencies!
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        subject.finalize_config! kitchen_instance
      end.to raise_error ::Kitchen::UserError, error_message
    end
  end

  shared_examples "the value is valid" do |value:|
    subject do
      described_class.new kitchen_root: "kitchen_root", attribute => value
    end

    before do
      allow(subject).to receive :load_needed_dependencies!
    end

    specify "should not raise an error" do
      expect do
        subject.finalize_config! kitchen_instance
      end.to_not raise_error
    end
  end

  shared_examples "a default value is used" do |default_value:|
    subject do
      described_class.new kitchen_root: "kitchen_root"
    end

    before do
      allow(subject).to receive :load_needed_dependencies!
      subject.finalize_config! kitchen_instance
    end

    specify "should associate :#{attribute} with #{default_value}" do
      expect(subject[attribute]).to match default_value
    end
  end
end
