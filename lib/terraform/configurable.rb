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
require "kitchen"
require "kitchen/terraform/version"
require "terraform"
require "terraform/debug_logger"

# Miscellaneous behaviour for objects that extend ::Kitchen::Configurable.
module ::Terraform::Configurable
  extend ::Forwardable

  def_delegator :config, :[]=

  def_delegators :instance, :driver, :provisioner, :transport

  def self.included(configurable_class)
    configurable_class.plugin_version ::Kitchen::Terraform::VERSION
  end

  def debug_logger
    @debug_logger ||= ::Terraform::DebugLogger.new logger: logger
  end

  def instance_pathname(filename:)
    ::File
      .join(
        config.fetch(:kitchen_root),
        ".kitchen",
        "kitchen-terraform",
        instance.name,
        filename
      )
  end
end
