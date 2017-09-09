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

require "kitchen/terraform/client"

# Represents supported options for client commands.
class ::Kitchen::Terraform::Client::Options
  # Adds -backend-config with arguments to the options.
  #
  # @param key [#to_s] the backend configuration key
  # @param value [#to_s] the backend configuration value
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def backend_config(key:, value:)
    add option: "-backend-config='#{key}=#{value}'"
  end

  # Adds -backend-config with arguments to the options multiple times.
  #
  # @param keys_and_values [::Hash<#to_s, #to_s>] the backend configuration keys and values
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def backend_configs(keys_and_values:)
    keys_and_values
      .inject self do |additional_options, (key, value)|
        additional_options
          .backend_config(
            key: key,
            value: value
          )
      end
  end

  # Adds -input=false to the options.
  #
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def disable_input
    add option: "-input=false"
  end

  # Adds -auto-approve=true to the options.
  #
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def enable_auto_approve
    add option: "-auto-approve=true"
  end

  # Adds -backend=true to the options.
  #
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def enable_backend
    add option: "-backend=true"
  end

  # Adds -check-variables=true to the options.
  #
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def enable_check_variables
    add option: "-check-variables=true"
  end

  # Adds -get=true to the options.
  #
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def enable_get
    add option: "-get=true"
  end

  # Adds -force to the options.
  #
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def force
    add option: "-force"
  end

  # Adds -force-copy to the options.
  #
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def force_copy
    add option: "-force-copy"
  end

  # Adds -from-module with an argument to the options.
  #
  # @param source [#to_s] the module source
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def from_module(source:)
    add option: "-from-module=#{source}"
  end

  # Adds -json to the options.
  #
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def json
    add option: "-json"
  end

  # Adds -lock=true to the options.
  #
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def enable_lock
    add option: "-lock=true"
  end

  # Adds -refresh=true to the options.
  #
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def enable_refresh
    add option: "-refresh=true"
  end

  # Adds -lock-timeout with an argument to the options.
  #
  # @param duration [#to_s] the lock timeout duration
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def lock_timeout(duration:)
    add option: "-lock-timeout=#{duration}"
  end

  # Conditionally adds -no-color to the options.
  #
  # @param toggle [::TrueClass, ::FalseClass] the flag toggle
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def maybe_no_color(toggle:)
    toggle and no_color or self
  end

  # Conditionally adds -plugin-dir to the options.
  #
  # @param path [::TrueClass, ::FalseClass] the path to the plugin directory
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def maybe_plugin_dir(path:)
    path and plugin_dir path: path or self
  end

  # Adds -no-color to the options.
  #
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def no_color
    add option: "-no-color"
  end

  # Adds -parallelism with an argument to the options.
  #
  # @param concurrent_operations [#to_s] the number of concurrent operations
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def parallelism(concurrent_operations:)
    add option: "-parallelism=#{concurrent_operations}"
  end

  # Adds -plugin-dir with an argument to the options.
  #
  # @param path [#to_s] the path to the plugin directory
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def plugin_dir(path:)
    add option: "-plugin-dir=#{path}"
  end

  # Adds -state with an argument to the options.
  #
  # @param path [#to_s] the path to the input state file
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def state(path:)
    add option: "-state=#{path}"
  end

  # Adds -state-out with an argument to the options.
  #
  # @param path [#to_s] the path to the output state file
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def state_out(path:)
    add option: "-state-out=#{path}"
  end

  # Adds -upgrade to the options.
  #
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def upgrade
    add option: "-upgrade"
  end

  # Adds -var with arguments to the options.
  #
  # @param key [#to_s] the variable key
  # @param value [#to_s] the variable value
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def var(key:, value:)
    add option: "-var='#{key}=#{value}'"
  end

  # Adds -var with arguments to the options multiple times.
  #
  # @param keys_and_values [::Hash<#to_s, #to_s>] the variable keys and values
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def vars(keys_and_values:)
    keys_and_values
      .inject self do |additional_options, (key, value)|
        additional_options
          .var(
            key: key,
            value: value
          )
      end
  end

  # Adds -var-file with an argument to the options.
  #
  # @param path [#to_s] the path to the variable file
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def var_file(path:)
    add option: "-var-file=#{path}"
  end

  # Adds -var-file with an argument to the options multiple times.
  #
  # @param paths [::Array<#to_s>] the paths to the variable files
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def var_files(paths:)
    paths
      .inject self do |additional_options, path|
        additional_options.var_file path: path
      end
  end

  # Adds -verify-plugins with an argument to the options.
  #
  # @param toggle [#to_s] toggle to enable or disable
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def verify_plugins(toggle:)
    add option: "-verify-plugins=#{toggle}"
  end

  # The options expressed as a space delimited string.
  #
  # @return [::String] the options string
  def to_s
    @options.join " "
  end

  private

  # Adds an option to the collection.
  #
  # @api private
  # @param option [::String] the option to be added
  # @return [::Kitchen::Terraform::Client::Options] the expanded options
  def add(option:)
    self
      .class
      .new(
        option: option,
        options: @options
      )
  end

  # Initializes the collection of options.
  #
  # @api private
  # @param option [::String] a new option to add to the collection.
  # @param options [::Array] the current collection
  def initialize(option: nil, options: [])
    @options = options + [option].compact
  end
end
