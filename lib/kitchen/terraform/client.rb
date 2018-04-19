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
require "kitchen/terraform"
require "kitchen/terraform/client_version_requirement"
require "kitchen/terraform/output_parser"

# Terraform commands are run by shelling out and using the
# {https://www.terraform.io/docs/commands/index.html Terraform command-line interface}, which is assumed to be present
# in the {https://en.wikipedia.org/wiki/PATH_(variable) PATH} of the user.
#
# The shell out environment includes the +TF_IN_AUTOMATION+ environment variable as specified by the
# {https://www.terraform.io/guides/running-terraform-in-automation.html Running Terraform in Automation guide}.
class ::Kitchen::Terraform::Client
  include ::Kitchen::Logging
  include ::Kitchen::ShellOut

  # This method runs the +terraform apply+ command against the root module directory.
  #
  # @param flags [::Array] a list of flags to add to the command.
  # @raise [::Kitchen::ShellOut::ShellCommandFailed] if the command fails.
  # @return [self]
  def apply(flags:)
    run_terraform command: "apply #{flags.join " "} #{root_module_directory}"
    self
  end

  # This method runs +terraform workspace delete+ against the test workspace.
  #
  # @raise [::Kitchen::ShellOut::ShellCommandFailed] if the command fails.
  # @return [self]
  def delete_kitchen_instance_workspace
    run_terraform command: "workspace delete kitchen-terraform-#{workspace_name}"
    self
  end

  # This method runs +terraform destroy+ against the root module directory.
  #
  # @param flags [::Array] a list of flags to add to the command.
  # @raise [::Kitchen::ShellOut::ShellCommandFailed] if the command fails.
  # @return [self]
  def destroy(flags:)
    run_terraform command: "destroy #{flags.join " "} #{root_module_directory}"
    self
  end

  # This method runs +terraform get+ against the root module directory.
  #
  # @raise [::Kitchen::ShellOut::ShellCommandFailed] if the command fails.
  # @return [self]
  def get(flags:)
    run_terraform command: "get #{flags.join " "} #{root_module_directory}"
    self
  end

  # This method runs +terraform init+ against the root module directory.
  #
  # @param flags [::Array] a list of flags to add to the command.
  # @raise [::Kitchen::ShellOut::ShellCommandFailed] if the command fails.
  # @return [self]
  def init(flags:)
    run_terraform command: "init #{flags.join " "} #{root_module_directory}"
    self
  end

  # This method runs +terraform version+ and yields an explanatory message if the version is not supported.
  #
  # @raise [::Kitchen::ShellOut::ShellCommandFailed] if the command fails.
  # @yieldparam message [::String] an explanation of why the version is not supported.
  def if_version_not_supported(&block)
    run_terraform command: "version"

    client_version_requirement
      .if_not_satisfied(
        client_version: command_output,
        &block
      )

    self
  end

  # This method runs +terraform output+ and stores the parsed result in a container.
  #
  # The output is formatted as JSON to support parsing.
  #
  # @param container [::Hash] a container to store the output.
  # @raise [::Kitchen::ShellOut::ShellCommandFailed] if the command fails.
  # @return [self]
  def output(container:)
    run_output

    output_parser
      .parse(
        container: container,
        output: command_output
      )

    self
  end

  # This method runs +terraform validate+ against the root module directory.
  #
  # @param flags [::Array] a list of flags to add to the command.
  # @raise [::Kitchen::ShellOut::ShellCommandFailed] if the command fails.
  # @return [self]
  def validate(flags:)
    run_terraform command: "validate #{flags.join " "} #{root_module_directory}"
    self
  end

  # This method runs +terraform select+ or +terraform new+ against the test workspace, yields control, and then runs
  # +terraform select+ against the default workspace.
  #
  # @raise [::Kitchen::ShellOut::ShellCommandFailed] if the command fails.
  # @return [self]
  def within_kitchen_instance_workspace(&block)
    block ||=
      proc do
      end

    select_or_new_kitchen_instance_workspace
    block.call
    select_default_workspace
    self
  end

  private

  attr_accessor(
    :client_version_requirement,
    :logger,
    :output_parser
  )

  attr_reader(
    :workspace_name,
    :root_module_directory,
    :command_output,
    :timeout
  )

  # @api private
  def command_output=(command_output)
    @command_output = String command_output
  end

  # @api private
  def initialize(logger:, root_module_directory:, timeout:, workspace_name:)
    self
      .client_version_requirement =
        ::Kitchen::Terraform::ClientVersionRequirement
          .new(
            requirement:
              [
                ">= 0.10.2",
                "< 0.12.0"
              ]
          )

    self.logger = logger
    self.command_output = ""
    self.output_parser = ::Kitchen::Terraform::OutputParser.new
    self.root_module_directory = root_module_directory
    self.timeout = timeout
    self.workspace_name = workspace_name
  end

  # @api private
  def run_terraform(command:)
    self
      .command_output =
        run_command(
          "terraform #{command}",
          environment:
            {
              "LC_ALL" => nil,
              "TF_IN_AUTOMATION" => "true"
            },
          timeout: timeout
        )
  end

  # @api private
  def root_module_directory=(root_module_directory)
    @root_module_directory = String root_module_directory
  end

  # @api private
  def run_output
    run_terraform command: "output -json"
  rescue ::Kitchen::ShellOut::ShellCommandFailed => shell_command_failed
    /no\\ outputs\\ defined/
      .match ::Regexp.escape shell_command_failed.message or
      raise shell_command_failed

    self.command_output = "{}"
  end

  # @api private
  def select_default_workspace
    run_terraform command: "workspace select default"
  end

  # @api private
  def select_or_new_kitchen_instance_workspace
    run_terraform command: "workspace select kitchen-terraform-#{workspace_name}"
  rescue ::Kitchen::ShellOut::ShellCommandFailed
    run_terraform command: "workspace new kitchen-terraform-#{workspace_name}"
  end

  # @api private
  def timeout=(timeout)
    @timeout = Integer timeout
  end

  # @api private
  def workspace_name=(workspace_name)
    @workspace_name =
      String(workspace_name)
        .gsub(
          /\s/,
          "-"
        )
  end
end
