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
require "thread"

::RSpec
  .describe ::Kitchen::Terraform::Deprecating::KitchenInstance do
    describe ".===(version)" do
      context "when the version is less than 4.0.0" do
        specify do
          expect(described_class.===(::Kitchen::Terraform::Version.new(version: "3.4.5"))).to be true
        end
      end

      context "when the version is equal to 4.0.0" do
        specify do
          expect(described_class.===(::Kitchen::Terraform::Version.new(version: "4.0.0"))).to be false
        end
      end

      context "when the version is greater than 4.0.0" do
        specify do
          expect(described_class.===(::Kitchen::Terraform::Version.new(version: "5.6.7"))).to be false
        end
      end
    end

    describe "#synchronize_or_call(action, state)" do
      subject do
        described_class.new instance
      end

      include_context "Kitchen::Instance"

      let :state do
        {}
      end

      shared_examples "no warning is issued" do
        after do
          subject
            .synchronize_or_call(
              action,
              state,
              &proc do
              end
            )
        end

        specify do
          expect(subject).to_not receive :warn
        end
      end

      shared_examples "a warning is issued about deprecating concurrency when concurrency is activated" do
        context "when there is one thread" do
          it_behaves_like "no warning is issued"
        end

        context "when there is more than one thread" do
          let :thread do
            ::Thread
              .new do
                ::Thread.stop
              end
          end

          before do
            sleep 0.1 while thread.status != "sleep"
          end

          after do
            subject
              .synchronize_or_call(
                action,
                state,
                &proc do
                end
              )

            thread.run
            thread.join
          end

          specify "should warn about deprecating concurrency" do
            expect(subject)
              .to(
                receive(:warn)
                  .with(
                    "DEPRECATING: <suite-platform> is about to invoke Kitchen::Driver::Terraform##{action} with " \
                      "concurrency activated; this action will be forced to run serially as of Kitchen-Terraform v4.0.0"
                  )
              )
          end
        end
      end

      shared_examples "the action is called" do
        specify do
          expect do |block|
            subject
              .synchronize_or_call(
                :action,
                state,
                &block
              )
          end
            .to yield_with_args state
        end
      end

      context "when the `action` is :create" do
        let :action do
          :create
        end

        it_behaves_like "a warning is issued about deprecating concurrency when concurrency is activated"
        it_behaves_like "the action is called"
      end

      context "when the `action` is :converge" do
        let :action do
          :converge
        end

        it_behaves_like "a warning is issued about deprecating concurrency when concurrency is activated"
        it_behaves_like "the action is called"
      end

      context "when the `action` is :setup" do
        let :action do
          :setup
        end

        it_behaves_like "a warning is issued about deprecating concurrency when concurrency is activated"
        it_behaves_like "the action is called"
      end

      context "when the `action` is :verify" do
        let :action do
          :verify
        end

        it_behaves_like "no warning is issued"
        it_behaves_like "the action is called"
      end

      context "when the `action` is :destroy" do
        let :action do
          :destroy
        end

        it_behaves_like "a warning is issued about deprecating concurrency when concurrency is activated"
        it_behaves_like "the action is called"
      end
    end
  end
