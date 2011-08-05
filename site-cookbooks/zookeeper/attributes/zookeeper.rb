default[:groups]['zookeeper'][:gid] = 305

default[:zookeeper][:server_role] = 'zookeeper_server'
default[:zookeeper][:data_dir] = '/var/zookeeper'
default[:zookeeper][:log_dir] = '/var/log/zookeeper'
default[:zookeeper][:max_client_connections] = 30

default[:zookeeper][:boxes] = 2

default[:zookeeper][:logrotate_freq] = 'daily'
default[:zookeeper][:logrotate_rotate] = 14
default[:zookeeper][:provider_name] = 'zookeeper_server'

default[:zookeeper][:java_options] = '-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=9501'
