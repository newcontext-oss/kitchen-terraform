# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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
require "rake/tasklib"

module Test
  module Kitchen
    module Terraform
      # Rake Tasks for testing
      class RakeTasks < ::Rake::TaskLib
        def initialize(config = {})
          self.loader = ::Kitchen::Loader::YAML.new(
            project_config: ENV["KITCHEN_YAML"],
            local_config: ENV["KITCHEN_LOCAL_YAML"],
            global_config: ENV["KITCHEN_GLOBAL_YAML"],
          )
          self.config = ::Kitchen::Config.new({ loader: loader }.merge(config))
          ::Kitchen.logger = ::Kitchen.default_file_logger nil, false
          define
        end

        private

        attr_accessor :config, :loader

        def define
          namespace "kitchen" do
            define_test_instances
            define_platforms
          end
        end

        def define_all_task(instances:)
          task "all" do
            instances.each_entry(&:test)
          end
        end

        def define_platform(instances:, name:)
          namespace name do
            desc "Run all #{name} test instances"
            define_all_task instances: instances
          end
        end

        def define_platforms
          config.instances.get_all(/.+/).group_by(&:platform).each_pair do |platform, instances|
            define_platform instances: instances, name: platform.name
          end
        end

        def define_test_instances
          config.instances.each do |instance|
            define_test_task instance: instance, name: instance.name
          end
        end

        def define_test_task(instance:, name:)
          desc "Run #{name} test instance"
          task name do
            instance.test(:always)
          end
        end
      end
    end
  end
end
