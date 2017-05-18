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
require "kitchen/terraform/define_config_attribute"
require "kitchen/verifier/inspec"
require "terraform/configurable"

# Runs tests post-converge to confirm that instances in the Terraform state are in an expected state
::Kitchen::Verifier::Terraform = ::Class.new ::Kitchen::Verifier::Inspec

::Kitchen::Verifier::Terraform.kitchen_verifier_api_version 2

::Kitchen::Verifier::Terraform.send :include, ::Terraform::Configurable

require "kitchen/verifier/terraform/groups_messages"
require "kitchen/verifier/terraform/groups_strings_or_symbols"

::Kitchen::Terraform::DefineConfigAttribute.call(
  attribute: :groups,
  initialize_default_value: lambda do |_plugin|
    []
  end,
  plugin_class: ::Kitchen::Verifier::Terraform,
  schema: lambda do
    configure do
      define_singleton_method :messages, &::Kitchen::Verifier::Terraform::GroupsMessages
      define_method :strings_or_symbols?, &::Kitchen::Verifier::Terraform::GroupsStringsOrSymbols
    end
    required(:value).each do
      schema do
        required(:name).filled :str?
        optional(:attributes).value :hash?, :strings_or_symbols?
        optional(:controls).each :filled?, :str?
        optional(:hostnames).value :str?
        optional(:port).value :int?
        optional(:username).value :str?
      end
    end
  end
)

require "kitchen/verifier/terraform/call"
require "kitchen/verifier/terraform/runner_options"

::Kitchen::Verifier::Terraform.send :define_method, :call, ::Kitchen::Verifier::Terraform::Call

::Kitchen::Verifier::Terraform.send :define_method, :runner_options, ::Kitchen::Verifier::Terraform::RunnerOptions

::Kitchen::Verifier::Terraform.send :private, :runner_options
