# frozen_string_literal: true

require 'mixlib/shellout'
require 'pathname'
require_relative 'command_options'
require_relative 'error'

module Terraform
  # Common logic for Mixlib::ShellOut Terraform commands
  module Command
    attr_reader :name, :options, :target

    def execute
      # TODO: use the live output stream
      shell_out.run_command
      shell_out.error!
      yield shell_out.stdout if block_given?
    rescue => error
      handle error: error
      raise Error, error.message, error.backtrace
    end

    def handle(**_)
    end

    def to_s
      CommandOptions.new options do |command_options|
        return "terraform #{name} #{command_options} #{target}"
      end
    end

    private

    attr_accessor :shell_out

    attr_writer :name, :options, :target

    def initialize(**keyword_arguments)
      initialize_attributes(**keyword_arguments)
      self.shell_out = Mixlib::ShellOut.new to_s, returns: 0
      yield self if block_given?
    end
  end
end
