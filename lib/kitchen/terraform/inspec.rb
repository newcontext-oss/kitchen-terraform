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
require "kitchen/terraform/error"
require "inspec"
require "inspec/cli"

# InSpec instances act as interfaces to the InSpec gem.
class ::Kitchen::Terraform::InSpec
  EXIT_CODE_SUCCESS = 0
  EXIT_CODE_SUCCESS_WITH_SKIPPED = 101

  VALID_EXIT_CODES =
    [
      EXIT_CODE_SUCCESS,
      EXIT_CODE_SUCCESS_WITH_SKIPPED
    ]
      .freeze

  # run executes InSpec controls.
  #
  # @param [::Hash] target with controls to execute.
  # @raise [::Kitchen::Terraform::Error] if the Inspec::Runner exits with an invalid code.
  # @return [void]
  def run(target:)
    run_runner target: target do |exit_code:|
      if not VALID_EXIT_CODES.include? exit_code
        raise(
          ::Kitchen::Terraform::Error,
          "InSpec Runner exited with #{exit_code}"
        )
      end
    end
  end

  private

  attr_accessor(
    :logger,
    :runner
  )

  # @api private
  # @param options [::Hash] options for an Inspec::Runner.
  def initialize(options:)
    self.logger = options.fetch "logger"
    self.runner = ::Inspec::Runner.new options
  end

  # @api private
  def run_runner(target:)
    runner
      .add_target(target)
      .tap do |profiles|
        logger.info "Loaded #{profiles.last}"
      end

    yield exit_code: runner.run
  end
end
