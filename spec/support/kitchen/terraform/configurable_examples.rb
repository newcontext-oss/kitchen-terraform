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

require "kitchen"
require "kitchen/driver/terraform"

::RSpec
  .shared_examples "Kitchen::Terraform::Configurable" do
    describe "@api_version" do
      subject do
        described_class.instance_variable_get :@api_version
      end

      it do
        is_expected.to eq 2
      end
    end

    describe "@plugin_version" do
      subject do
        described_class.instance_variable_get :@plugin_version
      end

      it "equals the gem version" do
        is_expected.to eq "3.3.1"
      end
    end

    describe "#finalize_config" do
      context "when the instance is undefined" do
        subject do
          lambda do
            described_instance.finalize_config! nil
          end
        end

        it do
          is_expected
            .to(
              raise_error(
                ::Kitchen::ClientError,
                "Instance must be provided to #{described_instance}"
              )
            )
        end
      end

      context "when the instance is defined" do
        after do
          described_instance.finalize_config! instance_double ::Object
        end

        subject do
          described_instance
        end

        it do
          is_expected.to receive(:validate_config!).ordered
          is_expected.to receive(:expand_paths!).ordered
          is_expected.to receive(:load_needed_dependencies!).ordered
        end
      end
    end
  end
