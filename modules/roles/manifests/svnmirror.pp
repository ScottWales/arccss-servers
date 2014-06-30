## \file    modules/roles/manifests/svnserve.pp
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

# Apache-based subversion write-through proxy

# Add repositories with the 'repositories' hash, e.g. in hiera
#
# roles::svnmirror::repositories:
#    coecss-servers:
#      source: https://github.com/ScottWales/coecss-servers
#
# will create a repository named 'coecss-servers' available at
# https://$vhost/coecss-servers that mirrors the contents of the repo defined
# by 'source'

class roles::svnmirror (
  $vhost        = "svn.${::fqdn}",
  $repohome     = '/svn',
  $repositories = {}
) {
  include roles::svnmirror::package
  include roles::svnmirror::vhost

  # Setup repohome
  file {$repohome:
    ensure => directory,
  }

  # Setup repos
  create_resources('roles::svnmirror::repo',$repositories)

}
