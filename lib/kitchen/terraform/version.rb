# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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

require "rubygems"

module Kitchen
  module Terraform
    # Kitchen::Terraform::Version represents the version of the Kitchen-Terraform gem. The module can send the version to
    # different containers as well as conditionally yield to blocks based on version requirements.
    module Version
      class << self
        # assign_plugin_version assigns the version to a class which includes Kitchen::Configurable.
        #
        # @param configurable_class [Kitchen::Configurable] the configurable class to which the version will be assigned.
        # @return [self]
        def assign_plugin_version(configurable_class:)
          configurable_class.plugin_version value.to_s
          self
        end

        # assign_specification_version assigns the version to a Gem::Specification.
        #
        # @param specification [Gem::Specification] the specification to which the version will be assigned.
        # @return [self]
        def assign_specification_version(specification:)
          specification.version = value
          self
        end

        # if_satisfies yields control if the provided requirement is satisfied by the version.
        #
        # @param requirement [Gem::Requirement, ::String] the requirement to be satisfied by the version.
        # @raise [Gem::Requirement::BadRequirementError] if the requirement is illformed.
        # @return [self]
        # @yield [] if the requirement is satisfied by the version.
        def if_satisfies(requirement:)
          yield if ::Gem::Requirement.new(requirement).satisfied_by? value

          self
        end

        # temporarily_override overrides the current version with the version provided, yields control, and then resets the
        # version.
        #
        # @note temporarily_override must only be used in tests to validate version flow control logic.
        # @raise [ArgumentError] if the version is malformed.
        # @return [self]
        # @yield [] the value of the version will be overridden while control is yielded.
        def temporarily_override(version:)
          current_value = value
          self.value = version
          yield
          self.value = current_value
          self
        end

        private

        # @api private
        def value
          self.value = ::Gem::Version.new "5.8.0" if not @value
          @value
        end

        # @api private
        def value=(version)
          @value = ::Gem::Version.new version
          self
        end
      end
    end
  end
end
