#
# Cookbook Name:: kafka
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "unzip"

remote_file "/tmp/".concat(node[:kafka][:distribution]).concat(".zip") do
  source node[:kafka][:source].concat(node[:kafka][:distribution]).concat(".zip")
  mode "755"
  action :create_if_missing
end

execute "Untar Kafka" do
  command "unzip -qo /tmp/#{node[:kafka][:distribution]}.zip -d /tmp/"
  action :run
end

execute "Copy Kafka to installation dir." do
  command "cp -fr /tmp/kafka /usr/local"
  action :run
end

directory "/var/log/kafka" do
  mode "0755"
  action :create
end

logrotate_app "kafka" do
  cookbook "kafka"
  template "kafka-rotate.erb"
  path [ "/var/log/kafka/*.log" ]
  frequency node[:kafka][:logrotate_freq]
  create "644 root root"
  rotate node[:kafka][:logrotate_rotate]
end

zookeeper_pairs = wait_for("Zookeeper", node[:kafka][:zookeeper_boxes], 10) { fqdns_for_role("#{node[:kafka][:zookeeper_role]}") }
i = 0
while i < zookeeper_pairs.size do
  zookeeper_pairs[i] = zookeeper_pairs[i].concat(":2181")
  i += 1
end
#loop_count = 10
#boxes = node[:kafka][:zookeeper_boxes]
#print "Waiting for all ZooKeeper instances...\n"
#while loop_count > 0
#  zookeeper_pairs = []
#  search(:node, "run_list:role\\[#{node[:kafka][:zookeeper_role]}\\] AND chef_environment:#{node.chef_environment}") do |zkn|
#    zookeeper_pairs << "#{zkn.fqdn}:2181"
#  end

#  print zookeeper_pairs.length.to_s.concat(" of ").concat(boxes.to_s).concat(" available...\n")
#  if zookeeper_pairs.length == boxes then
#    break
#  end
#  sleep 3 * loop_count
#  loop_count -= 1
#end

template "/usr/local/kafka/config/server.properties" do
  variables(
    :zookeeper_pairs => zookeeper_pairs
  )
  source "server.properties.erb"
end

template "/usr/local/kafka/bin/kafka-run-class.sh" do
  source "kafka-run-class.sh.erb"
  mode 0755
end

case node[:platform]
when "ubuntu"
  template "/etc/init/kafka.conf" do
    source "kafka-init.erb"
  end

  execute "Stop Kafka if running." do
    command "stop kafka; sleep 5"
    returns [0,1]
    user "root"
    action :run
  end

  execute "Start Kafka using upstart." do
    command "start kafka"
    user "root"
    action :run
  end
when "centos", "redhat", "fedora"
  template "/etc/init.d/kafka" do
    source "kafka.init.erb"
    mode 0755
    backup false
  end

  service "kafka" do
    supports :start => true, :stop => false
    action [:enable, :start]
  end
end
