## \file    modules/roles/manifests/monitor.pp
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

# Set up a ELK based monitor of the server
class roles::monitor (
  $elasticsearch = 'localhost',
) {
  include ::collectd
  include ::logstash

  logstash::configfile {'input_collectd':
    content => "input { collectd {} }\n",
    order   => 10,
  }
  logstash::configfile {'output_elasticsearch':
    content => "output { elasticsearch {host => ${elasticsearch}} }\n",
    order   => 30,
  }

  class {'collectd::plugin::network':
    server => 'localhost',
  }

  if $elasticsearch == 'localhost' {
    # Logstash needs elasticsearch to start properly
    Class['::elasticsearch'] -> Class['::logstash']
  }
}
