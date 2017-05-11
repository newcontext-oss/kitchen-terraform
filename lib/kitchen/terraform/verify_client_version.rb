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

require "kitchen/terraform"

::Kitchen::Terraform::VerifyClientVersion = lambda do |version:|
  (0.7..0.9).cover? version or
    throw :failure, "Terraform version #{version} is not supported; supported versions are 0.7 through 0.9"
  (0.7..0.8).cover? version and
    throw :success, "Support for Terraform version #{version} is deprecated and will be dropped in kitchen-terraform " \
                      "version 2.0; upgrade to Terraform version 0.9"
  throw :success, "Support for Terraform version #{version} will continue until at least kitchen-terraform version 2.0"
end
