#
# Cloudera repo
#

# Dummy apt-get resource, will only be run if the apt repo requires updating
execute("apt-get update"){ action :nothing }

# Add cloudera package repo
template "/etc/apt/sources.list.d/cloudera.list" do
  owner "root"
  mode "0644"
  source "apt-sources-cloudera.list.erb"
  notifies :run, resources("execute[apt-get update]")
end
# Get the archive key for cloudera package repo
execute "curl -s http://archive.cloudera.com/debian/archive.key | apt-key add -" do
  not_if "apt-key export 'Cloudera Apt Repository' | grep 'BEGIN PGP PUBLIC KEY'"
  notifies :run, resources("execute[apt-get update]"), :immediately
end
