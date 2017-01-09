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
  # Behaviour for the [:plan] and [:state] config options
  module FileConfigs
    def self.extended(configurable_class)
      configurable_class.configure_files
    end

    def configure_files
      { plan: 'terraform.tfplan', state: 'terraform.tfstate' }
        .each_pair do |attr, filename|
          configure_file attr: attr, filename: filename
        end
      expand_path_for attr
    end

    private

    def configure_file(attr:, filename:)
      default_config attr do |configurable|
        configurable.instance_pathname filename: filename
      end
    end
  end
end
