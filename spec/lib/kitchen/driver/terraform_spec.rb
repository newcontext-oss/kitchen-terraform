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

require "json"
require "kitchen"
require "kitchen/driver/terraform"
require "kitchen/terraform/client_version_verifier"
require "kitchen/terraform/error"
require "kitchen/terraform/shell_out"
require "support/kitchen/terraform/config_attribute/backend_configurations_examples"
require "support/kitchen/terraform/config_attribute/color_examples"
require "support/kitchen/terraform/config_attribute/command_timeout_examples"
require "support/kitchen/terraform/config_attribute/lock_examples"
require "support/kitchen/terraform/config_attribute/lock_timeout_examples"
require "support/kitchen/terraform/config_attribute/parallelism_examples"
require "support/kitchen/terraform/config_attribute/plugin_directory_examples"
require "support/kitchen/terraform/config_attribute/root_module_directory_examples"
require "support/kitchen/terraform/config_attribute/variable_files_examples"
require "support/kitchen/terraform/config_attribute/variables_examples"
require "support/kitchen/terraform/configurable_examples"
require "support/kitchen/terraform/result_in_failure_matcher"
require "support/kitchen/terraform/result_in_success_matcher"

::RSpec
  .describe ::Kitchen::Driver::Terraform do
    let :config do
      {
        backend_configurations: {key: "value"},
        color: false,
        kitchen_root: kitchen_root,
        plugin_directory: "/plugin/directory",
        variable_files: ["/variable/file"],
        variables: {key: "value"}
      }
    end

    let :described_instance do
      described_class.new config
    end

    let :kitchen_instance do
      ::Kitchen::Instance
        .new(
          driver: described_instance,
          logger: kitchen_logger,
          platform: ::Kitchen::Platform.new(name: "test-platform"),
          provisioner: ::Kitchen::Provisioner::Base.new,
          state_file:
            ::Kitchen::StateFile
              .new(
                kitchen_root,
                "test-suite-test-platform"
              ),
          suite: ::Kitchen::Suite.new(name: "test-suite"),
          transport: ::Kitchen::Transport::Base.new,
          verifier: ::Kitchen::Verifier::Base.new
        )
    end

    let :kitchen_logger do
      described_instance.send :logger
    end

    let :kitchen_root do
      "/kitchen/root"
    end

    let :shell_out do
      class_double(::Kitchen::Terraform::ShellOut).as_stubbed_const
    end

    def shell_out_run_failure(command:, message: "mocked `terraform` failure", working_directory: kitchen_root)
      allow(shell_out)
        .to(
          receive(:run)
            .with(
              command: command,
              options:
                {
                  cwd: working_directory,
                  live_stream: kitchen_logger,
                  timeout: 600
                }
            )
            .and_raise(
              ::Kitchen::Terraform::Error,
              message
            )
        )
    end

    def shell_out_run_success(command:, return_value: "mocked `terraform` success", working_directory: kitchen_root)
      allow(shell_out)
        .to(
          receive(:run)
            .with(
              command: command,
              options:
                {
                  cwd: working_directory,
                  live_stream: kitchen_logger,
                  timeout: 600
                }
            )
            .and_return(return_value)
        )
    end

    def shell_out_run_yield(command:, standard_output: "mocked `terraform` success")
      allow(shell_out)
        .to(
          receive(:run)
            .with(
              command: command,
              options:
                {
                  cwd: kitchen_root,
                  live_stream: kitchen_logger,
                  timeout: 600
                }
            )
            .and_yield(standard_output: standard_output)
        )
    end

    shared_examples "the `terraform workspace <kitchen-instance>` subcommand results in success" do
      let :subcommand do
        "select"
      end

      before do
        shell_out_run_success command: "workspace #{subcommand} kitchen-terraform-test-suite-test-platform"
      end

      it do
        is_expected.to_not raise_error
      end
    end

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::BackendConfigurations"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::CommandTimeout"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Color"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Lock"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::LockTimeout"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Parallelism"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::PluginDirectory"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::RootModuleDirectory"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::VariableFiles"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Variables"

    it_behaves_like "Kitchen::Terraform::Configurable"

    describe ".serial_actions" do
      specify "actions are returned" do
        expect(described_class.serial_actions)
          .to(
            contain_exactly(
              :create,
              :converge,
              :setup,
              :destroy
            )
          )
      end
    end

    describe "#apply" do
      subject do
        lambda do |block = lambda do end|
          described_instance.apply &block
        end
      end

      before do
        described_instance.finalize_config! kitchen_instance
      end

      shared_examples "terraform: get; validate; apply; output" do
        context "when `terraform get` results in failure" do
          before do
            shell_out_run_failure(
              command: /get/,
              message: "mocked `terraform get` failure"
            )
          end

          it do
            is_expected.to result_in_failure.with_message "mocked `terraform get` failure"
          end
        end

        context "when `terraform get` results in success" do
          before do
            shell_out_run_success command: "get -update"
          end

          context "when `terraform validate` results in failure" do
            before do
              shell_out_run_failure(
                command: /validate/,
                message: "mocked `terraform validate` failure"
              )
            end

            it do
              is_expected.to result_in_failure.with_message "mocked `terraform validate` failure"
            end
          end

          context "when `terraform validate` results in success" do
            before do
              shell_out_run_success(
                command:
                  "validate " \
                    "-check-variables=true " \
                    "-no-color " \
                    "-var=key\\=value " \
                    "-var-file=\/variable\/file"
              )
            end

            context "when `terraform apply` results in failure" do
              before do
                shell_out_run_failure(
                  command: /apply/,
                  message: "mocked `terraform apply` failure"
                )
              end

              it do
                is_expected.to result_in_failure.with_message "mocked `terraform apply` failure"
              end
            end

            context "when `terraform apply` results in success" do
              before do
                shell_out_run_success(
                  command:
                    "apply " \
                      "-lock=true " \
                      "-lock-timeout=0s " \
                      "-input=false " \
                      "-auto-approve=true " \
                      "-no-color " \
                      "-parallelism=10 " \
                      "-refresh=true " \
                      "-var=key\\=value " \
                      "-var-file=\/variable\/file"
                )
              end

              context "when `terraform output` results in failure due to no outputs defined" do
                before do
                  shell_out_run_failure(
                    command: "output -json",
                    message: "no outputs defined"
                  )
                end

                it do
                  is_expected.to yield_with_args output: {}
                end
              end

              context "when `terraform output` results in failure" do
                before do
                  shell_out_run_failure(
                    command: "output -json",
                    message: "mocked `terraform output` failure"
                  )
                end

                it do
                  is_expected.to result_in_failure.with_message "mocked `terraform output` failure"
                end
              end

              context "when `terraform output` results in success" do
                before do
                  shell_out_run_yield(
                    command: "output -json",
                    standard_output: terraform_output_value
                  )
                end

                context "when the value of the `terraform output` result is not valid JSON" do
                  let :terraform_output_value do
                    "not valid JSON"
                  end

                  it do
                    is_expected.to result_in_failure.with_message /Parsing Terraform output as JSON failed:/
                  end
                end

                context "when the value of the `terraform output` result is valid JSON" do
                  let :terraform_output_value do
                    ::JSON.dump value_as_hash
                  end

                  let :value_as_hash do
                    {
                      output_name: {
                        sensitive: false,
                        type: "list",
                        value: ["output_value_1"]
                      }
                    }
                  end

                  it do
                    is_expected
                      .to(
                        yield_with_args(
                          output:
                            {
                              "output_name" =>
                                {
                                  "sensitive" => false,
                                  "type" => "list",
                                  "value" => ["output_value_1"]
                                }
                            }
                        )
                      )
                  end
                end
              end
            end
          end
        end
      end

      context "when `terraform workspace select <kitchen-instance>` results in failure" do
        before do
          shell_out_run_failure(
            command: "workspace select kitchen-terraform-test-suite-test-platform",
            message: "mocked `terraform workspace select <kitchen-instance>` failure"
          )
        end

        context "when `terraform workspace new <kitchen-instance>` results in failure" do
          before do
            shell_out_run_failure(
              command: "workspace new kitchen-terraform-test-suite-test-platform",
              message: "mocked `terraform workspace new <kitchen-instance>` failure"
            )
          end

          it do
            is_expected
              .to result_in_failure.with_message "mocked `terraform workspace new <kitchen-instance>` failure"
          end
        end

        context "when `terraform workspace new <kitchen-instance>` results in success" do
          before do
            shell_out_run_success command: "workspace new kitchen-terraform-test-suite-test-platform"
          end

          it_behaves_like "terraform: get; validate; apply; output"
        end
      end

      context "when `terraform workspace select <kitchen-instance>` results in success" do
        before do
          shell_out_run_success command: "workspace select kitchen-terraform-test-suite-test-platform"
        end

        it_behaves_like "terraform: get; validate; apply; output"
      end
    end

    describe "#create" do
      subject do
        lambda do
          described_instance.create({})
        end
      end

      before do
        described_instance.finalize_config! kitchen_instance
      end

      context "when `terraform init` results in failure" do
        before do
          shell_out_run_failure(
            command: /init/,
            message: "mocked `terraform init` failure"
          )
        end

        it do
          is_expected
            .to(
              raise_error(
                ::Kitchen::ActionFailed,
                "mocked `terraform init` failure"
              )
            )
        end
      end

      context "when `terraform init` results in success" do
        before do
          shell_out_run_success(
            command:
              "init " \
                "-input=false " \
                "-lock=true " \
                "-lock-timeout=0s " \
                "-no-color " \
                "-upgrade " \
                "-force-copy " \
                "-backend=true " \
                "-backend-config=key\\=value " \
                "-get=true " \
                "-get-plugins=true " \
                "-plugin-dir=\/plugin\/directory " \
                "-verify-plugins=true"
          )
        end

        context "when `terraform workspace select <kitchen-instance>` results in failure" do
          before do
            shell_out_run_failure(
              command: "workspace select kitchen-terraform-test-suite-test-platform",
              message: "mocked `terraform workspace select <kitchen-instance>` failure"
            )
          end

          context "when `terraform workspace new <kitchen-instance>` results in failure" do
            before do
              shell_out_run_failure(
                command: "workspace new kitchen-terraform-test-suite-test-platform",
                message: "mocked `terraform workspace new <kitchen-instance>` failure"
              )
            end

            it do
              is_expected
                .to(
                  raise_error(
                    ::Kitchen::ActionFailed,
                    "mocked `terraform workspace new <kitchen-instance>` failure"
                  )
                )
            end
          end

          context "when `terraform workspace new <kitchen-instance>` results in success" do
            it_behaves_like "the `terraform workspace <kitchen-instance>` subcommand results in success" do
              let :subcommand do
                "new"
              end
            end
          end
        end

        context "when `terraform workspace select <kitchen-instance>` results in success" do
          it_behaves_like "the `terraform workspace <kitchen-instance>` subcommand results in success"
        end
      end
    end

    describe "#destroy" do
      subject do
        lambda do
          described_instance.destroy({})
        end
      end

      before do
        described_instance.finalize_config! kitchen_instance
      end

      context "when `terraform init` results in failure" do
        before do
          shell_out_run_failure(
            command: /init/,
            message: "mocked `terraform init` failure"
          )
        end

        it do
          is_expected
            .to(
              raise_error(
                ::Kitchen::ActionFailed,
                "mocked `terraform init` failure"
              )
            )
        end
      end

      context "when `terraform init` results in success" do
        before do
          shell_out_run_success(
            command:
              "init " \
                "-input=false " \
                "-lock=true " \
                "-lock-timeout=0s " \
                "-no-color " \
                "-force-copy " \
                "-backend=true " \
                "-backend-config=key\\=value " \
                "-get=true " \
                "-get-plugins=true " \
                "-plugin-dir=\/plugin\/directory " \
                "-verify-plugins=true"
          )
        end

        context "when `terraform workspace select <kitchen-instance>` results in failure" do
          before do
            shell_out_run_failure(
              command: "workspace select kitchen-terraform-test-suite-test-platform",
              message: "mocked `terraform workspace select <kitchen-instance>` failure"
            )
          end

          context "when `terraform workspace new <kitchen-instance>` results in failure" do
            before do
              shell_out_run_failure(
                command: "workspace new kitchen-terraform-test-suite-test-platform",
                message: "mocked `terraform workspace new <kitchen-instance>` failure"
              )
            end

            it do
              is_expected
                .to(
                  raise_error(
                    ::Kitchen::ActionFailed,
                    "mocked `terraform workspace new <kitchen-instance>` failure"
                  )
                )
            end
          end
        end

        context "when `terraform workspace select <kitchen-instance>` results in success" do
          before do
            shell_out_run_success command: "workspace select kitchen-terraform-test-suite-test-platform"
          end

          context "when `terraform destroy` results in failure" do
            before do
              shell_out_run_failure(
                command: /destroy/,
                message: "mocked `terraform destroy` failure"
              )
            end

            it do
              is_expected
                .to(
                  raise_error(
                    ::Kitchen::ActionFailed,
                    "mocked `terraform destroy` failure"
                  )
                )
            end
          end

          context "when `terraform destroy` results in success" do
            before do
              shell_out_run_success(
                command:
                  "destroy " \
                    "-auto-approve " \
                    "-lock=true " \
                    "-lock-timeout=0s " \
                    "-input=false " \
                    "-no-color " \
                    "-parallelism=10 " \
                    "-refresh=true " \
                    "-var=key\\=value " \
                    "-var-file=\/variable\/file"
              )
            end

            context "when `terraform select default` results in failure" do
              before do
                shell_out_run_failure(
                  command: "workspace select default",
                  message: "mocked `terraform workspace select default` failure"
                )
              end

              it do
                is_expected
                  .to(
                    raise_error(
                      ::Kitchen::ActionFailed,
                      "mocked `terraform workspace select default` failure"
                    )
                  )
              end
            end

            context "when `terraform workspace select default` results in success" do
              before do
                shell_out_run_success command: "workspace select default"
              end

              context "when `terraform workspace delete <kitchen-instance>` results in failure" do
                before do
                  shell_out_run_failure(
                    command: "workspace delete kitchen-terraform-test-suite-test-platform",
                    message: "mocked `terraform workspace delete <kitchen-instance>` failure"
                  )
                end

                it do
                  is_expected
                    .to(
                      raise_error(
                        ::Kitchen::ActionFailed,
                        "mocked `terraform workspace delete <kitchen-instance>` failure"
                      )
                    )
                end
              end

              context "when `terraform workspace delete <kitchen-instance>` results in success" do
                it_behaves_like "the `terraform workspace <kitchen-instance>` subcommand results in success" do
                  let :subcommand do
                    "delete"
                  end
                end
              end
            end
          end
        end
      end
    end

    describe "#verify_dependencies" do
      subject do
        lambda do
          described_instance.verify_dependencies
        end
      end

      context "when `terraform version` results in failure" do
        before do
          shell_out_run_failure(
            command: "version",
            message: "mocked `terraform version` failure",
            working_directory: "."
          )
        end

        it do
          is_expected
            .to(
              raise_error(
                ::Kitchen::UserError,
                "mocked `terraform version` failure"
              )
            )
        end
      end

      context "when `terraform version` results in success" do
        before do
          shell_out_run_success(
            command: "version",
            return_value: version_return_value,
            working_directory: "."
          )
        end

        context "when the value of the `terraform version` result is not supported" do
          let :version_return_value do
            "Terraform v0.9.0"
          end

          it do
            is_expected
              .to(
                raise_error(
                  ::Kitchen::UserError,
                  /not supported/
                )
              )
          end
        end

        context "when the value of the `terraform version` result is supported" do
          let :version_return_value do
            "Terraform v0.11.0"
          end

          it do
            is_expected.to_not raise_error
          end
        end
      end
    end
  end
