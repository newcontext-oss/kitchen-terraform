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

::RSpec.shared_examples 'control is yielded' do
  subject do lambda do |block| described_instance.send described_method, &block end end

  it('does yield control') { is_expected.to yield_control }
end

::RSpec.shared_examples 'control is not yielded' do
  subject do lambda do |block| described_instance.send described_method, &block end end

  it('does not yield control') { is_expected.to_not yield_control }
end
