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

require "kitchen/terraform/config_attribute_type/integer"

# This attribute controls the number of seconds that Terraform will wait for a lock on the state to be obtained during
# {https://www.terraform.io/docs/state/locking.html operations related to state}.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2803828 Integer}
# Required:: False
# Default:: +0+
# Example:: <code>lock_timeout: 10</code>
::Kitchen::Terraform::ConfigAttribute::LockTimeout =
  ::Kitchen::Terraform::ConfigAttributeType::Integer
    .create(
      attribute: :lock_timeout,
      default_value: 0
    )
