# frozen_string_literal: true

require_relative 'command'
require_relative 'output_not_found'

module Terraform
  # Command to extract values of output variables
  class OutputCommand
    include Command

    def handle(error:)
      raise OutputNotFound, error.message, error.backtrace if
        error.message =~ /no(?:thing to)? output/
    end

    private

    def initialize_attributes(state:, name:)
      self.name = 'output'
      self.options = { state: state }
      self.target = name
    end
  end
end
