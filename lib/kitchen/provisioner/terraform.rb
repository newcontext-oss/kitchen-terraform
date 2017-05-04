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
require "kitchen/config/apply_timeout"
require "kitchen/config/color"
require "kitchen/config/directory"
require "kitchen/config/parallelism"
require "kitchen/config/plan"
require "kitchen/config/state"
require "kitchen/config/variable_files"
require "kitchen/config/variables"
require "terraform/configurable"

# Applies constructive Terraform plans
class ::Kitchen::Provisioner::Terraform < ::Kitchen::Provisioner::Base
  ::Kitchen::Config::ApplyTimeout.call plugin_class: self

  ::Kitchen::Config::Color.call plugin_class: self

  ::Kitchen::Config::Directory.call plugin_class: self

  ::Kitchen::Config::Parallelism.call plugin_class: self

  ::Kitchen::Config::Plan.call plugin_class: self

  ::Kitchen::Config::State.call plugin_class: self

  ::Kitchen::Config::VariableFiles.call plugin_class: self

  ::Kitchen::Config::Variables.call plugin_class: self

  include ::Terraform::Configurable

  kitchen_provisioner_api_version 2

  def call(_state = nil)
    client.apply_constructively
  rescue ::Kitchen::StandardError, ::SystemCallError => error
    raise ::Kitchen::ActionFailed, error.message
  end
end
