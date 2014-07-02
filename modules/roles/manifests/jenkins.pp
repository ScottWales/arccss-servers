## \file    modules/roles/manifests/jenkins.pp
#  \author  Scott Wales <scott.wales@unimelb.edu.au>
#
#  Copyright 2014 ARC Centre of Excellence for Climate Systems Science
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

# Sets up a Jenkins install with NCI LDAP auth, and builds a Docker image to
# use as a build slave

class roles::jenkins (
  $proxyip = '127.0.0.1',
) {

  # Hardcoded by Jenkins module
  $home    = '/var/lib/jenkins'

  include ::jenkins
  include ::roles::jenkins::dockerimage
  include ::roles::jenkins::config
  include ::roles::jenkins::backup

  # Open a port for the proxy
  firewall {'500 proxy to jenkins':
    source => $proxyip,
    port   => 8080,
    action => accept,
  }

  @::roles::apache::proxy {'/jenkins':
    vhost => 'proxy',
    url   => "http://${ipaddress_eth0}:8080"
  }

}
