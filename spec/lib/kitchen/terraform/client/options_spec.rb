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
  shared_examples "a bulk mapper" do |method:, key:|
    it do
      expect(
        subject
          .send(
            method,
            keys_and_values: {
              key_1: "value_1",
              key_2: "value_2"
            }
          )
          .to_s
      )
        .to eq "#{key}='key_1=value_1' #{key}='key_2=value_2'"
    end
  end

  describe "#backend_config" do
    it do
      expect(
        subject
          .backend_config(
            key: "key",
            value: "value"
          )
          .to_s
      )
        .to eq "-backend-config='key=value'"
    end
  end

  describe "#backend_configs" do
    it_behaves_like(
      "a bulk mapper",
      method: :backend_configs,
      key: "-backend-config"
    )
  end

  describe "#backup" do
    it do
      expect(
        subject
          .backup(path: "/path")
          .to_s
      )
        .to eq "-backup=/path"
    end
  end

  describe "#disable_input" do
    it do
      expect(
        subject
          .disable_input
          .to_s
      )
        .to eq "-input=false"
    end
  end

  describe "#enable_auto_approve" do
    it do
      expect(
        subject
        .enable_auto_approve
        .to_s
      )
        .to eq "-auto-approve=true"
    end
  end

  describe "#enable_backend" do
    it do
      expect(
        subject
          .enable_backend
          .to_s
      )
        .to eq "-backend=true"
    end
  end

  describe "#enable_check_variables" do
    it do
      expect(
        subject
        .enable_check_variables
        .to_s
      )
        .to eq "-check-variables=true"
    end
  end

  describe "#enable_get" do
    it do
      expect(
        subject
          .enable_get
          .to_s
      )
        .to eq "-get=true"
    end
  end

  describe "#enable_lock" do
    it do
      expect(
        subject
          .enable_lock
          .to_s
      )
        .to eq "-lock=true"
    end
  end

  describe "#enable_refresh" do
    it do
      expect(
        subject
          .enable_refresh
          .to_s
      )
        .to eq "-refresh=true"
    end
  end

  describe "#force" do
    it do
      expect(
        subject
          .force
          .to_s
      )
        .to eq "-force"
    end
  end

  describe "#force_copy" do
    it do
      expect(
        subject
          .force_copy
          .to_s
      )
        .to eq "-force-copy"
    end
  end

  describe "#from_module" do
    it do
      expect(
        subject
          .from_module(source: "/source")
          .to_s
      )
        .to eq "-from-module=/source"
    end
  end

  describe "#json" do
    it do
      expect(
        subject
          .json
          .to_s
      )
        .to eq "-json"
    end
  end

  describe "#lock_timeout" do
    it do
      expect(
        subject
          .lock_timeout(duration: "1m")
          .to_s
      )
        .to eq "-lock-timeout=1m"
    end
  end

  describe "#maybe_no_color" do
    context "when the toggle is truthy" do
      it do
        expect(
          subject
            .maybe_no_color(toggle: true)
            .to_s
        )
          .to eq "-no-color"
      end
    end

    context "when the toggle is falsey" do
      it do
        expect(
          subject
            .maybe_no_color(toggle: false)
            .to_s
        )
          .to eq ""
      end
    end
  end

  describe "#maybe_plugin_dir" do
    context "when the path is truthy" do
      it do
        expect(
          subject
            .maybe_plugin_dir(path: "/path")
            .to_s
        )
          .to eq "-plugin-dir=/path"
      end
    end

    context "when the path is falsey" do
      it do
        expect(
          subject
            .maybe_plugin_dir(path: nil)
            .to_s
        )
          .to eq ""
      end
    end
  end

  describe "#no_color" do
    it do
      expect(
        subject
          .no_color
          .to_s
      )
        .to eq "-no-color"
    end
  end

  describe "#parallelism" do
    it do
      expect(
        subject
          .parallelism(concurrent_operations: 123)
          .to_s
      )
        .to eq "-parallelism=123"
    end
  end

  describe "#plugin_dir" do
    it do
      expect(
        subject
          .plugin_dir(path: "/path")
          .to_s
      )
        .to eq "-plugin-dir=/path"
    end
  end

  describe "#state" do
    it do
      expect(
        subject
          .state(path: "/path")
          .to_s
      )
        .to eq "-state=/path"
    end
  end

  describe "#state_out" do
    it do
      expect(
        subject
          .state_out(path: "/path")
          .to_s
      )
        .to eq "-state-out=/path"
    end
  end

  describe "#upgrade" do
    it do
      expect(
        subject
          .upgrade
          .to_s
      )
        .to eq "-upgrade"
    end
  end

  describe "#var" do
    it do
      expect(
        subject
          .var(
            key: "key",
            value: "value"
          )
          .to_s
      )
        .to eq "-var='key=value'"
    end
  end

  describe "#vars" do
    it_behaves_like(
      "a bulk mapper",
      key: "-var",
      method: :vars
    )
  end

  describe "#var_file" do
    it do
      expect(
        subject
          .var_file(path: "/path")
          .to_s
      )
        .to eq "-var-file=/path"
    end
  end

  describe "#var_files" do
    it do
      expect(
        subject
          .var_files(
            paths: [
              "/path_1",
              "/path_2"
            ]
          )
          .to_s
      )
        .to eq "-var-file=/path_1 -var-file=/path_2"
    end
  end

  describe "#verify_plugins" do
    it do
      expect(
        subject
          .verify_plugins(toggle: false)
          .to_s
      )
        .to eq "-verify-plugins=false"
    end
  end
end
