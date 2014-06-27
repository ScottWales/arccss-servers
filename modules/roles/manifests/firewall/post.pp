## \file    modules/common/manifests/firewall/post.pp
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

class roles::firewall::post {
  firewall {'999 ip4 INPUT drop all':
    proto    => 'all',
    action   => 'drop',
    before   => undef,
    provider => 'iptables',
    chain    => 'INPUT',
  }

  firewall {'999 ip6 INPUT drop all':
    proto    => 'all',
    action   => 'drop',
    before   => undef,
    provider => 'ip6tables',
    chain    => 'INPUT',
  }

  firewall {'999 ip4 FORWARD drop all':
    proto    => 'all',
    action   => 'drop',
    before   => undef,
    provider => 'iptables',
    chain    => 'FORWARD',
  }

  firewall {'999 ip6 FORWARD drop all':
    proto    => 'all',
    action   => 'drop',
    before   => undef,
    provider => 'ip6tables',
    chain    => 'FORWARD',
  }
}
