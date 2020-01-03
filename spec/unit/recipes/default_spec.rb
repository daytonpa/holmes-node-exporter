#
# Cookbook:: holmes-node-exporter
# Spec:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'holmes-node-exporter::default' do
  context 'When all attributes are default, on CentOS 7' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7').converge(described_recipe)
    end
    let(:cron) { chef_run.cron('yum') }
    let(:remote_file) { chef_run.remote_file('node_exporter') }
    let(:template) { chef_run.template('/etc/systemd/system/node_exporter.service') }

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates a system user and group for the node exporter service' do
      expect(chef_run).to create_user('node_exporter').with(
        system: true,
        group: 'node_exporter'
      )
      expect(chef_run).to create_group('node_exporter').with(system: true)
    end

    it 'creates a cron job to update YUM, and updates YUM' do
      expect(chef_run).to create_cron('yum').with(
        command: 'yum update -y'
      )
      expect(cron).to notify('execute[yum]').to(:run).immediately
    end

    it 'downloads and installs the node exporter service' do
      expect(chef_run).to create_remote_file('node_exporter').with(
        owner: 'node_exporter',
        group: 'node_exporter'
      )
      expect(remote_file).to notify('execute[unpack_and_install_node_exporter]').to(:run).immediately
    end

    it 'creates a PID file for the node exporter service' do
      expect(chef_run).to create_file('/var/run/node_exporter.pid').with(
        owner: 'node_exporter',
        group: 'node_exporter',
        mode: '0644'
      )
    end

    it 'creates a log directory and log file for the node exporter service' do
      expect(chef_run).to create_directory('/var/log/node_exporter')
      expect(chef_run).to create_file('/var/log/node_exporter/node_exporter.logs')
    end

    it 'creates a systemd file for the node exporter service, and reloads systemd' do
      expect(chef_run).to create_template('/etc/systemd/system/node_exporter.service').with(
        owner: 'node_exporter',
        group: 'node_exporter'
      )
      expect(template).to notify('execute[reload]').to(:run).immediately
    end

    it 'starts and enables the node exporter service' do
      expect(chef_run).to start_service('node_exporter')
      expect(chef_run).to enable_service('node_exporter')
    end
  end
end
