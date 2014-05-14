## \file    modules/kibana/manifests/init.pp
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

class kibana (
  $vhost         = 'localhost',
  $elasticsearch = 'localhost:9200',
  $web_provider  = 'jfryman/nginx',
) {
  $source = 'https://download.elasticsearch.org/kibana/kibana/kibana-3.0.1.tar.gz'

  exec {'wget kibana':
    command => "wget -O - ${source} | tar xz --strip-components=1",
    path    => ['/bin','/usr/bin'],
    cwd     => '/var/www/html',
    creates => '/var/www/html/index.html',
    require => Package['wget'],
  }

  #  # Create a proxy to elasticsearch
  #  nginx::resource::location {'^/_aliases$':
  #    vhost    => '$vhost',
  #    proxy    => "http://${elasticsearch}",
  #    ssl_only => true,
  #  }
  #  nginx::resource::location {'^/.*/_aliases$':
  #    vhost    => '$vhost',
  #    proxy    => "http://${elasticsearch}",
  #    ssl_only => true,
  #  }
  #  nginx::resource::location {'^/_nodes$':
  #    vhost    => '$vhost',
  #    proxy    => "http://${elasticsearch}",
  #    ssl_only => true,
  #  }
  #  nginx::resource::location {'^/.*/_search$':
  #    vhost    => '$vhost',
  #    proxy    => "http://${elasticsearch}",
  #    ssl_only => true,
  #  }
  #  nginx::resource::location {'^/.*/_mapping':
  #    vhost    => '$vhost',
  #    proxy    => "http://${elasticsearch}",
  #    ssl_only => true,
  #  }
  #
  #  # Kibana storage
  #  nginx::resource::location {'^/kibana-int/dashboard/.*$':
  #    vhost    => '$vhost',
  #    proxy    => "http://${elasticsearch}",
  #    ssl_only => true,
  #  }
  #  nginx::resource::location {'^/kibana-int/temp.*$':
  #    vhost    => '$vhost',
  #    proxy    => "http://${elasticsearch}",
  #    ssl_only => true,
  #  }

  # Have Kibana use the proxy
  file_line {'kibana elasticsearch':
    path    => '/var/www/html/config.js',
    match   => '^\s*elasticsearch:.*',
    line    => 'elasticsearch: "https://"+window.location.hostname+"",',
    require => Exec['wget kibana'],
  }

}
