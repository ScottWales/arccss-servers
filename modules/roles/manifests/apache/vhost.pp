## \file    modules/roles/manifests/apache/vhost.pp
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

# Wrapper around puppetlabs/apache's vhost to support defining locations in
# different parts of the manifest
define roles::apache::vhost (
  $port            = undef,
  $docroot         = undef,
  $virtual_docroot = undef,
  $serveradmin     = undef,
  $ssl             = undef,
  $priority        = undef,
  $servername      = undef,
  $serveraliases   = undef,
  $ip              = undef,
  $options         = undef,
  $override        = undef,
  $vhost_name      = undef,
  $logroot         = undef,
  $log_level       = undef,
  $access_log      = undef,
  $ensure          = undef,
  $headers         = undef,
  $request_headers = undef,
  $aliases         = undef,
  $directories     = undef,
  $redirect_status = undef,
  $redirect_dest   = undef,
  $custom_fragment = undef,
) {
  include apache

  $directory_config = "/etc/httpd/conf.d/${name}-directories"

  ::apache::vhost {$name:
    ensure              => $ensure,
    port                => $port,
    docroot             => $docroot,
    virtual_docroot     => $virtual_docroot,
    serveradmin         => $serveradmin,
    ssl                 => $ssl,
    priority            => $priority,
    servername          => $servername,
    serveraliases       => $serveraliases,
    ip                  => $ip,
    options             => $options,
    override            => $override,
    vhost_name          => $vhost_name,
    logroot             => $logroot,
    log_level           => $log_level,
    access_log          => $access_log,
    headers             => $headers,
    request_headers     => $request_headers,
    aliases             => $aliases,
    directories         => $directories,
    redirect_status     => $redirect_status,
    redirect_dest       => $redirect_dest,
    custom_fragment     => $custom_fragment,
    additional_includes => [$directory_config],
  }

  concat {$directory_config:
    ensure => present,
    notify => Service['httpd'],
  }
  concat::fragment {"${directory_config} header":
    target  => $directory_config,
    order   => '00',
    content => '# Configuration for Vhost directories, Managed by Puppet',
  }
}
