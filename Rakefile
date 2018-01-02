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

def download_terraform(sha256_sum:, version:)
  executable =
    ::Pathname
      .new("terraform")
      .expand_path

  uri =
    ::URI
      .parse(
        "https://releases.hashicorp.com/terraform/#{version}/terraform_#{version}_linux_amd64.zip"
      )

  puts "Downloading Terraform archive from #{uri}"

  uri
    .open do |archive|
      ::Digest::SHA256
        .file(archive.path)
        .hexdigest
        .==(sha256_sum) or
        raise "Downloaded Terraform archive has an unexpected SHA256 sum"

      puts "Extracting executable to #{executable}"

      ::Zip::File
        .open archive.path do |zip_file|
          zip_file
            .glob("terraform")
            .first
            .extract executable
        end

      executable.chmod 0544
      yield directory: executable.dirname
    end
ensure
  executable.unlink
end

def rspec_binstub
  binstub name: "rspec"
end

def kitchen_binstub
  binstub name: "kitchen"
end

namespace :test do
  desc "Run unit tests"

  task :unit do
    sh "#{rspec_binstub} --backtrace"
  end

  desc "Run integration tests"

  task(
    :integration,

    [
      :terraform_version,
      :terraform_sha256_sum
    ]
  ) do |_, arguments|
    download_terraform(
      sha256_sum: arguments.terraform_sha256_sum,
      version: arguments.terraform_version
    ) do |directory:|
      ::Dir.chdir "integration/docker_provider"
      sh "KITCHEN_LOG=debug PATH=#{directory}:$PATH #{kitchen_binstub} test"
    end
  end
end

task default: "test:unit"
