# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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

require "kitchen/rake_tasks"

module Test
  module Kitchen
    module Terraform
      # Rake Tasks for testing
      class RakeTasks < ::Kitchen::RakeTasks
        private

        def define
          super
          namespace "kitchen" do
            define_doctor
            define_workspaces
          end
        end

        def define_doctor
          config.instances.get_all(/doctor-\w+/).group_by do |instance|
            instance.platform.name
          end.each_pair do |platform_name, instances|
            desc "Run doctor-#{platform_name} test"
            task "doctor-#{platform_name}" do
              instances.each_entry do |instance|
                instance.doctor_action or raise "doctor did not detect an issue"
              end
            end
          end
        end

        def define_workspaces
          config.instances.get_all(/workspace-\w+/).group_by do |instance|
            instance.platform.name
          end.each_pair do |platform_name, instances|
            desc "Run workspaces-#{platform_name} test instances"
            task "workspaces-#{platform_name}" do
              instances.each_entry(&:converge).each_entry(&:verify).each_entry(&:destroy)
            end
          end
        end
      end
    end
  end
end
