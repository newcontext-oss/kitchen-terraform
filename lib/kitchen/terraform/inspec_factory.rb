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

require "kitchen/terraform/inspec/fail_fast_with_hosts"
require "kitchen/terraform/inspec/fail_slow_with_hosts"
require "kitchen/terraform/inspec/without_hosts"

module Kitchen
  module Terraform
    # InSpecFactory is the class of objects which build InSpec objects.
    class InSpecFactory
      # #build creates a new instance of an InSpec object.
      #
      # @param logger [Kitchen::Logger] a logger to log messages.
      # @param options [Hash] a mapping of InSpec options.
      # @param profile_locations [Array<::String>] the locations of the InSpec profiles which contain the controls to
      #   be executed.
      # @return [Kitchen::Terraform::InSpec::WithoutHosts, Kitchen::Terraform::InSpec::FailFastWithHosts,
      #   Kitchen::Terraform::InSpec::FailFastWithoutHosts]
      def build(logger:, options:, profile_locations:)
        if hosts.empty?
          ::Kitchen::Terraform::InSpec::WithoutHosts.new(
            logger: logger,
            options: options,
            profile_locations: profile_locations,
          )
        else
          if fail_fast
            ::Kitchen::Terraform::InSpec::FailFastWithHosts.new(
              hosts: hosts,
              logger: logger,
              options: options,
              profile_locations: profile_locations,
            )
          else
            ::Kitchen::Terraform::InSpec::FailSlowWithHosts.new(
              hosts: hosts,
              logger: logger,
              options: options,
              profile_locations: profile_locations,
            )
          end
        end
      end

      # #initialize prepares a new instance of the class
      #
      # @param fail_fast [Boolean] a toggle for fail fast or fail slow behaviour.
      # @param hosts [Array<String>] a list of hosts to verify with InSpec.
      # @return [Kitchen::Terraform::InSpecFactory]
      def initialize(fail_fast:, hosts:)
        self.fail_fast = fail_fast
        self.hosts = hosts
      end

      private

      attr_accessor :fail_fast, :hosts
    end
  end
end
