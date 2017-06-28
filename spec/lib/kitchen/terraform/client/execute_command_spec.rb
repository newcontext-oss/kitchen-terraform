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

require "mixlib/shellout"
require "kitchen/terraform/client/execute_command"
require "support/dry/monads/either_matchers"
require "support/kitchen/terraform/client/execute_command_context"

::RSpec.describe ::Kitchen::Terraform::Client::ExecuteCommand do
  describe ".call" do
    let :options do
      {}
    end

    subject do
      described_class.call cli: "cli",
                           command: "command",
                           logger: [],
                           options: options,
                           target: "target",
                           timeout: 1234
    end

    context "when unsupported options are provided" do
      let :options do
        {
          unsupported_option: "unsupported_option"
        }
      end

      it do
        is_expected.to result_in_failure.with_the_value /:unsupported/
      end
    end

    shared_examples "the command experiences an error" do |error_class:|
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "command",
                                                                    error: true,
                                                                    error_class: error_class

      it do
        is_expected.to result_in_failure
          .with_the_value /`cli command target` failed: '.*mocked `cli command target` error'/
      end
    end

    context "when the command experiences a permissions error" do
      it_behaves_like "the command experiences an error", error_class: ::Errno::EACCES
    end

    context "when the command experiences an entry error" do
      it_behaves_like "the command experiences an error", error_class: ::Errno::ENOENT
    end

    context "when the command experiences a timeout error" do
      it_behaves_like "the command experiences an error", error_class: ::Mixlib::ShellOut::CommandTimeout
    end

    context "when the command exits with a nonzero value" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "command"

      it do
        is_expected.to result_in_failure.with_the_value /`cli command target` failed: '.+'/
      end
    end

    context "when the command exits with a zero value" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "command",
                                                                    exit_code: 0

      it do
        is_expected.to result_in_success.with_the_value "mocked `cli command target` output"
      end
    end
  end
end
