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

require "kitchen/driver/terraform"

::Kitchen::Driver::Terraform::VerifyClientVersion = lambda do |client:, logger:|
  client.version.tap do |version|
    /0\.[7-9]/.match? version or
      raise ::Kitchen::UserError,
            "Terraform version #{version} is not supported; supported Terraform versions are 0.7 through 0.9"
    /0\.[7-8]/.match? version and
      logger.warn "Support for Terraform version #{version} is deprecated and will be dropped in " \
                    "kitchen-terraform version 2.0; upgrade to Terraform version 0.9"
  end
end

require "kitchen"
