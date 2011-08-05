default[:kafka][:zookeeper_boxes] = 1
default[:kafka][:zookeeper_role] = 'zookeeper_server'

default[:kafka][:distribution] = 'kafka-0.6'
default[:kafka][:source] = 'http://sna-projects.com/kafka/downloads/'

default[:kafka][:logrotate_freq] = 'daily'
default[:kafka][:logrotate_rotate] = 14
