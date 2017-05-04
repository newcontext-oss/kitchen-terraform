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

require "terraform"
require "terraform/command"

# A command to show a state
class ::Terraform::ShowCommand < ::Terraform::Command
  private

  def initialize(target: "", &block)
    super target: target, &block
    preparations.push ::Terraform::PrepareInputFile.new file: ::Pathname.new(target)
  end
end

require "pathname"
require "terraform/prepare_input_file"
