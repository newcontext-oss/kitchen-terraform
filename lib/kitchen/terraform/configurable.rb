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

# Refinements to Kitchen::Configurable.
#
# @see https://github.com/test-kitchen/test-kitchen/blob/v1.16.0/lib/kitchen/configurable.rb Kitchen::Configurable
module ::Kitchen::Terraform::Configurable
  # Alternative implementation of Kitchen::Configurable#finalize_config! which validates the configuration before
  # attempting to expand paths.
  #
  # @note this method should be removed when Test Kitchen: Issue #1229 is solved.
  # @param instance [::Kitchen::Instance] an associated instance.
  # @return [self] itself, for use in chaining.
  # @raise [::Kitchen::ClientError] if the instance is nil.
  # @see https://github.com/test-kitchen/test-kitchen/blob/v1.16.0/lib/kitchen/configurable.rb#L46
  #   Kitchen::Configurable#finalize_config!
  # @see https://github.com/test-kitchen/test-kitchen/issues/1229 Test Kitchen: Issue #1229
  def finalize_config!(instance)
    instance or
      raise(
        ::Kitchen::ClientError,
        "Instance must be provided to #{self}"
      )

    @instance = instance
    validate_config!
    expand_paths!
    load_needed_dependencies!

    self
  end
end
