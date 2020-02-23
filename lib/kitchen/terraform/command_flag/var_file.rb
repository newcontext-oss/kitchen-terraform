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
      # VarFile is the class of objects which control the locations of configuration variables files.
      class VarFile
        # #initialize prepares an instance of the class.
        #
        # @param pathnames [Array[String]] the pathnames.
        def initialize(pathnames:)
          self.pathnames = pathnames
        end

        # @return [String] the backend configuration flag.
        def to_s
          pathnames.map do |path|
            "-var-file=\"#{::Shellwords.shelljoin ::Shellwords.shellsplit path}\""
          end.join " "
        end

        private

        attr_accessor :pathnames
      end
    end
  end
end
