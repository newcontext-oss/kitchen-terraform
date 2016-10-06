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

require 'terraform/prepare_output_file'

::RSpec.describe ::Terraform::PrepareOutputFile do
  let(:described_instance) { described_class.new file: file }

  let(:file) { instance_double ::Pathname }

  let(:parent_directory) { instance_double ::Pathname }

  before do
    allow(file)
      .to receive(:parent).with(no_args).and_return parent_directory
  end

  describe '#execute' do
    before do
      allow(parent_directory).to receive(:mkpath).with no_args

      allow(file).to receive(:open).with 'a'
    end

    after { described_instance.execute }

    context 'the parent directory' do
      subject { parent_directory }

      it('is created') { is_expected.to receive(:mkpath).with no_args }
    end

    context 'the output file' do
      subject { file }

      it('is ensured to be writable') { is_expected.to receive(:open).with 'a' }
    end
  end
end
