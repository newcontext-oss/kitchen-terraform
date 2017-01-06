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

require 'terraform/version'

::RSpec.describe ::Terraform::Version do
  let(:described_instance) { described_class.new value: '1.2.3' }

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

  describe '#to_s' do
    subject { described_instance.to_s }

    it('returns "v<value>"') { is_expected.to eq 'v1.2.3' }
  end
end
