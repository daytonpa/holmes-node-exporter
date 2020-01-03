
def generate_node_exporter_config
  @config = ''
  node['holmes-node-exporter']['config']['options'].each do |config_key, config_value|
    @config << " --#{config_key}=#{config_value}" unless config_value.nil? || config_value == ''
  end
  node['holmes-node-exporter']['config']['collectors'].each do |config_key, config_value|
    case config_value
    when true
      @config << " --collector.#{config_key}"
    when false
      @config << " --no-collector.#{config_key}"
    end
  end
  @config
end
