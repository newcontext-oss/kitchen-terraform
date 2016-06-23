# frozen_string_literal: true

require_relative 'command'

module Terraform
  # Command to get modules
  class GetCommand
    include Command

    private

    def initialize_attributes(dir:)
      self.name = 'get'
      self.options = { update: true }
      self.target = dir
    end
  end
end
