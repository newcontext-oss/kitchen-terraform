# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kitchen"
require "kitchen/driver/terraform"
require "kitchen/terraform/client"
require "kitchen/terraform/verify_client_version"
require "kitchen/terraform/verify_directory"

# Verifies that a supported version of the Terraform command line client is available and that the plan and state files
# are accessible.
::Kitchen::Driver::Terraform::VerifyDependencies = lambda do
  catch :failure do
    catch :success do
      ::Kitchen::Terraform::Client::Version.call config: config, logger: debug_logger
    end.tap do |version|
      catch :success do
        ::Kitchen::Terraform::VerifyClientVersion.call version: version
      end.tap do |verified_client_version|
        logger.warn verified_client_version
      end
    end
    [config.fetch(:directory), ::File.dirname(config.fetch(:plan)), ::File.dirname(config.fetch(:state))]
      .each do |directory|
        catch :success do
          ::Kitchen::Terraform::VerifyDirectory.call directory: directory
        end.tap do |verified_directory|
          logger.debug verified_directory
        end
      end
    return
  end.tap do |failure|
    raise ::Kitchen::UserError, failure
  end
end
