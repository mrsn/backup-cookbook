#
# Cookbook Name:: backup
# Attributes:: default
#
# Copyright 2011, Cramer Development, Inc.
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
#

case node.platform
when 'ubuntu', 'debian'
  default.backup.dependencies = ['libxml2-dev', 'libxslt-dev']
when 'centos'
  default.backup.dependencies = ['gcc', 'libxml2', 'libxml2-devel', 'libxslt', 'libxslt-devel']
else
  default.backup.dependencies = ['gcc', 'libxml2', 'libxml2-devel', 'libxslt', 'libxslt-devel']
end

default.backup.config_path = '/etc/backup'
default.backup.log_path = '/var/log'
default.backup.model_path = "#{node.backup.config_path}/models"
default.backup.user = 'root'
default.backup.group = 'root'
default.backup.version = '3.7.7'
default.backup.upgrade_flag = true
default.backup.server = {}
default.backup.local_directories = ['/tmp/backup', '/home/vagrant']
