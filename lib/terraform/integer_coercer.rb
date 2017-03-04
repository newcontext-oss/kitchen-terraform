# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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

require 'terraform/simple_coercer'

module Terraform
  # A coercer for config values that must be integers
  class IntegerCoercer
    def coerce(attr:, value:)
      coercer.coerce attr: attr, value: value
    end

    private

    attr_accessor :coercer

    def initialize(configurable:)
      self.coercer =
        ::Terraform::SimpleCoercer.new configurable: configurable,
                                       expected: 'an integer',
                                       method: method(:Integer)
    end
  end
end
