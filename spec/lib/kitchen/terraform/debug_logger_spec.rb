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

require "kitchen"
require "kitchen/terraform/debug_logger"

::RSpec.describe ::Kitchen::Terraform::DebugLogger do
  subject do
    described_class.new logger
  end

  let :logger do
    instance_double ::Kitchen::Logger
  end

  shared_examples "#debug" do
    after do
      subject << "message"
    end

    specify "forwards the message to #debug of the wrapped logger" do
      expect(logger).to receive(:debug).with "message"
    end
  end

  describe "#<< " do
    it_behaves_like "#debug"
  end

  describe "#debug" do
    it_behaves_like "#debug"
  end
end
