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

require 'kitchen'
require 'terraform/debug_logger'

::RSpec.describe ::Terraform::DebugLogger do
  let(:described_instance) { described_class.new logger: logger }

  let(:logger) { instance_double ::Kitchen::Logger }

  shared_examples '#debug' do
    after { described_instance << 'message' }

    subject { logger }

    it 'forwards the message to #debug of the wrapped logger' do
      is_expected.to receive(:debug).with 'message'
    end
  end

  describe('#<< ') { it_behaves_like '#debug' }

  describe('#debug') { it_behaves_like '#debug' }
end
