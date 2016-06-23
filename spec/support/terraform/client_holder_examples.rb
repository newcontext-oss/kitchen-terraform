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

require 'terraform/client_holder'

RSpec.shared_examples Terraform::ClientHolder do
  describe '#client' do
    let(:instance) { instance_double Kitchen::Instance }

    before do
      allow(described_instance).to receive(:instance).with(no_args)
        .and_return instance

      allow(instance).to receive(:name).with no_args

      allow(instance).to receive(:provisioner).with no_args
    end

    subject { described_instance.client }

    it('is a Terraform client') { is_expected.to be_kind_of Terraform::Client }
  end
end
