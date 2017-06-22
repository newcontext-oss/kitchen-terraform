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

require "forwardable"
require "terraform"

# Behaviour for objects that extend ::Kitchen::Configurable
module ::Terraform::Configurable
  extend ::Forwardable

  def_delegator :config, :[]=

  def_delegators :instance, :driver, :provisioner, :transport

  def self.included(configurable_class)
    configurable_class.plugin_version ::Terraform::PROJECT_VERSION
  end

  def client
    ::Kitchen::Terraform::Client.new config: driver, logger: logger
  end

  def config_error(attr:, expected:)
    raise ::Kitchen::UserError, "#{formatted_config attr: attr} must be interpretable as #{expected}"
  end

  def debug_logger
    @debug_logger ||= ::Terraform::DebugLogger.new logger: logger
  end

  def instance_pathname(filename:)
    ::File.join config.fetch(:kitchen_root), ".kitchen", "kitchen-terraform", instance.name, filename
  end

  def silent_client
    ::Kitchen::Terraform::Client.new config: silent_config, logger: debug_logger
  end

  private

  def formatted_config(attr:)
    "#{self.class}#{instance.to_str}#config[:#{attr}]"
  end

  def silent_config
    driver.tap do |config| config[:color] = false end
  end
end

require "kitchen"
require "kitchen/terraform/client"
require "terraform/debug_logger"
require "terraform/project_version"
