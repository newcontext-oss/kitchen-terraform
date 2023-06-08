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

output "insensitive_string" {
  value = "insensitive-value"
}

output "sensitive_string" {
  value     = "sensitive-value"
  sensitive = true
}

output "list_of_objects" {
  value = [
    {
      first_name = "value"
    },
    {
      second_name = "value"
    }
  ]
}
