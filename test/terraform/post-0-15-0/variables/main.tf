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

terraform {
  required_version = ">= 0.11.4, < 1.1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 1.4"
    }
  }
}

resource "local_file" "string" {
  content  = var.string
  filename = "${path.module}/string.txt"
}

resource "local_file" "map" {
  content  = var.map["key"]
  filename = "${path.module}/map.txt"
}

resource "local_file" "list_of_strings" {
  content  = join("; ", var.list_of_strings)
  filename = "${path.module}/list_of_strings.txt"
}

resource "local_file" "list_of_maps" {
  content  = lookup(var.list_of_maps[0], "key")
  filename = "${path.module}/list_of_maps.txt"
}

resource "local_file" "variable_file" {
  content  = var.local_file_content_from_variable_file
  filename = "${path.module}/variable_file.txt"
}
