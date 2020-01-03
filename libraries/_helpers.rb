
def generate_node_exporter_config()
  @config = ''
  node['holmes-node-exporter']['config']['options'].each do |config_key, config_value|
    case config_value
    when '', nil
    else
      @config << " --#{config_key}=#{config_value}"
    end
  end
  node['holmes-node-exporter']['config']['collectors'].each do |config_key, config_value|
    case config_value
    when true
      @config << " --collector.#{config_key}"
    when false
      @config << " --no-collector.#{config_key}"
    else
    end
  end
  @config
end
