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
require_relative 'version'

module Terraform
  # Common logic for classes that include Kitchen::Configurable
  module Configurable
    extend Forwardable

    def_delegators :instance, :driver, :provisioner, :transport

    def self.included(configurable_class)
      configurable_class.plugin_version VERSION
    end

    def config_deprecated(attribute:, remediation:, type:, version:)
      log_deprecation aspect: "#{formatted(attribute: attribute)} as #{type}",
                      remediation: remediation, version: version
    end

    def config_error(attribute:, expected:)
      raise Kitchen::UserError, "#{formatted attribute: attribute} must be " \
                                  "interpretable as #{expected}"
    end

    def instance_pathname(filename:)
      File.join config[:kitchen_root], '.kitchen', 'kitchen-terraform',
                instance.name, filename
    end

    def log_deprecation(aspect:, remediation:, version:)
      logger.warn 'DEPRECATION NOTICE'
      logger.warn "Support for #{aspect} will be dropped in " \
                    "kitchen-terraform v#{version}"
      logger.warn remediation
    end

    private

    def formatted(attribute:)
      "#{self.class}#{instance.to_str}#config[:#{attribute}]"
    end
  end
end
