require 'minitest/spec'
require File.expand_path('../support/helpers', __FILE__)

describe 'zabbix::default' do
  include Helpers::Backup

  it 'ensures all the dependecies are installed' do
    (node.backup.dependencies).each do |dependency|
      package(dependency).must_be_installed
    end
  end

  it 'ensures the backup gem is installed' do
    skip('not implemented yet')
    #gem('backup').must_be_installed
  end

  it 'ensures the config directory exists' do
    directory(node.backup.config_path).must_have(:mode, '700')
      .with(:owner, node.backup.user)
      .and(:group, node.backup.group)
  end

  it 'ensures the log directory exists' do
    directory(node.backup.log_path).must_have(:mode, '700')
      .with(:owner, node.backup.user)
      .and(:group, node.backup.group)
  end

  it 'ensures the model directory exists' do
    directory(node.backup.model_path).must_have(:mode, '700')
      .with(:owner, node.backup.user)
      .and(:group, node.backup.group)
  end

  it 'ensures the backup main configuration exists' do
    file(node.backup.config_path + '/config.rb').must_have(:mode, '600')
    .with(:owner, node.backup.user)
    .and(:group, node.backup.group)
  end

  it 'ensures the backup model configuration exists' do
    file(node.backup.config_path + '/models/backup.rb').must_have(:mode, '600')
    .with(:owner, node.backup.user)
    .and(:group, node.backup.group)
  end

  it 'ensures all the config files have the right content' do
    skip('not implemented yet')
  end

end


