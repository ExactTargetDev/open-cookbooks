#
# Cookbook Name:: zookeeper
# Recipe:: default
#
# Copyright 2010, Infochimps, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#include_recipe "hadoop_cluster"
include_recipe "cloudera"

group 'zookeeper' do gid 305 ; action [:create] ; end
user 'zookeeper' do
  comment    'Hadoop Zookeeper Daemon'
  uid        305
  group      node[:groups]['zookeeper'][:gid]
  home       "/var/zookeeper"
  shell      "/bin/false"
  password   nil
  supports   :manage_home => true
  action     [:create, :manage]
end

package "hadoop-zookeeper"

#
# Configuration files

directory node[:zookeeper][:data_dir] do
  owner      "zookeeper"
  group      "zookeeper"
  mode       "0755"
  action     :create
  recursive  true
end

directory node[:zookeeper][:log_dir] do
  owner      "zookeeper"
  group      "zookeeper"
  mode       "0755"
  action     :create
  recursive  true
end

zk_server_ips = wait_for("zookeeper", node[:zookeeper][:boxes]) { fqdns_for_role("#{node[:zookeeper][:server_role]}") }

myid = 0
zookeeper_nodes = zk_server_ips.sort
zookeeper_nodes.length.times do |j|
  if zookeeper_nodes[j] == node[:fqdn] then
    myid = j
  end
end

template_variables = {
  :zookeeper_server_ips   => zk_server_ips.sort,
  :myid                   => myid,
  :zookeeper_data_dir     => node[:zookeeper][:data_dir],
  :zookeeper_max_client_connections => node[:zookeeper][:max_client_connections] || 30,
}
Chef::Log.debug template_variables.inspect
%w[ zoo.cfg log4j.properties].each do |conf_file|
  template "/etc/zookeeper/#{conf_file}" do
    owner "root"
    mode "0644"
    variables(template_variables)
    source "#{conf_file}.erb"
  end
end

template "/var/zookeeper/myid" do
 owner "zookeeper"
 mode "0644"
 variables(template_variables)
 source "myid.erb"
end

template "/usr/bin/zookeeper-server" do
 owner "zookeeper"
 mode "0731"
 source "zookeeper-server.erb"
end
