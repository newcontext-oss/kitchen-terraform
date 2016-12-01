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

require 'kitchen/util'

module Terraform
  # Group of Terraform server instances to be verified
  class Group
    def each_attribute(&block)
      data[:attributes].dup.each_pair(&block)
    end

    def hostnames
      data[:hostnames]
    end

    def if_local
      yield if hostnames.empty?
    end

    def name
      data[:name]
    end

    def options
      {
        attributes: attributes, controls: data[:controls], port: data[:port],
        user: data[:username]
      }
    end

    def store_attribute(key:, value:)
      data[:attributes][key] = value
    end

    private

    attr_accessor :data

    def attributes
      ::Kitchen::Util.stringified_hash data[:attributes]
    end

    def initialize(data:)
      self.data = data
    end
  end
end
