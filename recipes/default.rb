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

#if node.platform == 'ubuntu' or node.platform == 'debian'
#  include_recipe 'apt'
#elsif node.platform == 'centos'
#  include_recipe 'yum'
#end

(node.backup.dependencies).each do |dependency|
  package dependency
end

gem_version = node.backup.version
local_gem_path = "/tmp/backup-#{gem_version}.gem"

remote_file local_gem_path do
  source "https://s3-eu-west-1.amazonaws.com/gemrepo/backup-#{gem_version}.gem"
  mode '0644'
  action :create_if_missing
end

gem_package 'backup' do
  version node.backup.version
  source local_gem_path
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

if File.directory?('/opt/chef-server')
  utilities = { 
    :pg_dump  => "/opt/chef-server/embedded/bin/pg_dumpall",
    :pg_dumpall => "/opt/chef-server/embedded/bin/pg_dump"
  }
else
  utilities = {}
end

template 'Creating the config file' do
  path ::File.join(node.backup.config_path, 'config.rb')
  source 'config.rb.erb'
  owner node.backup.user
  group node.backup.group
  variables utilities
  mode '0600'
  action :create
end
