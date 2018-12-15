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
            define_orchestrated_with_remote_backends
            define_orchestrated_without_remote_backends
            define_workspace_both
          end
        end

        def define_orchestrated_with_remote_backends
          desc "Run orchestrated test instances with remote backends"
          task "orchestrated-with-remote-backends": [
            "test:kitchen:attributes-default",
            "test:kitchen:backend-ssh-default",
            "test:kitchen:plug-ins-default",
            "test:kitchen:variables-default",
            "test:kitchen:workspace-both",
          ]
        end

        def define_orchestrated_without_remote_backends
          desc "Run orchestrated test instances without remote backends"
          task "orchestrated-without-remote-backends": [
                 "test:kitchen:attributes-default",
                 "test:kitchen:plug-ins-default",
                 "test:kitchen:variables-default",
                 "test:kitchen:workspace-both",
               ]
        end

        def define_workspace_both
          desc "Run workspace test instances"
          task "workspace-both" do
            workspace_workflow
          end
        end

        def workspace_workflow
          config.instances.get_all(/workspace/).each(&:converge).each(&:verify).each(&:destroy)
        end
      end
    end
  end
end
