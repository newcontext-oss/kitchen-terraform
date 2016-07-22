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

require 'inspec'

module Terraform
  # Inspec::Runner with convenience methods for use by
  # Kitchen::Verifier::Terraform
  class InspecRunner < Inspec::Runner
    attr_reader :conf

    def add(targets:)
      targets.each { |target| add_target target, conf }
    end

    def define_attribute(name:, value:)
      conf.fetch('attributes').store name.to_s, value
    end

    def verify_run(verifier:)
      verifier.evaluate exit_code: run
    end

    private

    def initialize(conf = {})
      super
      yield self if block_given?
    end
  end
end
