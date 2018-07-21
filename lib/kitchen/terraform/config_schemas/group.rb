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

require "dry/validation"
require "kitchen/terraform/config_schemas"

module Kitchen
  module Terraform
    module ConfigSchemas
      # Kitchen::Terraform::ConfigSchemas::Group is a validation schema for the groups configuration attribute.
      Group = ::Dry::Validation.Params do
        required(:name).filled :str?
        required(:backend).filled :str?
        optional(:attributes).filled :hash?
        optional(:attrs).each(:filled?, :str?)
        optional(:backend_cache).value :bool?
        optional(:bastion_host).filled :str?
        optional(:bastion_port).value :int?
        optional(:bastion_user).filled :str?
        optional(:controls).each(:filled?, :str?)
        optional(:enable_password).filled :str?
        optional(:hosts_output).filled :str?
        optional(:key_files).each(:filled?, :str?)
        optional(:password).filled :str?
        optional(:path).filled :str?
        optional(:port).value :int?
        optional(:proxy_command).filled :str?
        optional(:reporter).each(:filled?, :str?)
        optional(:self_signed).value :bool?
        optional(:shell).value :bool?
        optional(:shell_command).filled :str?
        optional(:shell_options).filled :str?
        optional(:show_progress).value :bool?
        optional(:ssl).value :bool?
        optional(:user).filled :str?
      end
    end
  end
end
