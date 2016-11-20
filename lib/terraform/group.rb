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

require 'forwardable'
require 'hashie/dash'
require 'hashie/extensions/dash/coercion'
require 'set'
require 'terraform/group_attributes'

module Terraform
  # Group of Terraform server instances to be verified
  class Group < ::Hashie::Dash
    extend ::Forwardable

    include ::Hashie::Extensions::Dash::Coercion

    def_delegator :attributes, :resolve, :resolve_attributes

    property :attributes, coerce: ::Terraform::GroupAttributes,
                          default: ::Terraform::GroupAttributes.new

    property :controls, coerce: ::Array[::String], default: []

    property :hostname, coerce: ::String

    property :hostnames, coerce: ::String, default: ''

    property :name, coerce: ::String, required: true

    property :port

    coerce_key :port, ->(value) { Integer value }

    property :username, coerce: ::String

    def if_local
      yield if hostnames.empty?
    end

    def resolve_hostnames(resolver:)
      resolver.resolve group: self, hostnames: hostnames
    end

    def store_hostname(value:)
      resolved_hostnames.add value
    end

    def with_each_hostname
      resolved_hostnames.each do |hostname|
        self[:hostname] = hostname
        yield self
      end
    end

    private

    def resolved_hostnames
      @resolved_hostnames ||= ::Set.new
    end
  end
end
