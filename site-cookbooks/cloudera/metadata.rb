# http://wiki.opscode.com/display/chef/Metadata
maintainer        "Eric Hauser"
maintainer_email  "ehauser@exacttarget.com"
license           "Apache 2.0"
description       "Cloudera APT"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "0.0.1"
depends           "apt"

%w{ debian ubuntu }.each do |os|
  supports os
end
