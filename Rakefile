# frozen_string_literal: true

require "bundler/gem_tasks"
require "digest"
require "open-uri"
require "pathname"
require "rake/clean"
require "rbconfig"
require "shellwords"
require "uri"
require "zip"

def binstub(name:)
  ::File
    .expand_path(
      "../bin/#{name}",
      __FILE__
    )
end

def download_hashicorp_release(destination:, platform:, product:, sha256_sum:, version:)
  uri = ::URI::HTTPS.build host: "releases.hashicorp.com",
                           path: ::File.join("/", product, version, "#{product}_#{version}_#{platform}_amd64.zip")

  puts "Downloading HashiCorp release of #{product} v#{version} to #{destination}"

  uri
    .open do |file|
    actual_sha256_sum =
      ::Digest::SHA256
        .file(file.path)
        .hexdigest

    sha256_sum == actual_sha256_sum or
      raise(
        "Downloaded HashiCorp release of #{product} v#{version} was expected to have a SHA256 sum of " \
        "'#{sha256_sum}' but actually has a SHA256 sum of '#{actual_sha256_sum}'"
      )

    cp(
      file.path,
      destination
    )
  end
end

def execute_kitchen_terraform(grep_pattern:, terraform_path:, working_directory:)
  sh kitchen_environment(terraform_path: terraform_path),
     "#{kitchen_binstub} test --destroy=always | tee /dev/tty | grep -Pz '(?s)#{grep_pattern}'",
     chdir: working_directory
end

CLOBBER.include "**/.kitchen"
CLOBBER.include "**/.terraform"

def execute_kitchen_terraform_via_rake(grep_pattern:, terraform_path:, working_directory:)
  sh kitchen_environment(terraform_path: terraform_path),
     "#{rake_binstub} kitchen:all | tee /dev/tty | grep -Pz '(?s)#{grep_pattern}'", chdir: working_directory
end

def extract_hashicorp_release(destination:, source:)
  puts "Extracting #{source} to #{destination}"
  mkdir_p destination

  ::Zip::File.open source do |zip_file|
    zip_file
      .each do |entry|
      entry_destination =
        ::File
          .join(
            destination,
            entry.name
          )

      entry.extract entry_destination

      chmod(
        0o0544,
        entry_destination
      )
    end
  end
end

def kitchen_binstub
  binstub name: "kitchen"
end

def kitchen_environment(terraform_path:)
  {
    "KITCHEN_LOG" => "debug",
    "PATH" => ::ENV.fetch("PATH").tr("\\", "/").split(::File::PATH_SEPARATOR)
      .prepend(::File.dirname(::RbConfig.ruby), ::File.dirname(::File.expand_path(terraform_path)))
      .map!(&::Shellwords.method(:escape)).join(":"),
  }
end

def rake_binstub
  binstub name: "rake"
end

def rspec_binstub
  binstub name: "rspec"
end

directory "tmp"
CLEAN.include "tmp/*"

file "tmp/terraform.zip",
     [:terraform_version, :terraform_sha256_sum, :terraform_platform] => ["tmp"] do |current_task, arguments|
  arguments.with_defaults terraform_version: "0.11.7",
                          terraform_sha256_sum: "6b8ce67647a59b2a3f70199c304abca0ddec0e49fd060944c26f666298e23418",
                          terraform_platform: "linux"

  download_hashicorp_release destination: current_task.name, platform: arguments.terraform_platform,
                             product: "terraform", sha256_sum: arguments.terraform_sha256_sum,
                             version: arguments.terraform_version
end

directory "bin"

file "bin/terraform",
     [:terraform_version, :terraform_sha256_sum, :terraform_platform] => ["tmp/terraform.zip", "bin"] do |current_task|
  extract_hashicorp_release destination: ::File.dirname(current_task.name), source: current_task.prerequisites.first
end

CLOBBER.include "bin/terraform"

file "tmp/terraform-provider-docker.zip", [:version, :sha256_sum, :platform] => ["tmp"] do |current_task, arguments|
  arguments.with_defaults version: "0.1.1",
                          sha256_sum: "08a1fbd839f39910330bc90fed440b4f72a138ea72408482b0adf63c9fbee99b",
                          platform: "linux"
  download_hashicorp_release destination: current_task.name, platform: arguments.platform,
                             product: "terraform-provider-docker", sha256_sum: arguments.sha256_sum,
                             version: arguments.version
end

file "tmp/terraform-provider-local.zip", [:version, :sha256_sum, :platform] => ["tmp"] do |current_task, arguments|
  arguments.with_defaults version: "1.1.0",
                          sha256_sum: "b8786e14e8a04f52cccdf204a5ebc1d3754e5ac848d330561ac55d4d28434d00",
                          platform: "linux"
  download_hashicorp_release destination: current_task.name, platform: arguments.platform,
                             product: "terraform-provider-local", sha256_sum: arguments.sha256_sum,
                             version: arguments.version
