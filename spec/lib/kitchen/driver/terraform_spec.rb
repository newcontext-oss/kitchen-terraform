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

require "json"
require "kitchen/driver/terraform"
require "support/dry/monads/either_matchers"
require "support/kitchen/driver/terraform_context"
require "support/kitchen/terraform/clear_directory_context"
require "support/kitchen/terraform/client/command_context"
require "support/kitchen/terraform/config_attribute/backend_configurations_examples"
require "support/kitchen/terraform/config_attribute/color_examples"
require "support/kitchen/terraform/config_attribute/command_timeout_examples"
require "support/kitchen/terraform/config_attribute/directory_examples"
require "support/kitchen/terraform/config_attribute/lock_timeout_examples"
require "support/kitchen/terraform/config_attribute/parallelism_examples"
require "support/kitchen/terraform/config_attribute/plugin_directory_examples"
require "support/kitchen/terraform/config_attribute/state_examples"
require "support/kitchen/terraform/config_attribute/variable_files_examples"
require "support/kitchen/terraform/config_attribute/variables_examples"
require "support/kitchen/terraform/config_attribute/verify_plugins_examples"
require "support/kitchen/terraform/create_directories_context"
require "support/terraform/configurable_context"
require "support/terraform/configurable_examples"

::RSpec.describe ::Kitchen::Driver::Terraform do
  include_context "instance"

  let :described_instance do
    driver
  end

  shared_examples "workflow" do |subcommand:|
    context "when the create directories function results in failure" do
      include_context "Kitchen::Terraform::CreateDirectories.call failure"

      it "raises an action failed error" do
        is_expected
          .to(
            raise_error(
              ::Kitchen::ActionFailed,
              kind_of(::String)
            )
          )
      end
    end

    context "when the init subcommand results in a failure" do
      include_context "Kitchen::Terraform::CreateDirectories.call success"

      include_context "Kitchen::Terraform::ClearDirectory"

      include_context "Kitchen::Terraform::Client::Command.init failure"

      it "raises an action failed error" do
        is_expected
          .to(
            raise_error(
              ::Kitchen::ActionFailed,
              /terraform init/
            )
          )
      end
    end

    context "when the validate subcommand results in failure" do
      include_context "Kitchen::Terraform::CreateDirectories.call success"

      include_context "Kitchen::Terraform::ClearDirectory"

      include_context "Kitchen::Terraform::Client::Command.init success"

      include_context "Kitchen::Terraform::Client::Command.validate failure"

      it "raises an action failed error" do
        is_expected
          .to(
            raise_error(
              ::Kitchen::ActionFailed,
              /terraform validate/
            )
          )
      end
    end

    context "when the #{subcommand} subcommand results in failure" do
      include_context "Kitchen::Terraform::CreateDirectories.call success"

      include_context "Kitchen::Terraform::ClearDirectory"

      include_context "Kitchen::Terraform::Client::Command.init success"

      include_context "Kitchen::Terraform::Client::Command.validate success"

      include_context "Kitchen::Terraform::Client::Command.#{subcommand} failure"

      it "raises an action failed error" do
        is_expected
          .to(
            raise_error(
              ::Kitchen::ActionFailed,
              /terraform #{subcommand}/
            )
          )
      end
    end

    context "when each subcommand results in success" do
      include_context "Kitchen::Terraform::CreateDirectories.call success"

      include_context "Kitchen::Terraform::ClearDirectory"

      include_context "Kitchen::Terraform::Client::Command.init success"

      include_context "Kitchen::Terraform::Client::Command.validate success"

      include_context "Kitchen::Terraform::Client::Command.#{subcommand} success"

      it "raises no error" do
        is_expected.to_not raise_error
      end
    end
  end

  it_behaves_like ::Terraform::Configurable

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::BackendConfigurations"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::CommandTimeout"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Color"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Directory"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::LockTimeout"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Parallelism"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::PluginDirectory"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::State"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::VariableFiles"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Variables"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::VerifyPlugins"

  describe ".serial_actions" do
    subject do
      described_class.serial_actions
    end

    it "is empty" do
      is_expected.to be_empty
    end
  end

  describe "#create" do
    subject do
      lambda do
        described_instance.create instance_double ::Object
      end
    end

    it_behaves_like(
      "workflow",
      subcommand: "apply"
    )
  end

  describe "#destroy" do
    subject do
      lambda do
        described_instance.destroy instance_double ::Object
      end
    end

    it_behaves_like(
      "workflow",
      subcommand: "destroy"
    ) do
      before do
        allow(file_utils).to receive :remove_dir
      end

      context "when the function to remove the instance directory results in failure" do
        include_context "Kitchen::Terraform::CreateDirectories.call success"

        include_context "Kitchen::Terraform::ClearDirectory"

        include_context "Kitchen::Terraform::Client::Command.init success"

        include_context "Kitchen::Terraform::Client::Command.validate success"

        include_context "Kitchen::Terraform::Client::Command.destroy success"

        before do
          allow(file_utils).to receive(:remove_dir).and_raise "failed to remove directory"
        end

        it "raises an action failed error" do
          is_expected.to(
            raise_error(
              ::Kitchen::ActionFailed,
              "failed to remove directory"
            )
          )
        end
      end
    end
  end

  describe "#output" do
    subject do
      described_instance.output
    end

    context "when the output function results in failure" do
      include_context "Kitchen::Terraform::Client::Command.output failure"

      it do
        is_expected.to result_in_failure.with_the_value /terraform output/
      end
    end

    context "when the value of the output function result does not match the expected format of JSON" do
      include_context "Kitchen::Terraform::Client::Command.output success"

      it do
        is_expected.to result_in_failure
          .with_the_value /parsing Terraform client output as JSON failed.*unexpected token/m
      end
    end

    context "when the value of the output function result matches the expected format of JSON" do
      include_context(
        "Kitchen::Terraform::Client::Command.output success",
        output:
          ::JSON
            .dump(
              output_name: {
                sensitive: false,
                type: "list",
                value: ["output_value_1"]
              }
            )
      )

      it do
        is_expected
          .to(
            result_in_success
              .with_the_value(
                "output_name" => {
                  "sensitive" => false,
                  "type" => "list",
                  "value" => ["output_value_1"]
                }
              )
          )
      end
    end
  end

  describe "#verify_dependencies" do
    subject do
      lambda do
        described_instance.verify_dependencies
      end
    end

    shared_examples "the verification of dependencies is a failure" do
      it "raises a user error" do
        is_expected.to raise_error ::Kitchen::UserError
      end
    end

    context "when the result of the version function is a failure" do
      include_context "Kitchen::Terraform::Client::Command.version failure"

      it_behaves_like "the verification of dependencies is a failure"
    end

    context "when the result of the version verification function is a failure" do
      include_context(
        "Kitchen::Terraform::Client::Command.version success",
        output: "Terraform v0.10.1"
      )

      it_behaves_like "the verification of dependencies is a failure"
    end

    context "when the result of the version verification function is a success" do
      include_context(
        "Kitchen::Terraform::Client::Command.version success",
        output: "Terraform v0.10.2"
      )

      it "does not raise an error" do
        is_expected.to_not raise_error
      end
    end
  end
end
