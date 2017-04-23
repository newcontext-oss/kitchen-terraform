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

require 'support/terraform/config_default_value_examples'
require 'support/terraform/simple_config_examples'
require 'terraform/groups_config'

::RSpec.shared_examples ::Terraform::GroupsConfig do
  it_behaves_like ::Terraform::SimpleConfig

  it_behaves_like 'a default value is set', attr: :groups, value: []
end
