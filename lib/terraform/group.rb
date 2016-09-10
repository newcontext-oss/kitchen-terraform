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

require 'delegate'
require_relative 'inspec_runner'

module Terraform
  # Group to be verified
  class Group < DelegateClass Hash
    def populate(runner:)
      dig(:attributes).each_pair do |key, output_name|
        runner.set_attribute key: key,
                             value: provisioner.output(name: output_name)
      end
    end

    def verify_each_host(options:)
      provisioner.each_list_output name: dig(:hostnames) do |hostname|
        store :host, hostname
        verifier.info "Verifying group: #{dig :name}; current host #{hostname}"
        InspecRunner.run_and_verify group: self, options: options.merge(self),
                                    verifier: verifier
      end
    end

    private

    attr_accessor :provisioner, :transport, :verifier

    def coerce_attributes
      store :attributes, Hash(dig(:attributes))
    rescue ArgumentError, TypeError
      verifier.config_error attribute: "groups][#{self}][:attributes",
                            expected: 'a mapping of Inspec attribute names to ' \
                                       'Terraform output variable names'
    end

    def coerce_controls
      store :controls, Array(dig(:controls))
    end

    def coerce_hostnames
      store :hostnames, String(dig(:hostnames))
    end

    def coerce_name
      store :name, String(dig(:name))
    end

    def coerce_parameters
      coerce_attributes
      coerce_controls
      coerce_hostnames
      coerce_name
      coerce_port
      coerce_username
    end

    def coerce_port
      store :port, Integer(dig(:port) || transport[:port])
    rescue ArgumentError, TypeError
      verifier.config_error attribute: "groups][#{self}][:port",
                            expected: 'an integer'
    end

    def coerce_username
      store :user, String(dig(:username) || transport[:username])
    end

    def initialize(value:, verifier:)
      super Hash value
      self.provisioner = verifier.provisioner
      self.transport = verifier.transport
      self.verifier = verifier
      coerce_parameters
    rescue ArgumentError, TypeError
      verifier.config_error attribute: "groups][#{self}",
                            expected: 'a group mapping'
    end
  end
end
