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

require "kitchen"
require "kitchen/terraform/version_verifier_strategy/permissive"

::RSpec.describe ::Kitchen::Terraform::VersionVerifierStrategy::Permissive do
  subject do
    described_class.new logger: ::Kitchen::Logger.new
  end

  describe "#supported" do
    specify "should not raise an error" do
      expect do
        subject.supported
      end.to_not raise_error
    end
  end

  describe "#unsupported" do
    specify "should not raise an error" do
      expect do
        subject.unsupported
      end.to_not raise_error
    end
  end
end
