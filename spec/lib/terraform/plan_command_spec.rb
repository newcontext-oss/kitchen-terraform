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

require "pathname"
require "support/terraform/command_examples"
require "terraform/plan_command"

::RSpec.describe ::Terraform::PlanCommand do
  let :described_instance do described_class.new do |options| options.out = output_file end end

  let :output_file do ::Pathname.new "/output/file" end

  it_behaves_like "#name" do let :name do "plan" end end

  describe "#prepare" do
    let :prepare_output_file do instance_double ::Terraform::PrepareOutputFile end

    before do
      allow(::Terraform::PrepareOutputFile).to receive(:new).with(file: output_file).and_return prepare_output_file
    end

    after do described_instance.prepare end

    subject do prepare_output_file end

    it "prepares the output out file" do is_expected.to receive(:execute).with no_args end
  end
end
