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
    let(:client) { instance_double Object }

    let(:client_class) { class_double(Terraform::Client).as_stubbed_const }

    let(:instance) { instance_double Kitchen::Instance }

    let(:instance_name) { instance_double Object }

    let(:logger) { instance_double Object }

    let(:provisioner) { instance_double Object }

    before do
      allow(described_instance).to receive(:instance).with(no_args)
        .and_return instance

      allow(instance).to receive(:name).with(no_args)
        .and_return instance_name

      allow(described_instance).to receive(:logger).with(no_args)
        .and_return logger

      allow(instance).to receive(:provisioner).with(no_args)
        .and_return provisioner

      allow(client_class).to receive(:new).with(
        instance_name: instance_name, logger: logger, provisioner: provisioner
      ).and_return client
    end

    subject { described_instance.client }

    it('is a Terraform client') { is_expected.to be client }
  end
end
