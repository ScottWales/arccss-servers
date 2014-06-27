## \file    modules/roles/manifests/common/admins/admin.pp
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

# Setup a single admin
define roles::common::admins::admin (
  $mail = undef,
  $sudo = false,
  $authorized_keys = {},
) {

  # Create user
  user {$name:
    ensure => present,
  }

  # Setup admin mail address
  if $mail {
    mailalias {$name:
      recipient => $mail,
    }
  }

  # Setup keys
  Ssh_authorized_key{
    user => $name,
  }

  create_resources('ssh_authorized_key', $authorized_keys)
}
