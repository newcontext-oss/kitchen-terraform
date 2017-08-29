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

require "kitchen/terraform/client/options"

::RSpec.describe ::Kitchen::Terraform::Client::Options do
  let :described_instance do
    described_class.new
  end

  describe ".backend_config" do
    subject do
      described_instance
        .backend_config(
          key: "key",
          value: "value"
        )
        .to_s
    end

    it do
      is_expected.to eq "-backend-config='key=value'"
    end
  end

  describe ".backend_configs" do
    subject do
      described_instance
        .backend_configs(
          keys_and_values: {
            key_1: :value_1,
            key_2: :value_2
          }
        )
        .to_s
    end

    it do
      is_expected.to eq "-backend-config='key_1=value_1' -backend-config='key_2=value_2'"
    end
  end

  describe ".backup" do
    subject do
      described_instance
        .backup(path: "/path")
        .to_s
    end

    it do
      is_expected.to eq "-backup=/path"
    end
  end

  describe ".disable_input" do
    subject do
      described_instance
        .disable_input
        .to_s
    end

    it do
      is_expected.to eq "-input=false"
    end
  end

  describe ".disable_verify_plugins" do
    subject do
      described_instance
        .disable_verify_plugins
        .to_s
    end

    it do
      is_expected.to eq "-verify-plugins=false"
    end
  end

  describe ".enable_auto_approve" do
    subject do
      described_instance
        .enable_auto_approve
        .to_s
    end

    it do
      is_expected.to eq "-auto-approve=true"
    end
  end

  describe ".enable_backend" do
    subject do
      described_instance
        .enable_backend
        .to_s
    end

    it do
      is_expected.to eq "-backend=true"
    end
  end

  describe ".enable_check_variables" do
    subject do
      described_instance
        .enable_check_variables
        .to_s
    end

    it do
      is_expected.to eq "-check-variables=true"
    end
  end

  describe ".enable_get" do
    subject do
      described_instance
        .enable_get
        .to_s
    end

    it do
      is_expected.to eq "-get=true"
    end
  end

  describe ".enable_lock" do
    subject do
      described_instance
        .enable_lock
        .to_s
    end

    it do
      is_expected.to eq "-lock=true"
    end
  end

  describe ".enable_refresh" do
    subject do
      described_instance
        .enable_refresh
        .to_s
    end

    it do
      is_expected.to eq "-refresh=true"
    end
  end

  describe ".force" do
    subject do
      described_instance
        .force
        .to_s
    end

    it do
      is_expected.to eq "-force"
    end
  end

  describe ".force_copy" do
    subject do
      described_instance
        .force_copy
        .to_s
    end

    it do
      is_expected.to eq "-force-copy"
    end
  end

  describe ".from_module" do
    subject do
      described_instance
        .from_module(source: "/source")
        .to_s
    end

    it do
      is_expected.to eq "-from-module=/source"
    end
  end

  describe ".json" do
    subject do
      described_instance
        .json
        .to_s
    end

    it do
      is_expected.to eq "-json"
    end
  end

  describe ".lock_timeout" do
    subject do
      described_instance
        .lock_timeout(duration: "1m")
        .to_s
    end

    it do
      is_expected.to eq "-lock-timeout=1m"
    end
  end

  describe ".maybe_no_color" do
    subject do
      described_instance
        .maybe_no_color(toggle: toggle)
        .to_s
    end

    context "when the toggle is truthy" do
      let :toggle do
        true
      end

      it do
        is_expected.to eq "-no-color"
      end
    end

    context "when the toggle is falsey" do
      let :toggle do
        false
      end

      it do
        is_expected.to eq ""
      end
    end
  end

  describe ".maybe_plugin_dir" do
    subject do
      described_instance
        .maybe_plugin_dir(path: path)
        .to_s
    end

    context "when the path is truthy" do
      let :path do
        "/path"
      end

      it do
        is_expected.to eq "-plugin-dir=/path"
      end
    end

    context "when the path is falsey" do
      let :path do
        nil
      end

      it do
        is_expected.to eq ""
      end
    end
  end

  describe ".no_color" do
    subject do
      described_instance
        .no_color
        .to_s
    end

    it do
      is_expected.to eq "-no-color"
    end
  end

  describe ".parallelism" do
    subject do
      described_instance
        .parallelism(concurrent_operations: 123)
        .to_s
    end

    it do
      is_expected.to eq "-parallelism=123"
    end
  end

  describe ".plugin_dir" do
    subject do
      described_instance
        .plugin_dir(path: "/path")
        .to_s
    end

    it do
      is_expected.to eq "-plugin-dir=/path"
    end
  end

  describe ".state" do
    subject do
      described_instance
        .state(path: "/path")
        .to_s
    end

    it do
      is_expected.to eq "-state=/path"
    end
  end

  describe ".state_out" do
    subject do
      described_instance
        .state_out(path: "/path")
        .to_s
    end

    it do
      is_expected.to eq "-state-out=/path"
    end
  end

  describe ".upgrade" do
    subject do
      described_instance
        .upgrade
        .to_s
    end

    it do
      is_expected.to eq "-upgrade"
    end
  end

  describe ".var" do
    subject do
      described_instance
        .var(
          key: "key",
          value: "value"
        )
        .to_s
    end

    it do
      is_expected.to eq "-var='key=value'"
    end
  end

  describe ".vars" do
    subject do
      described_instance
        .vars(
          keys_and_values: {
            key_1: :value_1,
            key_2: :value_2
          }
        )
        .to_s
    end

    it do
      is_expected.to eq "-var='key_1=value_1' -var='key_2=value_2'"
    end
  end

  describe ".var_file" do
    subject do
      described_instance
        .var_file(path: "/path")
        .to_s
    end

    it do
      is_expected.to eq "-var-file=/path"
    end
  end

  describe ".var_files" do
    subject do
      described_instance
        .var_files(
          paths: [
            "/path_1",
            "/path_2"
          ]
        )
        .to_s
    end

    it do
      is_expected.to eq "-var-file=/path_1 -var-file=/path_2"
    end
  end
end
