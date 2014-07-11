## \file    modules/roles/manifests/elasticsearch.pp
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

# Create an elasticsearch instance hiding behind a proxy
# Elasticsearch doesn't let us control what can be accessed, so we use Nginix
# to enable that

class roles::elasticsearch {
  include roles::webserver

  include ::elasticsearch
  include java
  include apache
  include kibana

  Class['java']   -> Class['::elasticsearch']
  Package['wget'] -> Class['::elasticsearch']

  # Setup backups
  file {'/sbin/elasticsearch-backup':
    ensure => present,
    source => 'puppet:///modules/roles/elasticsearch-backup',
    mode   => '0500',
    owner  => 'root',
  }
  cron {'elasticsearch-backup':
    command => '/sbin/elasticsearch-backup',
    user    => 'root',
    hour    => 1,
    minute  => 0,
  }

  $vhost = $::fqdn

  include apache::mod::proxy
  include apache::mod::proxy_http

  apache::vhost {'elasticsearch-redirect':
    servername      => $vhost,
    port            => '80',
    redirect_status => 'permanent',
    redirect_dest   => "https://${vhost}/",
    docroot         => '/var/www/null',
  }

  # TODO
  # At the moment we're feeding in the entire Apache config as a template,
  # would be nice to be able to open up indexes through puppet, e.g.
  #    elasticsearch::index {'umui':
  #        require => "ip 127.0.0.1",
  #    }
  apache::vhost {'elasticsearch-ssl':
    servername      => $vhost,
    port            => '443',
    ssl             => true,
    custom_fragment => template('roles/elasticsearch/apache-config.erb'),
    docroot         => '/var/www/html',
  }

  # For now set the Kibana home page here
  # TODO This could be part of Kibana
  file {'/var/www/html/app/dashboards/default.json':
    ensure  => present,
    require => Class['kibana'],
    source  => 'puppet:///modules/roles/elasticsearch/kibana-default.json',
  }

  # Register a backup
  rest {'elasticsearch backup':
    url     => 'http://localhost:9200/_snapshot/backup',
    action  => 'PUT',
    data    => "{
      'type': 'fs',
      'settings': {
        'compress': 'true',
        'location': '${roles::common::backup::path}/elasticsearch',
      }
    }",
    unless  => 'http://localhost:9200/_snapshot/backup',
    require => Class['roles::commmon::backup'],
  }

}
