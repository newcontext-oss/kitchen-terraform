# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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

require "kitchen/terraform/inspec_runner"

module Kitchen
  module Terraform
    module InSpec
      # FailFastWithHosts is the class of objects which execute InSpec against multiple hosts and raise rescued errors
      # immediately.
      class FailFastWithHosts
        # exec executes the InSpec controls of an InSpec profile.
        #
        # @raise [Kitchen::TransientFailure] if the execution of InSpec fails.
        # @return [self]
        def exec
          hosts.each do |host|
            ::Kitchen::Terraform::InSpecRunner.new(
              options: options.merge(host: host),
              profile_locations: profile_locations,
            ).exec
          end

          self
        end

        # #initialize prepares a new instance of the class.
        #
        # @param hosts [Array<::String>] the names or addresses of hosts on which Inspec controls will be executed.
        # @param options [Hash] options for execution.
        # @param profile_locations [Array<::String>] the locations of the InSpec profiles which contain the controls
        #   to be executed.
        # @return [Kitchen::Terraform::InSpec::FailFastWithHosts]
        def initialize(hosts:, options:, profile_locations:)
          self.hosts = hosts
          self.options = options
          self.profile_locations = profile_locations
        end

        private

        attr_accessor :hosts, :options, :profile_locations
      end
    end
  end
end
