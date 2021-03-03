# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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

require "inspec"
require "kitchen"
require "kitchen/terraform/inspec_runner"

::RSpec.describe ::Kitchen::Terraform::InSpecRunner do
  let :logger do
    ::Kitchen::Logger.new
  end

  describe ".logger=" do
    before do
      described_class.logger = logger
    end

    specify "should extend the logger interface to be compatible with InSpec" do
      expect(logger.logdev.filename).to be false
    end

    specify "should set the Inspec logger" do
      expect(::Inspec::Log.logger).to be logger
    end
  end

  describe "#exec" do
    subject do
      described_class.new options: options, profile_locations: [profile_location]
    end

    let :full_options do
      { key: "value", logger: logger }
    end

    let :loader do
      instance_double ::Inspec::Plugin::V2::Loader
    end

    let :options do
      { key: "value" }
    end

    let :profile_location do
      "./profile"
    end

    let :runner do
      instance_double ::Inspec::Runner
    end

    before do
      allow(::Inspec::Plugin::V2::Loader).to receive(:new).and_return loader
      allow(loader).to receive :load_all
      allow(loader).to receive :exit_on_load_error
      allow(::Inspec::Runner).to receive(:new).with(full_options).and_return runner
      allow(runner).to receive(:add_target).with profile_location
      described_class.logger = logger
    end

    context "when the InSpec runner raises an error and a host is not targeted" do
      before do
        allow(runner).to receive(:run).and_raise "failure"
      end

      specify "should raise a transient failure error" do
        expect do
          subject.exec
        end.to raise_error ::Kitchen::TransientFailure, /Running InSpec failed/
      end
    end

    context "when the InSpec runner raises an error and a host is targeted" do
      let :full_options do
        { host: "test", key: "value", logger: logger }
      end

      let :options do
        { host: "test", key: "value" }
      end

      before do
        allow(runner).to receive(:run).and_raise "failure"
      end

      specify "should raise a transient failure error which names the host" do
        expect do
          subject.exec
        end.to raise_error ::Kitchen::TransientFailure, /Running InSpec against the 'test' host failed/
      end
    end

    context "when the InSpec runner returns a non-zero exit code" do
      before do
        allow(runner).to receive(:run).and_return 1
      end

      specify "should raise a transient failure error" do
        expect do
          subject.exec
        end.to raise_error ::Kitchen::TransientFailure
      end
    end

    context "when the InSpec runner returns a zero exit code" do
      before do
        allow(runner).to receive(:run).and_return 0
      end

      specify "should not raise an error" do
        expect do
          subject.exec
        end.not_to raise_error
      end
    end
  end
end
