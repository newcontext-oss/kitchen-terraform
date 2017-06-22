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

require "kitchen/verifier/terraform/configure_inspec_runner_backend"

::RSpec.describe ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerBackend do
  let :omitted do
    instance_double ::Object
  end

  let :options do
    {}
  end

  before do
    described_class.call hostname: hostname, options: options
  end

  subject do
    options.fetch "backend", omitted
  end

  context "when the hostname is 'localhost'" do
    let :hostname do
      "localhost"
    end

    it "associates 'backend' with 'local' in the options" do
      is_expected.to eq "local"
    end
  end

  context "when the hostname is not 'localhost'" do
    let :hostname do
      "abc"
    end

    it "omits 'backend'" do
      is_expected.to be omitted
    end
  end
end
