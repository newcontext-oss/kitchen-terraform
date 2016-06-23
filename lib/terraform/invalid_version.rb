# frozen_string_literal: true

require_relative 'error'

module Terraform
  # Error of an invalid Terraform version
  class InvalidVersion < Error
    def message
      "Terraform version must match #{supported_version}"
    end

    private

    attr_accessor :supported_version

    def initialize(supported_version)
      self.supported_version = supported_version
    end
  end
end
