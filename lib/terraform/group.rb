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

require 'hashie/dash'
require 'hashie/extensions/dash/coercion'
require 'terraform/group_attributes'
require 'terraform/group_hostnames'

module Terraform
  # Group of Terraform server instances to be verified
  class Group < ::Hashie::Dash
    include ::Hashie::Extensions::Dash::Coercion

    property :attributes, coerce: ::Terraform::GroupAttributes,
                          default: ::Terraform::GroupAttributes.new

    property :controls, coerce: ::Array[::String], default: []

    property :hostname, coerce: ::String

    property :hostnames, coerce: ::Terraform::GroupHostnames,
                         default: ::Terraform::GroupHostnames.new

    property :name, coerce: ::String, required: true

    property :port

    coerce_key :port, ->(value) { Integer value }

    property :username, coerce: ::String

    def description
      "host '#{hostname}' of group '#{name}'"
    end

    def resolve(client:)
      attributes.resolve client: client
      hostnames
        .resolve(client: client) { |hostname| yield merge hostname: hostname }
    end

    private

    def initialize(attributes = {}, &block)
      super Hash(attributes), &block
    end
  end
end
