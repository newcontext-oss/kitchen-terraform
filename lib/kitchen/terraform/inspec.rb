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
require "train"

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

  class << self
    # logger= sets the logger for all InSpec processes.
    #
    # @param logger [::Kitchen::Logger] the logger to use.
    # @return [void]
    def logger=(logger)
      ::Inspec::Log.logger = logger
    end
  end

  # exec executes the InSpec controls of an InSpec profile.
  #
  # @raise [::Kitchen::Terraform::Error] if the execution of the InSpec controls fails.
  # @return [void]
  def exec
    self.exit_code = runner.run
    validate_exit_code
  rescue ::ArgumentError, ::RuntimeError, ::Train::UserError => error
    raise(
      ::Kitchen::Terraform::Error,
      error.message
    )
  end

  private

  attr_accessor(
    :exit_code,
    :runner
  )

  # @api private
  # @param options [::Hash] options for execution.
  # @param path [::String] the path to the InSpec profile which contains the controls to be executed.
  def initialize(options:, path:)
    ::Inspec::Runner.new(options).tap do |runner|
      self.runner = runner
      ::Inspec::Log.info ::String.new "Loaded #{runner.add_target(path: path).last.name}"
    end
  end

  # @api private
  def validate_exit_code
    VALID_EXIT_CODES
      .find(
        lambda do
          raise(
            ::Kitchen::Terraform::Error,
            "InSpec Runner exited with #{exit_code}"
          )
        end
      ) do |valid_exit_code|
        valid_exit_code == exit_code
      end
  end
end
