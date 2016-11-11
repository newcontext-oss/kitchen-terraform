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

module Terraform
  # Group of Terraform server instances to be verified
  class Group
    def each_attribute(&block)
      data[:attributes].each_pair(&block)
    end

    def evaluate(verifier:)
      verifier.merge options: options
      verifier.resolve_attributes group: self
      verifier.resolve_hostnames group: self do |hostname|
        verifier.info "Verifying host '#{hostname}' of group '#{data[:name]}'"
        verifier.merge options: { host: hostname }
        verifier.execute
      end
    end

    def hostnames
      data[:hostnames]
    end

    def store_output_names(name:)
      output_names.push name
    end

    def merge_attributes
      output_names.each do |k|
        data[:attributes].key?(k) ? next : store_attribute(key: k, value: k)
      end
    end

    def store_attribute(key:, value:)
      data[:attributes][key] = value
    end

    private

    attr_accessor :data, :output_names

    def initialize(data:, output_names: [])
      self.data = data
      self.output_names = output_names
    end

    def options
      {
        attributes: data[:attributes], controls: data[:controls],
        port: data[:port], user: data[:username]
      }
    end
  end
end
