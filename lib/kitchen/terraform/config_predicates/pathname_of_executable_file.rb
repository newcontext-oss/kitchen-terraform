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

require "dry/logic"
require "pathname"

module Kitchen
  module Terraform
    module ConfigPredicates
      # This module comprises a configuration attribute predicate for a pathname of an executable file.
      #
      # This module must be declared as providing predicates and extended in a schema's configuration in order to be
      # used.
      module PathnameOfExecutableFile
        class << self
          def executable_pathname?(value:)
            Pathname(value).executable?
          rescue
            false
          end
        end
        # A callback to configure an extending schema with this predicate.
        #
        # @param schema [::Dry::Validation::Schema] the schema to be configured.
        # @return [self]
        def self.extended(schema)
          schema.predicates self

          self
        end

        include ::Dry::Logic::Predicates

        predicate :pathname_of_executable_file? do |value|
          executable_pathname? value: value
        end

        private

        def messages
          super.merge en: { errors: { pathname_of_executable_file?: "must be a valid pathname of an executable file" } }
        end
      end
    end
  end
end
