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

require "terraform/prepare_output_file"

::RSpec.describe ::Terraform::PrepareOutputFile do
  let :described_instance do described_class.new file: file end

  let :file do instance_double ::Pathname end

  let :parent_directory do instance_double ::Pathname end

  before do allow(file).to receive(:parent).with(no_args).and_return parent_directory end

  describe "#execute" do
    before do
      allow(parent_directory).to receive(:mkpath).with no_args

      allow(file).to receive(:open).with "a"
    end

    after do described_instance.execute end

    context "the parent directory" do
      subject do parent_directory end

      it "is created" do is_expected.to receive(:mkpath).with no_args end
    end

    context "the output file" do
      subject do file end

      it "is ensured to be writable" do is_expected.to receive(:open).with "a" end
    end
  end
end
