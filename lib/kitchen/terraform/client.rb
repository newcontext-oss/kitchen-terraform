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
require "rubygems"

# Terraform commands are run by shelling out and using the
# {https://www.terraform.io/docs/commands/index.html Terraform command-line interface}, which is assumed to be present
# in the {https://en.wikipedia.org/wiki/PATH_(variable) PATH} of the user.
#
# The shell out environment includes the +TF_IN_AUTOMATION+ environment variable as specified by the
# {https://www.terraform.io/guides/running-terraform-in-automation.html Running Terraform in Automation guide}.
class ::Kitchen::Terraform::Client
  include ::Kitchen::Logging
  include ::Kitchen::ShellOut
  attr_writer :logger

  # This method runs the +terraform apply+ command against the root module directory.
  #
  # The generated plan is automatically approved.
  #
  # Input variables must be set through flags.
  #
  # The state of each resource is updated prior to planning and applying.
  #
  # @param flags [::Array] a list of flags to add to the command.
  # @return [self]
  def apply(flags:)
    run_terraform(
      command:
        "apply " \
          "-auto-approve=true " \
          "-input=false " \
          "-refresh=true " \
          "#{flags.join " "} " \
          "#{root_module_directory}"
    )
  end

  # This method runs +terraform workspace delete+ against the test workspace.
  #
  # @return [self]
  def delete_kitchen_instance_workspace
    run_terraform command: "workspace delete kitchen-terraform-#{workspace_name}"
  end

  # This method runs +terraform destroy+ against the root module directory.
  #
  # The generated plan is automatically approved.
  #
  # Input variables must be set through flags.
  #
  # The state of each resource is updated prior to planning and applying.
  #
  # @param flags [::Array] a list of flags to add to the command.
  # @return [self]
  def destroy(flags:)
    run_terraform(
      command:
        "destroy " \
          "-force " \
          "-input=false " \
          "-refresh=true " \
          "#{flags.join " "} " \
          "#{root_module_directory}"
    )
  end

  # This method runs +terraform get+ against the root module directory.
  #
  # Modules which are already downloaded are updated if possible.
  #
  # @return [self]
  def get
    run_terraform command: "get -update #{root_module_directory}"
  end

  # This method runs +terraform init+ against the root module directory.
  #
  # The backend is initialized.
  #
  # Existing workspace state is migrated.
  #
  # Plugins are installed.
  #
  # Child modules are installed.
  #
  # Input variables must be set through flags.
  #
  # The integrity of plugins is verified.
  #
  # @param flags [::Array] a list of flags to add to the command.
  # @return [self]
  def init(flags:)
    run_terraform(
      command:
        "init " \
          "-backend=true " \
          "-force-copy " \
          "-get-plugins=true " \
          "-get=true " \
          "-input=false " \
          "-verify-plugins=true " \
          "#{flags.join " "} " \
          "#{root_module_directory}"
    )
  end

  # This method runs +terraform init+ against the root module directory.
  #
  # The backend is initialized.
  #
  # Existing workspace state is migrated.
  #
  # Plugins are installed.
  #
  # Child modules are installed.
  #
  # Input variables must be set through flags.
  #
  # Modules and plugins are upgraded.
  #
  # The integrity of plugins is verified.
  #
  # @param flags [::Array] a list of flags to add to the command.
  # @return [self]
  def init_with_upgrade(flags:)
    run_terraform(
      command:
        "init " \
          "-backend=true " \
          "-force-copy " \
          "-get-plugins=true " \
          "-get=true " \
          "-input=false " \
          "-upgrade " \
          "-verify-plugins=true " \
          "#{flags.join " "} " \
          "#{root_module_directory}"
    )
  end

  # This method runs +terraform version+ and yields an explanatory message if the version is not supported.
  #
  # @yieldparam message [::String] an explanation of why the version is not supported.
  def if_version_not_supported(&block)
    run_terraform command: "version" do |output:|
      client_version_requirement
        .if_not_satisfied(
          client_version:
            ::Gem::Version
              .create(
                output
                  .slice(
                    /(\d+\.\d+\.\d+)/,
                    1
                  )
              ),
          &block
        )
    end

    self
  end

  # This method runs +terraform output+ and stores the parsed result in a container.
  #
  # The output is formatted as JSON to support parsing.
  #
  # @param container [::Hash] a container to store the output.
  # @return [self]
  def output(container:)
    run_terraform command: "output -json" do |output:|
      output_parser.output = output
    end

    output_parser.parse container: container
    self
  rescue ::Kitchen::ShellOut::ShellCommandFailed => shell_command_failed
    /no\\ outputs\\ defined/
      .match ::Regexp.escape shell_command_failed.message or
      raise shell_command_failed

    output_parser.parse container: container
    self
  end

  # Sets the attribute root_module_directory
  def root_module_directory=(root_module_directory)
    @root_module_directory = String root_module_directory
  end

  # This method runs +terraform workspace select+ against the default workspace.
  #
  # @return [self]
  def select_default_workspace
    run_terraform command: "workspace select default"
  end

  # This method runs +terraform select+ or +terraform new+ against the test workspace.
  #
  # @return [self]
  def select_or_create_kitchen_instance_workspace
    run_terraform command: "workspace select kitchen-terraform-#{workspace_name}"
  rescue ::Kitchen::ShellOut::ShellCommandFailed
    run_terraform command: "workspace new kitchen-terraform-#{workspace_name}"
  end

  # Sets the attribute timeout
  def timeout=(timeout)
    @timeout = Integer timeout
  end

  # This method runs +terraform validate+ against the root module directory.
  #
  # Input variables must be set through flags.
  def validate(flags:)
    run_terraform(
      command:
        "validate " \
          "-check-variables=true " \
          "#{flags.join " "} " \
          "#{root_module_directory}"
    )
  end

  # Sets the attribute workspace_name
  def workspace_name=(workspace_name)
    @workspace_name =
      String(workspace_name)
        .gsub(
          /\s/,
          "-"
        )
  end

  private

  attr_accessor(
    :client_version_requirement,
    :output_parser
  )

  attr_reader(
    :logger,
    :workspace_name,
    :root_module_directory,
    :timeout
  )

  # @api private
  def initialize
    self.client_version_requirement = ::Kitchen::Terraform::ClientVersionRequirement.new

    client_version_requirement
      .restrictions=(
        [
          ">= 0.10.2",
          "< 0.12.0"
        ]
      )

    self.logger = ::Kitchen.logger
    self.workspace_name = "unconfigured-client"
    self.output_parser = ::Kitchen::Terraform::OutputParser.new
    self.root_module_directory = "."
    self.timeout = 600
  end

  # @api private
  def run_terraform(command:, &block)
    block ||=
      proc do
      end

    block
      .call(
        output:
          run_command(
            "terraform #{command}",
            environment:
              {
                "LC_ALL" => nil,
                "TF_IN_AUTOMATION" => true
              },
            timeout: @timeout
          )
      )

    self
  end
end
