#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2011-2012, Cramer Development, Inc.
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

if node.platform == 'ubuntu' or node.platform == 'debian'
  include_recipe 'apt'
elsif node.platform == 'centos'
  include_recipe 'yum'
end

(node.backup.dependencies).each do |dependency|
  package dependency
end

gem_package 'backup' do
  version node.backup.version
  gem_binary '/opt/chef/embedded/bin/gem'
  options '--no-ri --no-rdoc'
  action :upgrade if node.backup.upgrade_flag
end

%w[ config_path model_path log_path ].each do |dir|
  directory node.backup[dir] do
    owner node.backup.user
    group node.backup.group
    mode '0700'
  end
end

#template "Backup config file" do
#  path ::File.join( node['backup']['config_path'], "config.rb")
#  source 'config.rb.erb'
#  owner node['backup']['user']
#  group node['backup']['group']
#  mode '0600'
#end
