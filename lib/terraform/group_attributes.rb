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

    def self.coerce(config_value)
      self[config_value]
    end

    def resolve(client:)
      client.each_output_name { |name| soft_store key: name, value: name }
      dup.each_pair { |key, value| store key, client.output(name: value) }
    end

    private

    def soft_store(key:, value:)
      fetch(key) { store key, value }
    end
  end
end
