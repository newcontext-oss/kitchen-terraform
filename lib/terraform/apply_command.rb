# frozen_string_literal: true

require_relative 'command'

module Terraform
  # Command to apply an execution plan
  class ApplyCommand
    include Command

    private

    def initialize_attributes(state:, plan:)
      self.name = 'apply'
      self.options = { input: false, state: state }
      self.target = plan
    end
  end
end
