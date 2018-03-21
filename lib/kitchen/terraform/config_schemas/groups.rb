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

require "dry-validation"
require "kitchen/terraform/config_predicates"
require "kitchen/terraform/config_schemas"

# A {http://dry-rb.org/gems/dry-validation/basics/working-with-schemas/ DRY Validation schema} for the groups
# configuration attribute which is an array of hashes.
::Kitchen::Terraform::ConfigSchemas::Groups =
  ::Dry::Validation
    .Schema do
      configure do
        extend ::Kitchen::Terraform::ConfigPredicates
      end

      required(:value)
        .each do
          schema do
            required(:name).filled :str?

            optional(:attributes).value :hash_of_symbols_and_strings?
            optional(:hostnames).filled :str?

            optional(:inspec_options)
              .schema do
                optional(:attrs)
                  .each(
                    :filled?,
                    :str?,
                    :path_to_existent_file?
                  )

                optional(:backend).filled :str?
                optional(:backend_cache).value :bool?

                optional(:controls)
                  .each(
                    :filled?,
                    :str?
                  )

                optional(:create_lockfile).value :bool?

                optional(:key_files)
                  .each(
                    :filled?,
                    :str?,
                    :path_to_existent_file?
                  )

                optional(:password).filled :str?
                optional(:path).filled :str?
                optional(:port).value :int?

                optional(:reporter)
                  .each(
                    :filled?,
                    :str?
                  )

                optional(:self_signed).value :bool?
                optional(:shell).value :bool?
                optional(:shell_command).filled :str?
                optional(:shell_options).filled :str?
                optional(:show_progress).value :bool?
                optional(:ssl).value :bool?
                optional(:sudo).value :bool?
                optional(:sudo_command).filled :str?
                optional(:sudo_options).filled :str?
                optional(:sudo_password).filled :str?
                optional(:user).filled :str?
                optional(:vendor_cache).filled :str?
              end
          end
        end
    end
