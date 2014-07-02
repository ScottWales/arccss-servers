## \file    modules/roles/manifests/proxy.pp
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

class roles::proxy(
  $vhost = $::fqdn,
) {
  include ::apache

  # Forward http connections to https
  ::roles::apache::vhost {'proxy-redirect':
    servername      => $vhost,
    port            => 80,
    redirect_status => permanent,
    redirect_dest   => "https://${vhost}/",
    docroot         => '/var/www/null',
  }

  # Proxy vhost
  ::roles::apache::vhost {'proxy':
    servername => $vhost,
    port       => 443,
    ssl        => true,
    docroot    => '/var/www/null',
  }

  # Collect locations & proxies for the vhost
  ::Roles::Apache::Proxy     <<| vhost == 'proxy' |>>
  ::Roles::Apache::Directory <<| vhost == 'proxy' |>>

}
