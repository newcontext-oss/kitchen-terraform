# frozen_string_literal: true

require_relative 'command'

module Terraform
  # Command to plan an execution
  class PlanCommand
    include Command

    private

    def initialize_attributes(destroy:, out:, state:, var:, var_file:, dir:)
      self.name = 'plan'
      self.options = {
        destroy: destroy, input: false, out: out, state: state, var: var,
        var_file: var_file
      }
      self.target = dir
    end
  end
end
