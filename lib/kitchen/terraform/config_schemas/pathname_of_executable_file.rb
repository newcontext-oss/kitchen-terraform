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
require "kitchen/terraform/config_predicates/pathname_of_executable_file"

# A validation schema for a configuration attribute which is a pathname of an executable file.
#
# @see http://dry-rb.org/gems/dry-validation/basics/working-with-schemas/ DRY Validation Working With Schemas
module Kitchen
  module Terraform
    module ConfigSchemas
      PathnameOfExecutableFile =
        ::Dry::Validation.Schema do
          configure do
            extend ::Kitchen::Terraform::ConfigPredicates::PathnameOfExecutableFile
          end
          required(:value).value :pathname_of_executable_file?
        end
    end
  end
end
