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
  default.backup.dependencies = ['libxml2-dev', 'libxslt-dev', 'mysql-client']
when 'centos'
  default.backup.dependencies = ['gcc', 'libxml2', 'libxml2-devel', 'libxslt', 'libxslt-devel', 'mysql']
else
  default.backup.dependencies = ['gcc', 'libxml2', 'libxml2-devel', 'libxslt', 'libxslt-devel', 'mysql']
end

default.backup.config_path = '/etc/backup'
default.backup.log_path = '/var/log/backup'
default.backup.model_path = "#{node.backup.config_path}/models"
default.backup.bin_path = '/opt/chef/embedded/bin/backup'
default.backup.user = 'root'
default.backup.group = 'root'
default.backup.version = '3.7.7'
default.backup.upgrade_flag = true
default.backup.server = {}

default.zabbix_notifier.host = '192.168.33.33'
default.zabbix_notifier.port = 10051
