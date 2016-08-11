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

require_relative 'user_error'

module Terraform
  # Group to be verified
  class Group
    attr_reader :controls, :hostnames, :name, :port, :username

    def each_attribute_pair(&block)
      attributes.each_pair(&block)
    end

    def to_s
      name
    end

    private

    attr_accessor :attributes

    attr_writer :controls, :hostnames, :name, :port, :username

    def initialize(
      attributes: {}, controls: [], hostnames:, name:, port: nil, transport:,
      username: nil
    )
      self.attributes = Hash attributes
      self.controls = Array controls
      self.hostnames = String hostnames
      self.name = String name
      self.port = Integer port || transport[:port]
      self.username = String username || transport[:username]
      yield self if block_given?
    end
  end
end
