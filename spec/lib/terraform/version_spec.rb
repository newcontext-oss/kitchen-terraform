# frozen_string_literal: true
#
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

require 'support/yield_control_examples'
require 'terraform/version'

::RSpec.describe ::Terraform::Version do
  let(:described_instance) { described_class.new value: '1.2.3' }

  describe '.create' do
    subject { described_class.create value: value }

    context 'when the value is supported and not deprecated' do
      let(:value) { '0.8' }

      it 'returns a Version' do
        is_expected.to be_instance_of ::Terraform::Version
      end
    end

    context 'when the value is supported and deprecated' do
      let(:value) { '0.6' }

      it 'returns a DeprecatedVersion' do
        is_expected.to be_instance_of ::Terraform::DeprecatedVersion
      end
    end

    context 'when the value is not supported' do
      let(:value) { '9.9' }

      it 'returns an UnsupportedVersion' do
        is_expected.to be_instance_of ::Terraform::UnsupportedVersion
      end
    end
  end

  describe '#==' do
    subject { described_instance == version }

    context 'when the versions are equivalent at the major and minor level' do
      let(:version) { described_class.new value: '1.2.4' }

      it('returns true') { is_expected.to be true }
    end

    context 'when the versions are not equivalent at the major and minor ' \
              'level' do
      let(:version) { described_class.new value: '0.1.2' }

      it('returns false') { is_expected.to be false }
    end
  end

  describe '#if_deprecated' do
    it_behaves_like 'control is not yielded' do
      let(:described_method) { :if_deprecated }
    end
  end

  describe '#if_json_not_supported' do
    it_behaves_like 'control is not yielded' do
      let(:described_method) { :if_json_not_supported }
    end
  end

  describe '#if_not_supported' do
    it_behaves_like 'control is not yielded' do
      let(:described_method) { :if_not_supported }
    end
  end

  describe '#to_s' do
    subject { described_instance.to_s }

    it('returns "Terraform v<value>"') { is_expected.to eq 'Terraform v1.2.3' }
  end
end
