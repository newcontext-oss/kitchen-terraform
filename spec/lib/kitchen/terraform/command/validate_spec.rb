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

require "kitchen"
require "kitchen/terraform/command/validate"
require "kitchen/terraform/shell_out_nu"

::RSpec.describe ::Kitchen::Terraform::Command::Validate do
  describe ".run" do
    let :directory do
      "/directory"
    end

    let :output do
      "output"
    end

    let :timeout do
      1234
    end

    let :validate do
      described_class.new color: false, variable_files: variable_files, variables: variables
    end

    let :variable_file_one do
      "/Arbitrary Directory/Variable File One.tfvars"
    end

    let :variable_file_two do
      "/Arbitrary Directory/Variable File Two.tfvars"
    end

    let :variable_files do
      [variable_file_one, variable_file_two]
    end

    let :variables do
      {
        string: variables_string,
        map: variables_map,
        list: variables_list,
      }
    end

    let :variables_list do
      "[ \\\"Element One\\\", \\\"Element Two\\\" ]"
    end

    let :variables_map do
      "{ key = \\\"A Value\\\" }"
    end

    let :variables_string do
      "\\\"A String\\\""
    end

    before do
      allow(::Kitchen::Terraform::ShellOutNu).to receive(:run_command).with(
        "terraform validate " \
        "-check-variables=true " \
        "-no-color " \
        "-var-file=\"#{variable_file_one}\" " \
        "-var-file=\"#{variable_file_two}\" " \
        "-var=\"string=#{variables_string}\" " \
        "-var=\"map=#{variables_map}\" " \
        "-var=\"list=#{variables_list}\"",
        cwd: directory,
        environment: kind_of(::Hash),
        timeout: timeout,
      ).and_return output
    end

    specify "should yield the result of running `terraform validate`" do
      expect do |block|
        described_class.run(
          color: false,
          directory: directory,
          variable_files: variable_files,
          variables: variables,
          timeout: timeout,
          &block
        )
      end.to yield_with_args validate: validate
    end
  end
end
