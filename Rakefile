# frozen_string_literal: true

require "bundler/gem_tasks"
require "digest"
require "open-uri"
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
  executable = ::Tempfile.new "terraform"
  executable.close

  ::URI
    .parse(
      "https://releases.hashicorp.com/terraform/#{version}/terraform_#{version}_linux_amd64.zip"
    )
    .open do |archive|
      if(
        ::Digest::SHA256
          .file(archive.path)
          .hexdigest
          .==(sha256_sum)
      )
        ::Zip::File
          .open archive.path do |zip_file|
            zip_file
              .glob("terraform")
              .first
              .extract executable.path do
                true
              end

            yield path: executable.path
          end
      else
        raise "Downloaded Terraform archive has an unexpected SHA256 sum"
      end
    end
ensure
  executable.close
  executable.unlink
end

namespace :test do
  desc "Run unit tests"

  task :unit do
    sh "#{binstub name: "rspec"} --backtrace"
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
    ) do |path:|
      ::Dir.chdir "integration/docker_provider"
      sh "PATH=\"$PATH:#{path}\" #{binstub name: "kitchen"} --log-level=debug"
    end
  end
end

task default: "test:unit"
