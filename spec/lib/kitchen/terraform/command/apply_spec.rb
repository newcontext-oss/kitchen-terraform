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
require "kitchen/terraform/command/apply"
require "kitchen/terraform/shell_out"

::RSpec.describe ::Kitchen::Terraform::Command::Apply do
  describe ".run" do
    let :apply do
      described_class.new(
        color: false,
        directory: directory,
        lock_timeout: lock_timeout,
        lock: lock,
        parallelism: parallelism,
        timeout: timeout,
        variable_files: variable_files,
        variables: variables,
      )
    end

    let :directory do
      "/directory"
    end

    let :lock do
      true
    end

    let :lock_timeout do
      "10s"
    end

    let :output do
      "output"
    end

    let :parallelism do
      1234
    end

    let :timeout do
      1234
    end

    let :variable_files do
      [variable_files_one, variable_files_two]
    end

    let :variable_files_one do
      "/Arbitrary Directory/Variable File One.tfvars"
    end

    let :variable_files_two do
      "/Arbitrary Directory/Variable File Two.tfvars"
    end

    let :variables do
      {list: variables_list, map: variables_map, string: variables_string}
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
      allow(::Kitchen::Terraform::ShellOut).to receive(:run_command).with(
        "terraform apply " \
        "-auto-approve " \
        "-input=false " \
        "-refresh=true " \
        "-no-color " \
        "-lock=#{lock} " \
        "-lock-timeout=#{lock_timeout} " \
        "-parallelism=#{parallelism} " \
        "-var=\"list=#{variables_list}\" " \
        "-var=\"map=#{variables_map}\" " \
        "-var=\"string=#{variables_string}\" " \
        "-var-file=\"#{variable_files_one}\" " \
        "-var-file=\"#{variable_files_two}\"",
        cwd: directory,
        environment: kind_of(::Hash),
        timeout: timeout,
      ).and_return output
    end

    specify "should yield the result of running `terraform apply`" do
      expect do |block|
        described_class.run(
          color: false,
          directory: directory,
          lock_timeout: lock_timeout,
          lock: lock,
          parallelism: parallelism,
          timeout: timeout,
          variable_files: variable_files,
          variables: variables,
          &block
        )
      end.to yield_with_args apply: apply
    end
  end
end
