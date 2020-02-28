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

require "kitchen"
require "kitchen/terraform/inspec_runner"

module Kitchen
  module Terraform
    module InSpec
      # WithoutHosts is the class of objects which execute InSpec without hosts.
      class WithoutHosts
        # #exec executes the InSpec controls of an InSpec profile.
        #
        # @raise [Kitchen::TransientFailure] if the execution of InSpec fails.
        # @return [self]
        def exec
          ::Kitchen::Terraform::InSpecRunner.new(options: options, profile_locations: profile_locations).exec

          self
        end

        # #initialize prepares a new instance of the class.
        #
        # @param options [Hash] a mapping of InSpec options.
        # @param profile_locations [Array<::String>] the locations of the InSpec profiles which contain the controls
        #   to be executed.
        # @return [Kitchen::Terraform::InSpec::WithoutHosts]
        def initialize(options:, profile_locations:)
          self.options = options
          self.profile_locations = profile_locations
        end

        private

        attr_accessor :options, :profile_locations
      end
    end
  end
end
