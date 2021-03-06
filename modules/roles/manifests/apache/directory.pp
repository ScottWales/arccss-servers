## \file    modules/roles/manifests/apache/directory.pp
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

# Create a directory/location segment in a vhost

define roles::apache::directory (
  $vhost,
  $priority        = '20',
  $path            = false,
  $provider        = false,
  $allow           = 'from all',
  $deny            = false,
  $order           = false,
  $satisfy         = false,
  $headers         = false,
  $custom_fragment = '',
) {

  $directory_config = "/etc/httpd/conf.d/${vhost}-directories"

  # Create the hash that the apache module expects
  $_directories = [{
    path            => $path,
    provider        => $provider,
    allow           => $allow,
    deny            => $deny,
    order           => $order,
    satisfy         => $satisfy,
    headers         => $headers,
    custom_fragment => $custom_fragment,
  }]

  # Use the apache directory template for the config
  concat::fragment {$name:
    target  => $directory_config,
    content => template('apache/vhost/_directories.erb'),
    order   => $priority,
  }

}
