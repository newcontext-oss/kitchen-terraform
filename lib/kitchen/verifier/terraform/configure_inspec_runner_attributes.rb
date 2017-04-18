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

require "kitchen/verifier/terraform"

module Kitchen
  module Verifier
    class Terraform < ::Kitchen::Verifier::Inspec
      ConfigureInspecRunnerAttributes = lambda do |client:, config:, group:, terraform_state:|
        {"terraform_state" => terraform_state}.tap do |attributes|
          client.each_output_name do |output_name| attributes.store output_name, client.output(name: output_name) end
          group.fetch(:attributes, {}).each_pair do |attribute_name, output_name|
            attributes.store attribute_name.to_s, client.output(name: output_name)
          end
          config.store :attributes, attributes
        end
      end
    end
  end
end
