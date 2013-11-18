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

template 'Creating the config file' do
  path ::File.join(node.backup.config_path, 'config.rb')
  source 'config.rb.erb'
  owner node.backup.user
  group node.backup.group
  mode '0600'
  action :create
end

if Chef::Config[:solo]
  backup_config = Chef::DataBagItem.load('backup_config', (node.fqdn).gsub('.', '_'))
else
  backup_config = Chef::EncryptedDataBagItem.load('backup_config', data_bag_item)
end

template 'Creating the model file' do
  path ::File.join(node.backup.config_path, '/models/backup.rb')
  source 'model.rb.erb'
  owner node.backup.user
  group node.backup.group
  variables(
    :local_directories                 => backup_config['local_backup_directories'],
    :backup_description                => backup_config['description'],
    :chunk_size_in_mb                  => backup_config['chunk_size_in_mb'],
    :sftp_username                     => backup_config['sftp_username'],
    :sftp_password                     => backup_config['sftp_password'],
    :sftp_server_ip                    => backup_config['sftp_server_ip'],
    :sftp_server_port                  => backup_config['sftp_server_port'] || 22,
    :sftp_server_backup_path           => backup_config['sftp_server_backup_path'],
    :time_to_keep_in_days              => backup_config['time_to_keep_in_days'],
    :compress_with                     => backup_config['compression'],
    :encryption                        => backup_config['encryption_algorithm'],
    :keep_time                         => backup_config['keep_time']
  )
  mode '0600'
  action :create
end
