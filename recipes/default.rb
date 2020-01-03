#
# Cookbook:: node_exporter
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

# This is a demo cookbook for testing InSpec Profiles
# We're installing

case node['hostnamectl']['architecture']
when 'x86-64'
  arch = 'amd64'
else
  arch = '386'
end

node_exporter_version = node['holmes-node-exporter']['version']
node_exporter_user = node['holmes-node-exporter']['user']
node_exporter_group = node['holmes-node-exporter']['group']
node_exporter_log_dir = File.expand_path(File.dirname(node['holmes-node-exporter']['path']['logs']))

group node_exporter_group do
  system true
  only_if { node_exporter_group != 'root' }
end
user node_exporter_user do
  group node_exporter_group
  system true
  only_if { node_exporter_user != 'root' }
end

case node['platform']
when 'ubuntu' 

  apt_update 'update' do
    action :periodic
  end

when 'amazon', 'centos'

  cron 'yum' do
    minute node['holmes-node-exporter']['cron']['minute']
    hour node['holmes-node-exporter']['cron']['hour']
    command 'yum update -y'
    notifies :run, 'execute[yum]', :immediately
  end
  execute 'yum' do
    command 'yum update -y'
    action :nothing
  end

end

remote_file 'node_exporter' do
  owner node_exporter_user
  group node_exporter_group
  path "/tmp/node_exporter-#{node_exporter_version}.linux-#{arch}.tar.gz"
  source "https://github.com/prometheus/node_exporter/releases/download/v#{node_exporter_version}/node_exporter-#{node_exporter_version}.linux-#{arch}.tar.gz"
  notifies :run, 'execute[unpack_and_install_node_exporter]', :immediately
  not_if "/usr/bin/node_exporter --version | grep -q #{node_exporter_version}"
end
execute 'unpack_and_install_node_exporter' do
  cwd '/tmp'
  command <<-COMMAND
    tar -xzf node_exporter-#{node_exporter_version}.linux-#{arch}.tar.gz --strip-components=1 && \
      mv /tmp/node_exporter #{node['holmes-node-exporter']['path']['bin']}
  COMMAND
  not_if 'systemctl status node_exporter | grep -q "active (running)"'
end

# Create a PID file for the node_exporter daemon
file node['holmes-node-exporter']['path']['pid'] do
  owner node_exporter_user
  group node_exporter_group
  mode '0644'
end

# Create a directory and file for logs
directory node_exporter_log_dir do
  owner node_exporter_user
  group node_exporter_group
  mode '0750'
end
file node['holmes-node-exporter']['path']['logs'] do
  owner node_exporter_user
  group node_exporter_group
  mode '0640'
end

# Generate the systemd file for node_exporter
template '/etc/systemd/system/node_exporter.service' do
  owner node_exporter_user
  group node_exporter_group
  source 'node_exporter.service.erb'
  notifies :run, 'execute[reload]', :immediately
end
execute 'reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

service 'node_exporter' do
  supports :reload => true, :restart => true
  action %i(start enable)
end
