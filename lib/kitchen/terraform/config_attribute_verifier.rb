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

require "kitchen"
require "kitchen/terraform"

# Verifies the schema of a configuration attribute.
module ::Kitchen::Terraform::ConfigAttributeVerifier
  # @see http://dry-rb.org/gems/dry-validation/basics/ DRY Validation Basics
  def verify_config(attribute:, schema:)
    required_config attribute do |_attribute, value, _plugin|
      process_config(
        attribute: attribute,
        messages:
          schema
            .call(value: value)
            .messages
      )
    end
  end

  private

  # @api private
  def process_config(attribute:, messages:)
    messages.empty? or
      raise(
        ::Kitchen::UserError,
        "#{self} configuration: #{attribute} #{messages}"
      )
  end
end
