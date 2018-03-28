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

require "kitchen/terraform/deprecating/kitchen_instance"
require "kitchen/terraform/version"
require "support/kitchen/instance_context"

::RSpec
  .describe ::Kitchen::Terraform::Deprecating::KitchenInstance do
    describe "#synchronize_or_call" do
      subject do
        described_class.new instance
      end

      include_context "Kitchen::Instance"

      let :state do
        {}
      end

      def call_method(&block)
        block ||=
          proc do
          end

        subject
          .send(
            :synchronize_or_call,
            action,
            state,
            &block
          )
      end

      shared_context "wait for thread to sleep" do
        before do
          sleep 0.1 while thread.status != "sleep"
        end
      end

      shared_context "wait for thread to finish" do
        after do
          call_method
          thread.run
          thread.join
        end
      end

      shared_context "when concurrency is not activated" do
        after do
          call_method
        end
      end

      shared_context "when concurrency is activated" do
        include_context "wait for thread to sleep"
        include_context "wait for thread to finish"

        let :thread do
          ::Thread
            .new do
              ::Thread.stop
            end
        end
      end

      shared_examples "no warning is issued" do
        specify do
          expect(subject).to_not receive :warn
        end
      end

      shared_examples "no warning is issued when concurrency is not activated" do
        include_context "when concurrency is not activated"
        it_behaves_like "no warning is issued"
      end

      shared_examples "no warning is issued when concurrency is activated" do
        include_context "when concurrency is activated"
        it_behaves_like "no warning is issued"
      end

      shared_examples "a warning is issued when concurrency is activated" do
        include_context "when concurrency is activated"

        specify "should warn about deprecating concurrency" do
          expect(subject)
            .to(
              receive(:warn)
                .with(
                  "DEPRECATING: <suite-platform> is about to invoke Kitchen::Driver::Terraform##{action} with " \
                    "concurrency activated; this action will be forced to run serially in an upcoming major version " \
                    "of Kitchen-Terraform"
                )
            )
        end
      end

      shared_examples "the action is called" do
        specify do
          expect do |block|
            call_method &block
          end
            .to yield_with_args state
        end
      end

      context "when the `action` is :create" do
        let :action do
          :create
        end

        it_behaves_like "no warning is issued when concurrency is not activated"
        it_behaves_like "a warning is issued when concurrency is activated"
        it_behaves_like "the action is called"
      end

      context "when the `action` is :converge" do
        let :action do
          :converge
        end

        it_behaves_like "no warning is issued when concurrency is not activated"
        it_behaves_like "a warning is issued when concurrency is activated"
        it_behaves_like "the action is called"
      end

      context "when the `action` is :setup" do
        let :action do
          :setup
        end

        it_behaves_like "no warning is issued when concurrency is not activated"
        it_behaves_like "a warning is issued when concurrency is activated"
        it_behaves_like "the action is called"
      end

      context "when the `action` is :verify" do
        let :action do
          :verify
        end

        it_behaves_like "no warning is issued when concurrency is not activated"
        it_behaves_like "no warning is issued when concurrency is activated"
        it_behaves_like "the action is called"
      end

      context "when the `action` is :destroy" do
        let :action do
          :destroy
        end

        it_behaves_like "no warning is issued when concurrency is not activated"
        it_behaves_like "a warning is issued when concurrency is activated"
        it_behaves_like "the action is called"
      end
    end
  end
