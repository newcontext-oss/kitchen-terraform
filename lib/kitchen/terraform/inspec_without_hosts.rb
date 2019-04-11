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

require "kitchen/terraform/inspec"

module Kitchen
  module Terraform
    # InSpec instances act as interfaces to the InSpec gem.
    class InSpecWithoutHosts
      # exec executes the InSpec controls of an InSpec profile.
      #
      # @raise [::Kitchen::Terraform::Error] if the execution of the InSpec controls fails.
      # @return [void]
      def exec(system:)
        ::Kitchen::Terraform::InSpec
          .new(options: options, profile_locations: profile_locations).info(message: "#{system}: Verifying").exec
      end

      private

      attr_accessor :options, :profile_locations

      # @param options [::Hash] options for execution.
      # @param profile_locations [::Array<::String>] the locations of the InSpec profiles which contain the controls to
      #   be executed.
      def initialize(options:, profile_locations:)
        self.options = options
        self.profile_locations = profile_locations
      end
    end
  end
end
