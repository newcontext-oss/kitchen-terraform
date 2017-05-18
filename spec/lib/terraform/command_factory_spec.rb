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

require "terraform/command_factory"
require "support/terraform/configurable_context"

::RSpec.describe ::Terraform::CommandFactory do
  include_context "instance"

  let :described_instance do
    described_class.new config: driver
  end

  before do
    driver[:color] = false

    driver[:directory] = ::Pathname.new "/directory"

    driver[:parallelism] = 1234

    driver[:plan] = ::Pathname.new "/plan/file"

    driver[:state] = ::Pathname.new "/state/file"

    driver[:variable_files] = [::Pathname.new("/variable/file")]

    driver[:variables] = {name: "value"}
  end

  shared_examples "a target is set" do
    subject do command.target.to_path end

    it "specifies a target" do is_expected.to eq target end
  end

  shared_examples "color option" do it "is set from config[:color]" do is_expected.to include "-no-color" end end

  shared_examples "destroy option" do it "is enabled" do is_expected.to include "-destroy=true" end end

  shared_examples "input option" do it "is disabled" do is_expected.to include "-input=false" end end

  shared_examples "options are specified" do subject do command.options.to_s end end

  shared_examples "output command options" do
    it_behaves_like "color option"

    it_behaves_like "state option"
  end

  shared_examples "parallelism option" do
    it "is set from config[:parallelism]" do is_expected.to include "-parallelism=1234" end
  end

  shared_examples "plan command options" do
    it_behaves_like "color option"

    it_behaves_like "input option"

    it_behaves_like "parallelism option"

    it_behaves_like "state option"

    it_behaves_like "var option"

    it_behaves_like "var-file option"

    it "out option is set from config[:plan]" do is_expected.to include "-out=/plan/file" end
  end

  shared_examples "state option" do
    it "is set from config[:state]" do is_expected.to include "-state=/state/file" end
  end

  shared_examples "var option" do
    it "is set from config[:variables]" do is_expected.to include "-var='name=value'" end
  end

  shared_examples "var-file option" do
    it "is set from config[:variable_files]" do is_expected.to include "-var-file=/variable/file" end
  end

  describe "#destructive_plan_command" do
    let :command do described_instance.destructive_plan_command end

    it_behaves_like "a target is set" do let :target do "/directory" end end

    it_behaves_like "options are specified" do
      it_behaves_like "destroy option"

      it_behaves_like "plan command options"
    end
  end

  describe "#get_command" do
    let :command do described_instance.get_command end

    it_behaves_like "a target is set" do let :target do "/directory" end end

    it_behaves_like "options are specified" do
      it "update option is enabled" do is_expected.to include "-update=true" end
    end
  end

  describe "#output_command" do
    let :command do described_instance.output_command target: ::Pathname.new("/target") end

    it_behaves_like "a target is set" do let :target do "/target" end end

    it_behaves_like "options are specified" do
      it_behaves_like "output command options"

      it "json option is enabled" do is_expected.to include "-json=true" end
    end
  end

  describe "#plan_command" do
    let :command do described_instance.plan_command end

    it_behaves_like "a target is set" do let :target do "/directory" end end

    it_behaves_like "options are specified" do it_behaves_like "plan command options" end
  end

  describe "#show_command" do
    let :command do described_instance.show_command end

    it_behaves_like "a target is set" do let :target do "/state/file" end end

    it_behaves_like "options are specified" do it_behaves_like "color option" end
  end

  describe "#validate_command" do
    let :command do described_instance.validate_command end

    it_behaves_like "a target is set" do let :target do "/directory" end end
  end
end
