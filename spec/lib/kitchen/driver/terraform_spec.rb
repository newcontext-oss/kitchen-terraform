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

require "dry/monads"
require "json"
require "kitchen"
require "kitchen/driver/terraform"
require "kitchen/terraform/shell_out"
require "support/dry/monads/either_matchers"
require "support/kitchen/terraform/config_attribute/backend_configurations_examples"
require "support/kitchen/terraform/config_attribute/color_examples"
require "support/kitchen/terraform/config_attribute/command_timeout_examples"
require "support/kitchen/terraform/config_attribute/directory_examples"
require "support/kitchen/terraform/config_attribute/lock_timeout_examples"
require "support/kitchen/terraform/config_attribute/parallelism_examples"
require "support/kitchen/terraform/config_attribute/plugin_directory_examples"
require "support/kitchen/terraform/config_attribute/variable_files_examples"
require "support/kitchen/terraform/config_attribute/variables_examples"
require "support/kitchen/terraform/configurable_examples"

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

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::BackendConfigurations"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::CommandTimeout"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Color"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Directory"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::LockTimeout"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Parallelism"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::PluginDirectory"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::VariableFiles"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Variables"

    it_behaves_like "Kitchen::Terraform::Configurable"

    describe ".serial_actions" do
      subject do
        described_class.serial_actions
      end

      it "is empty" do
        is_expected.to be_empty
      end
    end

    describe "#apply" do
      before do
        described_instance.finalize_config! kitchen_instance
      end

      subject do
        described_instance.apply
      end

      context "when `terraform workspace select <kitchen-instance>` results in failure" do
        before do
          allow(shell_out)
            .to(
              receive(:run)
                .with(
                  command: "workspace select kitchen-terraform-test-suite-test-platform",
                  duration: 600,
                  logger: kitchen_logger
                )
                .and_return(::Dry::Monads.Left("mocked `terraform workspace select <kitchen-instance>` failure"))
            )
        end

        it do
          is_expected
            .to result_in_failure.with_the_value "mocked `terraform workspace select <kitchen-instance>` failure"
        end
      end

      context "when `terraform workspace select <kitchen-instance>` results in success" do
        before do
          allow(shell_out)
            .to(
              receive(:run)
                .with(
                  command: "workspace select kitchen-terraform-test-suite-test-platform",
                  duration: 600,
                  logger: kitchen_logger
                )
                .and_return(::Dry::Monads.Right("mocked `terraform workspace select <kitchen-instance>` success"))
            )
        end

        context "when `terraform get` results in failure" do
          before do
            allow(shell_out)
              .to(
                receive(:run)
                  .with(
                    command: /get/,
                    duration: 600,
                    logger: kitchen_logger
                  )
                  .and_return(::Dry::Monads.Left("mocked `terraform get` failure"))
              )
          end

          it do
            is_expected.to result_in_failure.with_the_value "mocked `terraform get` failure"
          end
        end

        context "when `terraform get` results in success" do
          before do
            allow(shell_out)
              .to(
                receive(:run)
                  .with(
                    command:
                      /get\s
                        -update\s
                        #{kitchen_root}/x,
                    duration: 600,
                    logger: kitchen_logger
                  )
                  .and_return(::Dry::Monads.Right("mocked `terraform get` success"))
              )
          end

          context "when `terraform validate` results in failure" do
            before do
              allow(shell_out)
                .to(
                  receive(:run)
                    .with(
                      command: /validate/,
                      duration: 600,
                      logger: kitchen_logger
                    )
                    .and_return(::Dry::Monads.Left("mocked `terraform validate` failure"))
                )
            end

            it do
              is_expected.to result_in_failure.with_the_value "mocked `terraform validate` failure"
            end
          end

          context "when `terraform validate` results in success" do
            before do
              allow(shell_out)
                .to(
                  receive(:run)
                    .with(
                      command:
                        /validate\s
                          -check-variables=true\s
                          -no-color\s
                          -var='key=value'\s
                          -var-file=\/variable\/file\s
                          #{kitchen_root}/x,
                      duration: 600,
                      logger: kitchen_logger
                    )
                    .and_return(::Dry::Monads.Right("mocked `terraform validate` success"))
                )
            end

            context "when `terraform apply` results in failure" do
              before do
                allow(shell_out)
                  .to(
                    receive(:run)
                      .with(
                        command: /apply/,
                        duration: 600,
                        logger: kitchen_logger
                      )
                      .and_return(::Dry::Monads.Left("mocked `terraform apply` failure"))
                  )
              end

              it do
                is_expected.to result_in_failure.with_the_value "mocked `terraform apply` failure"
              end
            end

            context "when `terraform apply` results in success" do
              before do
                allow(shell_out)
                  .to(
                    receive(:run)
                      .with(
                        command:
                          /apply\s
                            -lock=true\s
                            -lock-timeout=0s\s
                            -input=false\s
                            -auto-approve=true\s
                            -no-color\s
                            -parallelism=10\s
                            -refresh=true\s
                            -var='key=value'\s
                            -var-file=\/variable\/file\s
                            #{kitchen_root}/x,
                        duration: 600,
                        logger: kitchen_logger
                      )
                      .and_return(::Dry::Monads.Right("mocked `terraform apply` success"))
                  )
              end

              context "when `terraform output` results in failure" do
                before do
                  allow(shell_out)
                    .to(
                      receive(:run)
                        .with(
                          command: "output -json",
                          duration: 600,
                          logger: kitchen_logger
                        )
                        .and_return(::Dry::Monads.Left("mocked `terraform output` failure"))
                    )
                end

                it do
                  is_expected.to result_in_failure.with_the_value "mocked `terraform output` failure"
                end
              end

              context "when `terraform output` results in success" do
                before do
                  allow(shell_out)
                    .to(
                      receive(:run)
                        .with(
                          command: "output -json",
                          duration: 600,
                          logger: kitchen_logger
                        )
                        .and_return(::Dry::Monads.Right(terraform_output_value))
                    )
                end

                context "when the value of the `terraform output` result is not valid JSON" do
                  let :terraform_output_value do
                    "not valid JSON"
                  end

                  it do
                    is_expected.to result_in_failure.with_the_value /Parsing Terraform output as JSON failed:/
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
                        result_in_success
                          .with_the_value(
                            "output_name" =>
                              {
                                "sensitive" => false,
                                "type" => "list",
                                "value" => ["output_value_1"]
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
    end

    describe "#create" do
      before do
        described_instance.finalize_config! kitchen_instance
      end

      subject do
        lambda do
          described_instance.create({})
        end
      end

      context "when `terraform init` results in failure" do
        before do
          allow(shell_out)
            .to(
              receive(:run)
                .with(
                  command: /init/,
                  duration: 600,
                  logger: kitchen_logger
                )
                .and_return(::Dry::Monads.Left("mocked `terraform init` failure"))
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
          allow(shell_out)
            .to(
              receive(:run)
                .with(
                  command:
                    /init\s
                      -input=false\s
                      -lock=true\s
                      -lock-timeout=0s\s
                      -no-color\s
                      -upgrade\s
                      -force-copy\s
                      -backend=true\s
                      -backend-config='key=value'\s
                      -get=true\s
                      -get-plugins=true\s
                      -plugin-dir=\/plugin\/directory\s
                      -verify-plugins=true\s
                      #{kitchen_root}/x,
                  duration: 600,
                  logger: kitchen_logger
                )
                .and_return(::Dry::Monads.Right("mocked `terraform init` success"))
            )
        end

        context "when `terraform workspace new <kitchen-instance>` results in failure" do
          before do
            allow(shell_out)
              .to(
                receive(:run)
                  .with(
                    command: "workspace new kitchen-terraform-test-suite-test-platform",
                    duration: 600,
                    logger: kitchen_logger
                  )
                  .and_return(::Dry::Monads.Left("mocked `terraform workspace new <kitchen-instance>` failure"))
              )
          end

          context "when `terraform workspace select <kitchen-instance>` results in failure" do
            before do
              allow(shell_out)
                .to(
                  receive(:run)
                    .with(
                      command: "workspace select kitchen-terraform-test-suite-test-platform",
                      duration: 600,
                      logger: kitchen_logger
                    )
                    .and_return(::Dry::Monads.Left("mocked `terraform workspace select <kitchen-instance>` failure"))
                )
            end

            it do
              is_expected
                .to(
                  raise_error(
                    ::Kitchen::ActionFailed,
                    "mocked `terraform workspace select <kitchen-instance>` failure"
                  )
                )
            end
          end

          context "when `terraform workspace select <kitchen-instance>` results in success" do
            before do
              allow(shell_out)
                .to(
                  receive(:run)
                    .with(
                      command: "workspace select kitchen-terraform-test-suite-test-platform",
                      duration: 600,
                      logger: kitchen_logger
                    )
                    .and_return(::Dry::Monads.Right("mocked `terraform workspace select <kitchen-instance>` success"))
                )
            end

            it do
              is_expected.to_not raise_error
            end
          end
        end

        context "when `terraform workspace new <kitchen-instance>` results in success" do
          before do
            allow(shell_out)
              .to(
                receive(:run)
                  .with(
                    command: "workspace new kitchen-terraform-test-suite-test-platform",
                    duration: 600,
                    logger: kitchen_logger
                  )
                  .and_return(::Dry::Monads.Right("mocked `terraform workspace new <kitchen-instance>` success"))
              )
          end

          it do
            is_expected.to_not raise_error
          end
        end
      end
    end

    describe "#destroy" do
      before do
        described_instance.finalize_config! kitchen_instance
      end

      subject do
        lambda do
          described_instance.destroy({})
        end
      end

      context "when `terraform init` results in failure" do
        before do
          allow(shell_out)
            .to(
              receive(:run)
                .with(
                  command: /init/,
                  duration: 600,
                  logger: kitchen_logger
                )
                .and_return(::Dry::Monads.Left("mocked `terraform init` failure"))
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
          allow(shell_out)
            .to(
              receive(:run)
                .with(
                  command:
                    /init\s
                      -input=false\s
                      -lock=true\s
                      -lock-timeout=0s\s
                      -no-color\s
                      -force-copy\s
                      -backend=true\s
                      -backend-config='key=value'\s
                      -get=true\s
                      -get-plugins=true\s
                      -plugin-dir=\/plugin\/directory\s
                      -verify-plugins=true\s
                      #{kitchen_root}/x,
                  duration: 600,
                  logger: kitchen_logger
                )
                .and_return(::Dry::Monads.Right("mocked `terraform init` success"))
            )
        end

        context "when `terraform workspace select <kitchen-instance>` results in failure" do
          before do
            allow(shell_out)
              .to(
                receive(:run)
                  .with(
                    command: "workspace select kitchen-terraform-test-suite-test-platform",
                    duration: 600,
                    logger: kitchen_logger
                  )
                  .and_return(::Dry::Monads.Left("mocked `terraform workspace select <kitchen-instance>` failure"))
              )
          end

          context "when `terraform workspace new <kitchen-instance>` results in failure" do
            before do
              allow(shell_out)
                .to(
                  receive(:run)
                    .with(
                      command: "workspace new kitchen-terraform-test-suite-test-platform",
                      duration: 600,
                      logger: kitchen_logger
                    )
                    .and_return(::Dry::Monads.Left("mocked `terraform workspace new <kitchen-instance>` failure"))
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
            allow(shell_out)
              .to(
                receive(:run)
                  .with(
                    command: "workspace select kitchen-terraform-test-suite-test-platform",
                    duration: 600,
                    logger: kitchen_logger
                  )
                  .and_return(::Dry::Monads.Right("mocked `terraform workspace select <kitchen-instance>` success"))
              )
          end

          context "when `terraform destroy` results in failure" do
            before do
              allow(shell_out)
                .to(
                  receive(:run)
                    .with(
                      command: /destroy/,
                      duration: 600,
                      logger: kitchen_logger
                    )
                    .and_return(::Dry::Monads.Left("mocked `terraform destroy` failure"))
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
              allow(shell_out)
                .to(
                  receive(:run)
                    .with(
                      command:
                        /destroy\s
                          -force\s
                          -lock=true\s
                          -lock-timeout=0s\s
                          -input=false\s
                          -no-color\s
                          -parallelism=10\s
                          -refresh=true\s
                          -var='key=value'\s
                          -var-file=\/variable\/file\s
                          #{kitchen_root}/x,
                      duration: 600,
                      logger: kitchen_logger
                    )
                    .and_return(::Dry::Monads.Right("mocked `terraform destroy` success"))
                )
            end

            context "when `terraform select default` results in failure" do
              before do
                allow(shell_out)
                  .to(
                    receive(:run)
                      .with(
                        command: "workspace select default",
                        duration: 600,
                        logger: kitchen_logger
                      )
                      .and_return(::Dry::Monads.Left("mocked `terraform workspace select default` failure"))
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
                allow(shell_out)
                  .to(
                    receive(:run)
                      .with(
                        command: "workspace select default",
                        duration: 600,
                        logger: kitchen_logger
                      )
                      .and_return(::Dry::Monads.Right("mocked `terraform workspace select default` success"))
                  )
              end

              context "when `terraform workspace delete <kitchen-instance>` results in failure" do
                before do
                  allow(shell_out)
                    .to(
                      receive(:run)
                        .with(
                          command: "workspace delete kitchen-terraform-test-suite-test-platform",
                          duration: 600,
                          logger: kitchen_logger
                        )
                        .and_return(
                          ::Dry::Monads.Left("mocked `terraform workspace delete <kitchen-instance>` failure")
                        )
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
                before do
                  allow(shell_out)
                    .to(
                      receive(:run)
                        .with(
                          command: "workspace delete kitchen-terraform-test-suite-test-platform",
                          duration: 600,
                          logger: kitchen_logger
                        )
                        .and_return(
                          ::Dry::Monads.Right("mocked `terraform workspace delete <kitchen-instance>` success")
                        )
                    )
                end

                it do
                  is_expected.to_not raise_error
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
          allow(shell_out)
            .to(
              receive(:run)
                .with(
                  command: "version",
                  logger: kitchen_logger
                ).and_return(::Dry::Monads.Left("mocked `terraform version` failure"))
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
          allow(shell_out)
            .to(
              receive(:run)
                .with(
                  command: "version",
                  logger: kitchen_logger
                ).and_return(::Dry::Monads.Right(terraform_version_value))
            )
        end

        context "when the value of the `terraform version` result is less than v0.10.2" do
          let :terraform_version_value do
            "terraform v0.10.1"
          end

          it do
            is_expected
              .to(
                raise_error(
                  ::Kitchen::UserError,
                  "Terraform version 0.10.1 is not supported; upgrade to Terraform version ~> 0.10.2"
                )
              )
          end
        end

        context "when the value of the `terraform version` result is greater than or equal to v0.11.0" do
          let :terraform_version_value do
            "terraform v0.11.0"
          end

          it do
            is_expected
              .to(
                raise_error(
                  ::Kitchen::UserError,
                  "Terraform version 0.11.0 is not supported; upgrade to Terraform version ~> 0.10.2"
                )
              )
          end
        end

        context(
          "when the value of the `terraform version` result is greater than or equal to v0.10.2 and less than v0.11.0"
        ) do
          let :terraform_version_value do
            "terraform v0.10.3"
          end

          it do
            is_expected.to_not raise_error
          end
        end
      end
    end
  end
