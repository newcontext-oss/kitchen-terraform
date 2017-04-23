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
require "kitchen/driver/terraform"
require "kitchen/provisioner/terraform"
require "kitchen/verifier/terraform"
require "support/kitchen/instance_context"
require "terraform/configurable"

::RSpec.shared_context "client" do |client_type: :client|
  let client_type do instance_double ::Terraform::Client end

  before do allow(described_instance).to receive(client_type).with(no_args).and_return send client_type end
end

::RSpec.shared_context "instance" do include_context ::Kitchen::Instance do before do instance end end end

::RSpec.shared_context "silent_client" do include_context "client", client_type: :silent_client end
