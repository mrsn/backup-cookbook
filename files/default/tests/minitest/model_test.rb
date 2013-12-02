require 'minitest/spec'
require File.expand_path('../support/helpers', __FILE__)

describe 'backup_test::model' do
  include Helpers::Backup

  it 'ensures the backup model configuration exists' do
    file(node.backup.config_path + '/models/backup.rb').must_have(:mode, '600')
    .with(:owner, node.backup.user)
    .and(:group, node.backup.group)
  end

  it 'ensures the model file has the global configuration' do
    backup_config = Chef::DataBagItem.load('backup_config', (node.fqdn).gsub('.', '_'))
    model_file = file(node.backup.config_path + '/models/backup.rb')
    model_file.must_include("Backup::Model.new('backup-for-#{node.fqdn}', 'backup model for #{node.fqdn}')")
    model_file.must_include("split_into_chunks_of #{backup_config['split_into_chunks_of']}")
  end

  it 'ensures the model file has archives backup configuration' do
    backup_config = Chef::DataBagItem.load('backup_config', (node.fqdn).gsub('.', '_'))
    model_file = file(node.backup.config_path + '/models/backup.rb')

    backup_config['archives'].each_pair do |model_name, configuration|
      model_file.must_include("archive '#{model_name}'")
      model_file.must_include("archive.add '#{configuration['add']}'")
      model_file.must_include("archive.exclude '#{configuration['exclude']}'")
    end
  end

  it 'ensures the model file has the sftp backup configuration' do
    backup_config = Chef::DataBagItem.load('backup_config', (node.fqdn).gsub('.', '_'))
    model_file = file(node.backup.config_path + '/models/backup.rb')
    backup_config['storages'].each_pair do |storage_type, configuration|
      model_file.must_include("store_with #{storage_type} do |server|")
      model_file.must_include("server.username = '#{configuration['username']}'")
      model_file.must_include("server.password = '#{configuration['password']}'")
      model_file.must_include("server.ip = '#{configuration['ip']}'")
      model_file.must_include("server.port = '#{configuration['port']}'")
      model_file.must_include("server.path = '#{configuration['path']}'")
      model_file.must_include("server.keep = #{configuration['keep']}")
    end
  end

  it 'ensures the model file has the database backup configuration' do
   backup_config = Chef::DataBagItem.load('backup_config', (node.fqdn).gsub('.', '_'))
   model_file = file(node.backup.config_path + '/models/backup.rb')
   backup_config['databases'].each_pair do |database_type, configuration|
     model_file.must_include("database #{database_type} do |db|")
     model_file.must_include("db.name = '#{configuration['name']}'") unless configuration['name'].nil?
     model_file.must_include("db.username = '#{configuration['username']}'")
     model_file.must_include("db.password = '#{configuration['password']}'")
     model_file.must_include("db.host = '#{configuration['host']}'")
     model_file.must_include("db.port = #{configuration['port']}")
     model_file.must_include("db.skip_tables = #{configuration['skip_tables']}")
     model_file.must_include("db.only_tables = #{configuration['only_tables']}")
     model_file.must_include("db.additional_options = #{configuration['additional_options']}")
   end
  end

  it 'ensures the model file has the notifications configuration' do
   backup_config = Chef::DataBagItem.load('backup_config', (node.fqdn).gsub('.', '_'))
   model_file = file(node.backup.config_path + '/models/backup.rb')
   backup_config['notifiers'].each_pair do |notifier_type, configuration|
     if notifier_type == 'Zabbix'
       model_file.must_include("notify_by #{notifier_type} do |notifier|")
       model_file.must_include("notifier.on_success = #{configuration['on_success']}")
       model_file.must_include("notifier.on_warning = #{configuration['on_warning']}")
       model_file.must_include("notifier.on_failure = #{configuration['on_failure']}")
       model_file.must_include("notifier.zabbix_host = '#{node.zabbix_notifier.host}'")
       model_file.must_include("notifier.zabbix_port = #{node.zabbix_notifier.port}")
       model_file.must_include("notifier.service_name = 'Backup trigger for #{node.ipaddress}'")
       model_file.must_include("notifier.service_host = '#{node.fqdn}'")
       model_file.must_include("notifier.item_key = '#{configuration['item_key']}")
     elsif notifier_type == 'Mail'
     else
     end
   end
  end

  it 'ensures the cronjob is correct configured' do
    backup_config = Chef::DataBagItem.load('backup_config', (node.fqdn).gsub('.', '_'))
    file_path = "/etc/cron.d/backup-job-for-#{node.fqdn}"
    file(file_path).must_have(:mode, '644')
    .with(:owner, 'root')
    .and(:group, 'root')

    cron_schedule = "#{backup_config['cron_job_schedule']['minute']}" + 
      " #{backup_config['cron_job_schedule']['hour']}" +
      " #{backup_config['cron_job_schedule']['day']}" +
      " #{backup_config['cron_job_schedule']['month']}" +
      " #{backup_config['cron_job_schedule']['weekday']}"

    file(file_path).must_include(cron_schedule)

    cmd = "#{node.backup.bin_path} perform" +
      " -t backup-for-#{node.fqdn} --config-file #{node.backup.config_path}/config.rb" +
      " --log-path=#{node.backup.log_path} > /dev/null"

    file(file_path).must_include(cmd)
  end
end
