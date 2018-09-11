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

require "kitchen/terraform/inspec_with_hosts"
require "kitchen/terraform/inspec_without_hosts"

module Kitchen
  module Terraform
    # System is the class of objects which are verified by the Terraform Verifier.
    class System
      # #add_attrs adds attributes to the system.
      #
      # @param attrs [#to_hash] the attributes to be added.
      # @return [self]
      def add_attrs(attrs:)
        @attributes = @attributes.merge Hash attrs

        self
      end

      # #add_hosts adds hosts to the system.
      #
      # @param hosts [#to_arr,#to_a] the hosts to be added.
      # @return [self]
      def add_hosts(hosts:)
        @hosts = @hosts.+ Array hosts

        self
      end

      # #each_host enumerates each host of the system.
      #
      # @yieldparam host [::String] the next host.
      # @return [self]
      def each_host
        @hosts.each do |host|
          yield host: host
        end

        self
      end

      # #resolve_attrs resolves the attributes of the system which are contained in Terraform outputs.
      #
      # @param system_attrs_resolver [::Kitchen::Terraform::SystemAttrsResolver] the resolver.
      # @return [self]
      def resolve_attrs(system_attrs_resolver:)
        system_attrs_resolver.resolve attrs_outputs_keys: @attrs_outputs.keys,
                                      attrs_outputs_values: @attrs_outputs.values, system: self

        self
      end

      # #resolve_hosts resolves the hosts of the system which are contained a Terraform output.
      #
      # @param system_hosts_resolver [::Kitchen::Terraform::SystemHostsResolver] the resolver.
      # @return [self]
      def resolve_hosts(system_hosts_resolver:)
        system_hosts_resolver.resolve(
          hosts_output: @mapping.fetch(:hosts_output) do
            return self
          end,
          system: self,
        )

        self
      end

      # #to_s returns a string representation of the system.
      #
      # @return [::String] the name of the system.
      def to_s
        @mapping.fetch :name
      end

      # #verify verifies the system by executing InSpec.
      #
      # @param inspec_options [::Hash] the options to be passed to InSpec.
      # @param inspec_profile_paths [::Array] the paths to the profiles which InSpec will execute.
      # @return [self]
      def verify(inspec_options:, inspec_profile_paths:)
        if @hosts.empty?
          ::Kitchen::Terraform::InSpecWithoutHosts
        else
          ::Kitchen::Terraform::InSpecWithHosts
        end
          .new(options: inspec_options.merge(attributes: @attributes), profile_paths: inspec_profile_paths)
          .exec(system: self)

        self
      end

      private

      def initialize(mapping:)
        @attributes = {}
        @attrs_outputs = mapping.fetch :attrs_outputs do
          {}
        end
        @hosts = mapping.fetch :hosts do
          []
        end
        @mapping = mapping
      end
    end
  end
end
