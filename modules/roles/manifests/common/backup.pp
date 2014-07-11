## \file    modules/common/manifests/backup.pp
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

# Set up automatic backups for $path
# Note that Amanda configuration is server-side, this just creates a directory
# & allows the backup server user to log in
class roles::common::backup (
  # Remote server & user
  $server      = undef,
  $remote_user = 'backup',

  # Key to login as the backup user
  $remote_key  = undef,
  $key_type    = 'ssh-rsa',

  # Path to use for backups (referred to by other classes)
  $path        = '/backup',
) {

  # Install Amanda client software
  class {'amanda::client':
    server      => $server,
    remote_user => $remote_user,
  }

  file {$path:
    ensure => directory,
  }

  # Allow access for the remote user
  amanda::ssh_authorized_key {"${remote_user}@${server}":
    key  => $remote_key,
    type => $key_type,
  }

}
