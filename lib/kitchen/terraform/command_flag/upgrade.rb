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

module Kitchen
  module Terraform
    module CommandFlag
      # Upgrade is the class of objects which control the upgrade of existing modules and plugins.
      class Upgrade
        # #initialize prepares a new instance of the class.
        #
        # @param enabled [Boolean] a toggle to enable or disable the upgrade.
        # @return [Kitchen::Terraform::CommandFlag::Upgrade]
        def initialize(enabled:)
          self.enabled = enabled
        end

        # @return [String] the upgrade flag.
        def to_s
          if enabled
            "-upgrade=true"
          else
            ""
          end
        end

        private

        attr_accessor :enabled
      end
    end
  end
end
