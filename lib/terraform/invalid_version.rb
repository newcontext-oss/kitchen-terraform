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

require_relative 'error'

module Terraform
  # Error of an invalid Terraform version
  class InvalidVersion < Error
    def message
      "Terraform version must match #{supported_version}"
    end

    private

    attr_accessor :supported_version

    def initialize(supported_version)
      self.supported_version = supported_version
    end
  end
end
