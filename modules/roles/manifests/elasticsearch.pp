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

class roles::elasticsearch (
  $backup_path = '/backup',
) {
  include roles::webserver

  include ::elasticsearch
  include ::java
  include ::apache
  include ::kibana

  Class['java']   -> Class['::elasticsearch']
  Package['wget'] -> Class['::elasticsearch']

  $vhost = $::fqdn
  $instance = 'es-01'

  # Create the elasticsearch instance
  elasticsearch::instance {$instance:}

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

  # Register the backup location with elasticsearch
  # See http://www.elasticsearch.org/guide/en/elasticsearch/reference/master/modules-snapshots.html
  file {"${backup_path}/elasticsearch":
    ensure => 'directory',
    owner  => 'elasticsearch',
  }
  rest {'elasticsearch backup':
    url     => 'http://localhost:9200/_snapshot/backup',
    request => 'PUT',
    data    => "{
      \"type\": \"fs\",
      \"settings\": {
        \"compress\": \"true\",
        \"location\": \"${backup_path}/elasticsearch\"
      }
    }",
    unless  => 'http://localhost:9200/_snapshot/backup',
    require => [
      Class['::roles::common::backup'],
      File["${backup_path}/elasticsearch"],
      Service[$instance],
    ],
  }

  # Create daily backups of Elasticsearch, to be fetched by the remote backup
  # server.  We can only have 1 snapshot for each name, so we delete the old one
  # before creating the new. Backups are incremental and deleting only removes
  # files not in use by other snapshots, so each new backup run should do
  # minimal work. To restore a snapshot run e.g.
  #    curl -XPOST "localhost:9200/_snapshot/backup/snapshot_3/_restore"

  cron {'elasticsearch-backup-prepare':
    command => '/usr/bin/curl -XDELETE "localhost:9200/_snapshot/backup/snapshot_$(/bin/date +%w)"',
    hour    => '20',
    minute  => '0',
  }
  cron {'elasticsearch-backup':
    command => '/usr/bin/curl -XPUT "localhost:9200/_snapshot/backup/snapshot_$(/bin/date +%w)"',
    hour    => '21',
    minute  => '0',
  }

}
