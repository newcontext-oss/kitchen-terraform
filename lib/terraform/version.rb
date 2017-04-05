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

require 'rubygems/version'
require 'terraform/deprecated_version'
require 'terraform/unsupported_version'

module Terraform
  # Version of Terraform
  class Version
    def self.create(value:)
      new(value: value).tap do |version|
        supported.find(&version.method(:==)) or
          return ::Terraform::UnsupportedVersion.new version
        deprecated.find(&version.method(:==)) and
          return ::Terraform::DeprecatedVersion.new version
      end
    end

    def self.deprecated
      [new(value: '0.6')]
    end

    def self.latest
      new value: '0.9'
    end

    def self.supported
      [latest, new(value: '0.8'), new(value: '0.7'), *deprecated]
    end

    def ==(other)
      major_minor == other.major_minor
    end

    alias eql? ==

    def if_deprecated; end

    def if_json_not_supported; end

    def if_not_supported; end

    def major_minor
      value.approximate_recommendation
    end

    def to_s
      "Terraform v#{value}"
    end

    private

    attr_accessor :value, :version

    def initialize(value:)
      self.value = ::Gem::Version.create value.slice(/v?(\d+(\.\d+)*)/, 1)
    end
  end
end
