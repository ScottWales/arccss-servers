## \file    manifests/init.pp
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

class shipyard (
  $admin_pass = undef,
  $db_pass    = undef,
) {
  require docker

  if ! $docker::tcp_bind {
    warning('Shipyard requires Docker\'s TCP interface, please set "$docker::tcp_bind" (e.g. to \'tcp://127.0.0.1:4243\')')
  }

  if ! $admin_pass {
    warning('No admin password defined, please set "$shipyard::db_pass"')
  }

  if ! $db_pass {
    warning('No database password defined, it will be set randomly')
  }

  docker::run {'shipyard-redis':
    image    => 'shipyard/redis',
    use_name => true,
    ports    => '6379',
  }

  docker::run {'shipyard-router':
    image    => 'shipyard/router',
    use_name => true,
    ports    => '80',
    links    => 'shipyard-redis:redis',
    require  => Docker::Run['shipyard-redis'],
  }

  docker::run {'shipyard-lb':
    image    => 'shipyard/lb',
    use_name => true,
    ports    => '80:80',
    links    => ['shipyard-redis:redis','shipyard-router:app_router'],
    require  => Docker::Run['shipyard-redis','shipyard-router'],
  }

  docker::run {'shipyard-db':
    image    => 'shipyard/db',
    use_name => true,
    ports    => '5432',
    env      => ["DB_PASS=${db_pass}"],
  }

  docker::run {'shipyard-shipyard':
    image    => 'shipyard/shipyard',
    use_name => true,
    ports    => '8000:8000',
    links    => ['shipyard-db:db','shipyard-redis:redis'],
    env      => ["ADMIN_PASS='${admin_pass}'"],
    command  => '/app/.docker/run.sh app master-worker',
    require  => Docker::Run['shipyard-redis','shipyard-db'],
  }

  docker::run {'shipyard-agent':
    image    => 'shipyard/agent',
    use_name => true,
    env      => ["IP=${::network_eth0}",'URL=http://localhost:8000'],
    ports    => '4500:4500',
    volumes  => '/var/run/docker.sock:/docker.sock',
    require  => Docker::Run['shipyard-shipyard'],
  }


}
