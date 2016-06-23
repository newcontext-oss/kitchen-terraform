# frozen_string_literal: true

require_relative 'client'

module Terraform
  # Logic to provide a lazily initialized Client instance
  module ClientHolder
    def client
      @client ||= Client.new instance: instance
    end
  end
end
