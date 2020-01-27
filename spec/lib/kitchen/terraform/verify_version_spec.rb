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
require "kitchen/terraform/verify_version"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::VerifyVersion do
  subject do
    described_class.new config: config, logger: logger
  end

  let :client do
    "/client"
  end

  let :config do
    {client: client, root_module_directory: root_module_directory, verify_version: verify_version}
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  let :root_module_directory do
    "/root-module"
  end

  let :verify_version do
    true
  end

  let :version_requirement do
    instance_double ::Gem::Requirement
  end

  let :version_verifier do
    instance_double ::Kitchen::Terraform::VersionVerifier
  end

  describe "#call" do
    before do
      allow(::Kitchen::Terraform::VersionVerifier).to receive(:new).with(
        command: kind_of(::Kitchen::Terraform::Command::Version),
        logger: logger
      ).and_return version_verifier
    end

    specify "should verify the version using a version requirement" do
      expect(version_verifier).to receive(:verify).with(
        options: {cwd: root_module_directory},
        requirement: version_requirement,
        strict: verify_version
      )
    end

    after do
      subject.call version_requirement: version_requirement
    end
  end
end