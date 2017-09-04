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

class ::Kitchen::Terraform::Client::Options
  def backend_config(key:, value:)
    add option: "-backend-config='#{key}=#{value}'"
  end

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

  def backup(path:)
    add option: "-backup=#{path}"
  end

  def disable_input
    add option: "-input=false"
  end

  def enable_auto_approve
    add option: "-auto-approve=true"
  end

  def enable_backend
    add option: "-backend=true"
  end

  def enable_check_variables
    add option: "-check-variables=true"
  end

  def enable_get
    add option: "-get=true"
  end

  def force
    add option: "-force"
  end

  def force_copy
    add option: "-force-copy"
  end

  def from_module(source:)
    add option: "-from-module=#{source}"
  end

  def json
    add option: "-json"
  end

  def enable_lock
    add option: "-lock=true"
  end

  def enable_refresh
    add option: "-refresh=true"
  end

  def lock_timeout(duration:)
    add option: "-lock-timeout=#{duration}"
  end

  def maybe_no_color(toggle:)
    toggle and no_color or self
  end

  def maybe_plugin_dir(path:)
    path and plugin_dir path: path or self
  end

  def no_color
    add option: "-no-color"
  end

  def parallelism(concurrent_operations:)
    add option: "-parallelism=#{concurrent_operations}"
  end

  def plugin_dir(path:)
    add option: "-plugin-dir=#{path}"
  end

  def state(path:)
    add option: "-state=#{path}"
  end

  def state_out(path:)
    add option: "-state-out=#{path}"
  end

  def upgrade
    add option: "-upgrade"
  end

  def var(key:, value:)
    add option: "-var='#{key}=#{value}'"
  end

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

  def var_file(path:)
    add option: "-var-file=#{path}"
  end

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

  def to_s
    @options.join " "
  end

  private

  def add(option:)
    self
      .class
      .new(
        option: option,
        options: @options
      )
  end

  def initialize(option: nil, options: [])
    @options = options + [option].compact
  end
end
