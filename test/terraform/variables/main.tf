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

terraform {
  required_version = ">= 0.11.4, < 0.13.0"
}

provider "local" {
  version = "~> 1.1"
}

resource "local_file" "string" {
  content  = "${var.string}"
  filename = "${path.module}/string.txt"
}

resource "local_file" "map" {
  content  = "${var.map["key"]}"
  filename = "${path.module}/map.txt"
}

resource "local_file" "list" {
  content  = "${join("; ", var.list)}"
  filename = "${path.module}/list.txt"
}

resource "local_file" "variable_file" {
  content  = "${var.local_file_content_from_variable_file}"
  filename = "${path.module}/variable_file.txt"
}
