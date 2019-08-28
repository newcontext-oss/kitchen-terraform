# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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

::RSpec.shared_examples "Kitchen::Terraform::ConfigAttribute::Color" do
  let :attribute do
    :color
  end

  context "when the config omits :color" do
    context "when the Test Kitchen process is not associated with a terminal device" do
      subject do
        described_class.new
      end

      before do
        allow(::Kitchen).to receive(:tty?).with(no_args).and_return false
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end

      specify "should associate :color with false" do
        expect(subject[attribute]).to be false
      end
    end

    context "when the Test Kitchen process is associated with a terminal device" do
      subject do
        described_class.new
      end

      before do
        allow(::Kitchen).to receive(:tty?).with(no_args).and_return true
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end

      specify "should associate :color with true" do
        expect(subject[attribute]).to be true
      end
    end
  end

  context "when the config associates :color with a nonboolean" do
    subject do
      described_class.new attribute => "abc"
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error ::Kitchen::UserError, /color.*must be boolean/
    end
  end

  context "when the config associates :color with a boolean" do
    subject do
      described_class.new attribute => false
    end

    specify "should not raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.not_to raise_error
    end
  end
end
