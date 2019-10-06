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
require "kitchen/terraform/inspec"

module Kitchen
  module Terraform
    # InSpec instances act as interfaces to the InSpec gem.
    class InSpecWithHosts
      # exec executes the InSpec controls of an InSpec profile.
      #
      # @raise [::Kitchen::TransientFailure] if the InSpec Runner exits with a non-zero exit code.
      # @raise [::Kitchen::ClientError] if the execution of the InSpec controls fails.
      # @return [void]
      def exec(system:)
        system.each_host do |host:|
          ::Kitchen::Terraform::InSpec
            .new(options: options.merge(host: host), profile_locations: profile_locations)
            .info(message: "#{system}: Verifying host #{host}").exec
        end
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
