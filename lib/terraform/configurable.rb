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

require 'forwardable'
require 'kitchen'
require 'pathname'
require 'terraform/client'
require 'terraform/debug_logger'
require 'terraform/project_version'

module Terraform
  # Behaviour for objects that extend ::Kitchen::Configurable
  module Configurable
    extend ::Forwardable

    def_delegator :config, :[]=

    def_delegators :instance, :driver, :provisioner, :transport

    def self.included(configurable_class)
      configurable_class.plugin_version ::Terraform::PROJECT_VERSION
    end

    def client
      ::Terraform::Client.new config: provisioner, logger: logger
    end

    def config_deprecated(attr:, remediation:, type:)
      log_deprecation aspect: "#{formatted_config attr: attr} as #{type}",
                      remediation: remediation
    end

    def config_error(attr:, expected:)
      raise ::Kitchen::UserError, "#{formatted_config attr: attr} must be " \
                                    "interpretable as #{expected}"
    end

    def debug_logger
      ::Terraform::DebugLogger.new logger: logger
    end

    def instance_pathname(filename:)
      ::Pathname.new(config[:kitchen_root])
                .join '.kitchen', 'kitchen-terraform', instance.name, filename
    end

    def limited_client
      ::Terraform::Client.new logger: debug_logger
    end

    def log_deprecation(aspect:, remediation:)
      logger.warn 'DEPRECATION NOTICE'
      logger
        .warn "Support for #{aspect} will be dropped in kitchen-terraform v1.0"
      logger.warn remediation
    end

    def silent_client
      ::Terraform::Client.new config: silent_config, logger: debug_logger
    end

    private

    def formatted_config(attr:)
      "#{self.class}#{instance.to_str}#config[:#{attr}]"
    end

    def silent_config
      provisioner.dup.tap { |config| config[:color] = false }
    end
  end
end
