if Chef::Config[:solo]
  backup_config = Chef::DataBagItem.load('backup_config', (node.fqdn).gsub('.', '_'))
else
  backup_config = Chef::EncryptedDataBagItem.load('backup_config', data_bag_item)
end

backup_name = "backup-for-#{node.fqdn}"

model_configuration_container = {
  :name        => backup_name,
  :description => "backup model for #{node.fqdn}",
  :split_into_chunks_of => backup_config['split_into_chunks_of']
}

if backup_config['archives'].nil?
  model_configuration_container.merge!({'archives' => {}})
else
  model_configuration_container.merge!({'utilities' => backup_config['utilities']})
end

  utilities = { 
    :pg_dump  => "/opt/chef-server/embedded/bin/pg_dumpall",
    :pg_dumpall => "/opt/chef-server/embedded/bin/pg_dump"
  }

if backup_config['archives'].nil?
  model_configuration_container.merge!({'archives' => {}})
else
  model_configuration_container.merge!({ 'archives' => backup_config['archives'] })
end

if backup_config['storages'].nil?
  model_configuration_container.merge!({'storages' => {}})
else
  model_configuration_container.merge! ({ 'storages' => backup_config['storages'] })
end

if backup_config['databases'].nil?
  model_configuration_container.merge!({'databases' => {}})
else
  model_configuration_container.merge! ({ 'databases' => backup_config['databases'] })
end

if backup_config['notifiers'].nil?
  model_configuration_container.merge!({'notifiers' => {}})
else
  temp_configuration = backup_config['notifiers']
  temp_configuration.each_pair do |notification_type, configuration|
    if notification_type == 'Zabbix'
      temp_configuration['Zabbix']['zabbix_host'] = node.zabbix_notifier.host
      temp_configuration['Zabbix']['zabbix_port'] = node.zabbix_notifier.port
      temp_configuration['Zabbix']['service_name'] = 'Backup trigger for ' + node.ipaddress
      temp_configuration['Zabbix']['service_host'] = node.fqdn
    end
    #TODO: make this work for mail
    raise 'Notification work only for zabbix at the moment' if notification_type == 'Mail'
  end
  model_configuration_container.merge! ({ 'notifiers' => temp_configuration })
end

template 'Creating the model file' do
  path ::File.join(node.backup.config_path, '/models/backup.rb')
  source 'model.rb.erb'
  owner node.backup.user
  group node.backup.group
  variables model_configuration_container
  mode '0600'
  action :create
end

backup_command = "#{node.backup.bin_path} perform" +
  " -t #{backup_name} --config-file #{node.backup.config_path}/config.rb" +
  " --log-path=#{node.backup.log_path} > /dev/null"

cron_d "backup-job-for-#{node.fqdn}" do
  command backup_command
  minute backup_config['cron_job_schedule']['minute']
  hour backup_config['cron_job_schedule']['hour']
  day backup_config['cron_job_schedule']['day']
  month backup_config['cron_job_schedule']['month']
  weekday backup_config['cron_job_schedule']['weekday']
end
