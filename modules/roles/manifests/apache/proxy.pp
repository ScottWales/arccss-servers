## \file    modules/roles/manifests/apache/proxy.pp
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

# Create a http proxy on a vhost
#
# roles::apache::proxy {'/jenkins':
#   vhost => 'proxy',
#   url   => 'http://jenkins.local:8080',
# }

define roles::apache::proxy (
  $vhost,
  $url,
  $priority = '10',
) {
  include ::apache::mod::proxy
  include ::apache::mod::proxy_http

  $directory_config = "/etc/httpd/conf.d/${vhost}-directories"

  $proxy_pass = {
    'path' => $name,
    'url'  => $url,
  }

  concat::fragment {$name:
    target  => $directory_config,
    content => template('apache/vhost/_proxy.erb'),
    order   => $priority,
  }
}
