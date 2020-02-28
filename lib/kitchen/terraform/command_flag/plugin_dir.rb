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

require "shellwords"

module Kitchen
  module Terraform
    module CommandFlag
      # PluginDir is the class of objects which control the location of the directory which contains plugin binaries.
      class PluginDir
        # #initialize prepares a new instance of the class.
        #
        # @param pathname [String] the pathname of the directory.
        # @return [Kitchen::Terraform::CommandFlag::PluginDir]
        def initialize(pathname:)
          self.pathname = pathname.to_s
        end

        # @return [String] the plugin directory flag.
        def to_s
          if pathname.empty?
            ""
          else
            "-plugin-dir=\"#{::Shellwords.shelljoin ::Shellwords.shellsplit pathname}\""
          end
        end

        private

        attr_accessor :pathname
      end
    end
  end
end
