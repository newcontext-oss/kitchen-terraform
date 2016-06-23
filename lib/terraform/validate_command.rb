# frozen_string_literal: true

require_relative 'command'

module Terraform
  # Command to valdidate configuration files
  class ValidateCommand
    include Command

    private

    def initialize_attributes(dir:)
      self.name = 'validate'
      self.options = {}
      self.target = dir
    end
  end
end
