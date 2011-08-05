# A simplier version of the service discovery module provided by ClusterChef
#
# Services are discovered via 2 attributes:
#
# - chef_environment
# - role
#
# The service_cluster attribute is a discriminator for when there might be multiple
# types of a given role within a single environment, i.e. running multiple Hadoop clusters
# in a single environment. It is assumed that the node doing the search already belongs to
# the cluster if a specific cluster is not specified.

module ServiceDiscovery
 
  # Find a single node by role
  def node_for_role role
    found = nil
    search(:node, "run_list:role\\[#{role}\\] AND chef_environment:#{node.chef_environment}") do |n|
      found = n
    end
    
    Chef::Log.info "Tried to find a single node of role[#{role}] in environment[#{node.chef_environment}] but failed" if found.nil?
    found
  end

  def fqdn_for_role role
    node = node_for_role(role)
    node.nil? && '0.0.0.0' || fqdn_of(node)
  end

  # Simple helper for just finding nodes by role
  def nodes_for_role role
    Chef::Log.info "Searching for node with role:#{role} and environment:#{node.chef_environment}"
    nodes = search(:node, "run_list:role\\[#{role}\\] AND chef_environment:#{node.chef_environment}")
    Chef::Log.info "Found [#{nodes.join(',')}]"
    nodes
  end

  def fqdns_for_role role
    nodes = nodes_for_role(role)
    nodes.map { |s| fqdn_of(s) }
  end

  def cluster_nodes_for_role role, cluster=nil
    sc = "#{node.service_cluster}" if cluster.nil?
    search(:node, "run_list:role\\[#{role}\\] AND service_cluster:#{sc} AND chef_environment:#{node.chef_environment}")
  end

  def cluster_fqdns_for_role role, cluster=nil
    nodes = cluster_nodes_for_role(role)
    nodes.map { |s| fqdn_of(s) }
  end

  # The local-only ip address for the given server
  def fqdn_of server
    server.attribute?('ec2') ? server[:ec2][:hostname] : server[:fqdn]
  end

  def wait_for descrip, n=1, loop_count=10
    print "Waiting for all #{descrip} instances using service discovery...\n"
    discovered = []
    while loop_count > 0
      discovered = yield
      print "#{discovered.length} of #{n} available...\n"
      if discovered.length == n then
        break
      end
      sleep 3 * loop_count
      loop_count -= 1
    end
    discovered
  end

end

class Chef::Recipe; include ServiceDiscovery; end
class Chef::Recipe::Directory; include ServiceDiscovery; end
class Chef::Resource; include ServiceDiscovery; end
