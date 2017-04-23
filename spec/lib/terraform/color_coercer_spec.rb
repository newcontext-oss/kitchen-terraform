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

require 'support/raise_error_examples'
require 'support/terraform/configurable_context'
require 'terraform/color_coercer'

::RSpec.describe ::Terraform::ColorCoercer do
  include_context 'instance'

  let(:described_instance) { described_class.new configurable: provisioner }

  describe '#coerce' do
    context 'when the value is a boolean' do
      before { described_instance.coerce attr: :color, value: true }

      subject { provisioner[:color] }

      it('uses the value') { is_expected.to be true }
    end

    context 'when the value is not a boolean' do
      it_behaves_like 'a user error has occurred' do
        let :described_method do
          described_instance.coerce attr: :color, value: 'true'
        end

        let(:message) { /.*:color.*a boolean/ }
      end
    end
  end
end
