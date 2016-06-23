# frozen_string_literal: true

require_relative 'command'

module Terraform
  # Command to obtain the version
  class VersionCommand
    include Command

    private

    def initialize_attributes(**_)
      self.name = 'version'
      self.options = {}
      self.target = ''
    end
  end
end
