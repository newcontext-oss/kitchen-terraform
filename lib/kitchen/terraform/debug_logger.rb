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

require "delegate"

module Kitchen
  module Terraform
    # This class delegates to a logger but ensures the debug level is the default level used for logging messages.
    class DebugLogger < ::SimpleDelegator
      # This method overrides the #<< method of the delegate to call #debug.
      #
      # @param message [#to_s] the message to be logged.
      # @return [nil, true] if the given severity is high enough for this particular logger then return
      #   <code>nil</code>; else return <code>true</code>.
      def <<(message)
        debug message
      end
    end
  end
end
