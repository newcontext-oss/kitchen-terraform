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

require 'awspec'

control 'local_security_group' do
  describe 'the security group' do
    let(:example_security_group) { security_group 'kitchen-terraform-example' }

    describe 'ingress' do
      subject { example_security_group.inbound }

      it('is open to the world') { is_expected.to be_opened.for '0.0.0.0/0' }
    end

    describe 'egress' do
      subject { example_security_group.outbound }

      it('is open to the world') { is_expected.to be_opened.for '0.0.0.0/0' }
    end
  end
end
