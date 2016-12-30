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

require 'hashie/extensions/coercion'
require 'hashie/hash'

module Terraform
  # InSpec attributes of a group
  class GroupAttributes < ::Hashie::Hash
    include ::Hashie::Extensions::Coercion

    coerce_value ::Object, ::String

    def self.coerce(hash)
      self[hash]
    end

    def resolve(resolver:)
      dup.each_pair do |key, value|
        resolver.resolve attributes: self, key: key, value: value
      end
    end
  end
end
