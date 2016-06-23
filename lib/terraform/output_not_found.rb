# frozen_string_literal: true

require_relative 'error'

module Terraform
  # Error of an output not found
  class OutputNotFound < Error
  end
end
