# frozen_string_literal: true

require "bundler/gem_tasks"
require "digest"
require "open-uri"
require "pathname"
require "uri"
require "zip"

def binstub(name:)
  ::File
    .expand_path(
      "../bin/#{name}",
      __FILE__
    )
end

def configure_default_integration(arguments:)
  arguments
    .with_defaults(
      terraform_version: "0.11.7",
      terraform_sha256_sum: "6b8ce67647a59b2a3f70199c304abca0ddec0e49fd060944c26f666298e23418"
    )
end

def download_terraform(arguments:)
  executable =
    ::Pathname
      .new("terraform")
      .expand_path

  uri =
    ::URI
      .parse(
        "https://releases.hashicorp.com/terraform/#{arguments.terraform_version}/terraform_#{arguments.terraform_version}_linux_amd64.zip"
      )

  puts "Downloading Terraform archive from #{uri}"

  open(
    expected_sha256_sum: arguments.terraform_sha256_sum,
    uri: uri
  ) do |archive:|
    puts "Extracting executable to #{executable}"

    ::Zip::File
      .open archive.path do |zip_file|
        zip_file
          .glob("terraform")
          .first
          .extract executable
      end

    executable.chmod 0o0544
    yield directory: executable.dirname
  end
ensure
  executable.exist? and executable.unlink
end

def execute_terraform(arguments:, path:)
  configure_default_integration arguments: arguments

  download_terraform arguments: arguments do |directory:|
    ::Dir
      .chdir path do
        sh "KITCHEN_LOG=debug PATH=#{directory}:$PATH #{kitchen_binstub} test"
      end
  end
end

def open(expected_sha256_sum:, uri:)
  uri
    .open do |archive|
      actual_sha256_sum =
        ::Digest::SHA256
          .file(archive.path)
          .hexdigest

      expected_sha256_sum == actual_sha256_sum or
        raise(
          "Downloaded Terraform archive was expected to have a SHA256 sum of '#{expected_sha256_sum}' but has an " \
            "actual SHA256 sum of '#{actual_sha256_sum}'"
        )

    yield archive: archive
  end
end

def rspec_binstub
  binstub name: "rspec"
end

def kitchen_binstub
  binstub name: "kitchen"
end

namespace :tests do
  namespace :unit do
    desc "Run all unit tests"

    task :all do
      sh "#{rspec_binstub} --backtrace"
    end
  end

  namespace :integration do
    desc "Run integration tests for basic functionality"

    task(
      :basic,
      [
        :terraform_version,
        :terraform_sha256_sum
      ]
    ) do |_, arguments|
      execute_terraform(
        arguments: arguments,
        path: "integration/basic"
      )
    end

    desc "Run integration tests for no outputs defined"

    task(
      :no_outputs_defined,
      [
        :terraform_version,
        :terraform_sha256_sum
      ]
    ) do |_, arguments|
      execute_terraform(
        arguments: arguments,
        path: "integration/no_outputs_defined"
      )
    end

    desc "Run integration tests shell words"

    task(
      :shell_words,
      [
        :terraform_version,
        :terraform_sha256_sum
      ]
    ) do |_, arguments|
      execute_terraform(
        arguments: arguments,
        path: "integration/Shell Words"
      )
    end

    desc "Run all integration tests"

    task(
      :all,
      [
        :terraform_version,
        :terraform_sha256_sum
      ] =>
        [
          "tests:integration:basic",
          "tests:integration:no_outputs_defined",
          "tests:integration:shell_words"
        ]
    )
  end
end

task default: "tests:unit:all"
