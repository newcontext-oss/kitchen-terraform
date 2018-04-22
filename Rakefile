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

def download_and_extract_hashicorp_release(destination:, expected_sha256_sum:, product:, version:)
  uri =
    ::URI::HTTPS
      .build(
        host: "releases.hashicorp.com",
        path:
          ::File
            .join(
              "/",
              product,
              version,
              "#{product}_#{version}_linux_amd64.zip"
            )
      )

  puts "Downloading #{uri}"

  uri
    .open do |file|
      actual_sha256_sum =
        ::Digest::SHA256
          .file(file.path)
          .hexdigest

      expected_sha256_sum == actual_sha256_sum or
        raise(
          "Downloaded Terraform archive was expected to have a SHA256 sum of '#{expected_sha256_sum}' but has an " \
            "actual SHA256 sum of '#{actual_sha256_sum}'"
        )

      extract_archive(
        destination: destination,
        source: file
      )
    end
end

def execute_terraform(arguments:, path:)
  configure_default_integration arguments: arguments

  directory =
    ::Pathname
      .new("terraform_#{arguments.terraform_version}")
      .expand_path

  directory.mkpath

  download_and_extract_hashicorp_release(
    destination: directory,
    expected_sha256_sum: arguments.terraform_sha256_sum,
    product: "terraform",
    version: arguments.terraform_version
  )

  ::Dir
    .chdir path do
      sh "KITCHEN_LOG=debug PATH=#{directory}:$PATH #{kitchen_binstub} test"
    end
end

def extract_archive(destination:, source:)
  destination_pathname = Pathname destination
  source_pathname = Pathname source
  puts "Extracting #{source_pathname} to #{destination_pathname}"
  destination_pathname.mkpath

  ::Zip::File
    .open source_pathname do |zip_file|
      zip_file
        .each do |entry|
          extract_archive_entry(
            destination: destination_pathname.join(entry.name),
            source: entry
          )
        end
    end
end

def extract_archive_entry(destination:, source:)
  destination.exist? or source.extract destination
  destination.chmod 0o0544
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
