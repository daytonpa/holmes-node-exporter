#
# Cookbook:: holmes-node-exporter
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

arch = if node['kernel']['machine'] == 'x86_64'
         'amd64'
       else
         '386'
       end

node_exporter_version = node['holmes-node-exporter']['version']
node_exporter_log_dir = File.expand_path(File.dirname(node['holmes-node-exporter']['path']['logs']))

group node['holmes-node-exporter']['group'] do
  system true
  only_if { node['holmes-node-exporter']['group'] != 'root' }
end
user node['holmes-node-exporter']['user'] do
  group node['holmes-node-exporter']['group']
  system true
  only_if { node['holmes-node-exporter']['user'] != 'root' }
end

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

remote_file 'node_exporter' do
  owner node['holmes-node-exporter']['user']
  group node['holmes-node-exporter']['group']
  path "#{Chef::Config[:file_cache_path]}/node_exporter-#{node_exporter_version}.linux-#{arch}.tar.gz"
  source "https://github.com/prometheus/node_exporter/releases/download/v#{node_exporter_version}/node_exporter-#{node_exporter_version}.linux-#{arch}.tar.gz"
  notifies :run, 'execute[unpack_and_install_node_exporter]', :immediately
end
execute 'unpack_and_install_node_exporter' do
  cwd Chef::Config[:file_cache_path]
  command <<-COMMAND
    tar -xzf node_exporter-#{node_exporter_version}.linux-#{arch}.tar.gz --strip-components=1 && \
      mv #{Chef::Config[:file_cache_path]}/node_exporter #{node['holmes-node-exporter']['path']['bin']}
  COMMAND
  action :nothing
end

# Create a PID file for the node_exporter daemon
file node['holmes-node-exporter']['path']['pid'] do
  owner node['holmes-node-exporter']['user']
  group node['holmes-node-exporter']['group']
  mode '0644'
end

# Create a directory and file for logs
directory node_exporter_log_dir do
  owner node['holmes-node-exporter']['user']
  group node['holmes-node-exporter']['group']
  mode '0750'
end
file node['holmes-node-exporter']['path']['logs'] do
  owner node['holmes-node-exporter']['user']
  group node['holmes-node-exporter']['group']
  mode '0640'
end

# Generate the systemd file for node_exporter
template '/etc/systemd/system/node_exporter.service' do
  owner node['holmes-node-exporter']['user']
  group node['holmes-node-exporter']['group']
  source 'node_exporter.service.erb'
  notifies :run, 'execute[reload]', :immediately
end
execute 'reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

service 'node_exporter' do
  supports reload: true, restart: true
  action %i( start enable )
end