end

namespace :tests do
  desc "Run all unit tests"
  task :unit do
    puts "Running all unit tests"
    sh "#{rspec_binstub} --backtrace"
  end

  namespace :integration do
    desc "Run integration tests for basic functionality"

    task :basic, [:terraform_version, :terraform_sha256_sum, :terraform_platform] => ["bin/terraform"] do |current_task|
      puts "Running integration tests for basic functionality"
      execute_kitchen_terraform grep_pattern: "Test Summary: 1 successful, 0 failures, 0 skipped" \
                                ".*1 example, 0 failures.*" \
                                "3 examples, 0 failures",
                                terraform_path: current_task.prerequisites.first,
                                working_directory: "integration/basic"
    end

    desc "Run integration tests for no outputs defined"

    task :no_outputs_defined,
         [:terraform_version, :terraform_sha256_sum, :terraform_platform] => ["bin/terraform"] do |current_task|
      puts "Running integration tests for no outputs defined"

      execute_kitchen_terraform grep_pattern: "Test Summary: 1 successful, 0 failures, 0 skipped",
                                terraform_path: current_task.prerequisites.first,
                                working_directory: "integration/no_outputs_defined"
    end

    desc "Run integration tests for Rake tasks"

    task :rake_tasks,
         [:terraform_version, :terraform_sha256_sum, :terraform_platform] => ["bin/terraform"] do |current_task|
      puts "Running integration tests for Rake tasks"

      execute_kitchen_terraform_via_rake grep_pattern: "Test Summary: 1 successful, 0 failures, 0 skipped.*Test " \
                                         "Summary: 1 successful, 0 failures skipped",
                                         terraform_path: current_task.prerequisites.first,
                                         working_directory: "integration/rake_tasks"
    end

    desc "Run integration tests for shell words"

    task :shell_words,
         [
           :terraform_version, :terraform_sha256_sum, :terraform_platform, :terraform_provider_docker_version,
           :terraform_provider_docker_sha256_sum, :terraform_provider_local_version,
           :terraform_provider_local_sha256_sum,
         ] => ["bin/terraform"] do |current_task, arguments|
      puts "Running integration tests for shell words"

      ::Rake::Task.[]("integration/Shell Words/Plugin Directory/terraform-provider-docker")
        .invoke(arguments.terraform_provider_docker_version, arguments.terraform_provider_docker_sha256_sum,
                arguments.terraform_platform)

      ::Rake::Task.[]("integration/Shell Words/Plugin Directory/terraform-provider-local")
        .invoke(arguments.terraform_provider_local_version, arguments.terraform_provider_local_sha256_sum,
                arguments.terraform_platform)

      execute_kitchen_terraform grep_pattern: "Test Summary: 1 successful, 0 failures, 0 skipped.*Test Summary: 3 " \
                                "successful, 0 failures, 0 skipped",
                                terraform_path: current_task.prerequisites.first,
                                working_directory: "integration/Shell Words"
    end

    directory "integration/Shell Words/Plugin Directory"
    CLOBBER.include "integration/Shell Words/Plugin Directory/*"

    file "integration/Shell Words/Plugin Directory/terraform-provider-docker",
         [:version, :sha256_sum, :platform] => [
           "tmp/terraform-provider-docker.zip",
           "integration/Shell Words/Plugin Directory",
         ] do |current_task|
      prerequisites = current_task.prerequisites

      extract_hashicorp_release destination: prerequisites.last, source: prerequisites.first
    end

    file "integration/Shell Words/Plugin Directory/terraform-provider-local",
         [:version, :sha256_sum, :platform] => [
           "tmp/terraform-provider-local.zip", "integration/Shell Words/Plugin Directory",
         ] do |current_task|
      prerequisites = current_task.prerequisites

      extract_hashicorp_release destination: prerequisites.last, source: prerequisites.first
    end
  end

  desc "Run all integration tests"
  task :integration,
       [
         :terraform_version, :terraform_sha256_sum, :terraform_platform, :terraform_provider_docker_version,
         :terraform_provider_docker_sha256_sum, :terraform_provider_local_version,
         :terraform_provider_local_sha256_sum,
       ] => ["tests:integration:basic", "tests:integration:no_outputs_defined", "tests:integration:shell_words"]
end

desc "Run all tests"
task :tests,
     [
       :terraform_version, :terraform_sha256_sum, :terraform_platform, :terraform_provider_docker_version,
       :terraform_provider_docker_sha256_sum, :terraform_provider_local_version, :terraform_provider_local_sha256_sum,
     ] => ["tests:unit", "tests:integration"]
task default: "tests"
