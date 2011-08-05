maintainer       "Eric Hauser"
maintainer_email "ehauser@exacttarget.com"
license          "Apache 2.0"
description      "Installs/Configures zookeeper"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

%w{apt logrotate service_discovery cloudera}.each do |d|
  depends d
end
