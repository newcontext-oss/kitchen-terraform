# frozen_string_literal: true

require 'inspec'

module Terraform
  # Inspec::Runner with convenience methods for use by
  # Kitchen::Verifier::Terraform
  class InspecRunner < Inspec::Runner
    attr_reader :conf

    def add(targets:)
      targets.each { |target| add_target target, conf }
    end

    def define_attribute(name:, value:)
      conf.fetch('attributes').store name.to_s, value
    end

    def verify_run(verifier:)
      verifier.evaluate exit_code: run
    end

    private

    def initialize(conf = {})
      super
      yield self if block_given?
    end
  end
end
