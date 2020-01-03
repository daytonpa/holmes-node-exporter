

default['holmes-node-exporter'].tap do |hne|
  hne['user'] = 'node_exporter'
  hne['group'] = 'node_exporter'
  hne['version'] = '0.18.1'

  hne['cron'].tap do |c|
    c['minute'] = '0'
    c['hour'] = '*/12'
  end

  hne['path'].tap do |path|
    path['bin'] = '/usr/bin/node_exporter'
    path['logs'] = '/var/log/node_exporter/node_exporter.logs'
    path['pid'] = '/var/run/node_exporter.pid'
  end

  hne['config']['options'].tap do |opt|
    opt['web.listen-address'] = ':9100'
    opt['web.telemetry-path'] = '/metrics'
    opt['web.max-requests'] = nil
    opt['log.level'] = 'info'
    opt['log.format'] = 'logger:stderr'
  end
  hne['config']['collectors'].tap do |collect|
    collect['arp'] = true
    collect['bcache'] = true
    collect['bonding'] = true
    collect['buddyinfo'] = false
    collect['conntrack'] = true
    collect['cpu'] = true
    collect['cpufreq'] = true
    collect['diskstats'] = true
    collect['drbd'] = false
    collect['edac'] = true
    collect['entropy'] = true
    collect['filefd'] = true
    collect['filesystem'] = true
    collect['hwmon'] = true
    collect['infiniband'] = true
    collect['interrupts'] = false
    collect['ipvs'] = true
    collect['ksmd'] = false
    collect['loadavg'] = true
    collect['logind'] = false
    collect['mdadm'] = true
    collect['meminfo'] = true
    collect['meminfo_numa'] = false
    collect['mountstats'] = false
    collect['netclass'] = true
    collect['netdev'] = true
    collect['netstat'] = true
    collect['nfs'] = true
    collect['nfsd'] = true
    collect['ntp'] = true
    collect['perf'] = false
    collect['pressure'] = true
    collect['processes'] = true
    collect['qdisc'] = false
    collect['runit'] = false
    collect['sockstat'] = true
    collect['stat'] = true
    collect['supervisord'] = false
    collect['systemd'] = true
    collect['tcpstat'] = false
    collect['textfile'] = true
    collect['time'] = true
    collect['timex'] = true
    collect['uname'] = true
    collect['vmstat'] = true
    collect['wifi'] = false
    collect['xfs'] = true
    collect['zfs'] = true
  end
end
