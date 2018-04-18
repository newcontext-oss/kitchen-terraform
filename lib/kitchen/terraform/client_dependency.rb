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
require "kitchen/terraform/client"

module ::Kitchen::Terraform::ClientDependency
  private

  attr_accessor :client

  # Instantiates a Terraform client and verifies that the version of the client is supported.
  #
  # @api private
  # @raise [::Kitchen::ClientError] if the version of the client is not supported.
  # @return [self]
  def load_needed_dependencies!
    super

    self
      .client =
        ::Kitchen::Terraform::Client
          .new(
            logger: logger,
            root_module_directory: config_root_module_directory,
            timeout: config_command_timeout,
            workspace_name: instance.name
          )

    client
      .if_version_not_supported do |message:|
        raise message
      end

    self
  rescue ::StandardError => error
    client_error error: error
  end
end
