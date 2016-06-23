# frozen_string_literal: true

module Terraform
  # Manages options for Terraform commands
  class CommandOptions
    def to_s
      key_flags.each_with_object String.new('') do |(flag, values), string|
        values.each { |value| string.concat "#{flag}=#{value} " }
      end.chomp ' '
    end

    private

    attr_accessor :options

    def key_flags
      options
        .map { |key, value| [key.to_s.tr('_', '-').prepend('-'), value] }.to_h
    end

    def initialize(**options)
      self.options = options
      normalize_values
      yield self if block_given?
    end

    def normalize_values
      options.each_pair { |key, value| options.store key, Array(value) }
    end
  end
end
