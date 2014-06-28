## \file    modules/roles/manifests/svnmirror/repo.pp
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

# Create a new repo under $repohome
define roles::svnmirror::repo (
  $source = undef,
) {
  include apache::mod::proxy
  include apache::mod::proxy_http

  $repopath = "${roles::svnmirror::repohome}/${name}"

  vcsrepo {$repopath:
    ensure   => present,
    provider => svn,
  }

  if $source {
    # Setup forward proxy for this repo
    roles::apache::directory {$name:
      vhost           => 'svn-ssl',
      path            => "/${name}",
      provider        => 'location',
      custom_fragment => "
        DAV          svn
        SVNPath      ${repopath}
        SVNMasterURI ${source}
      ",
    }
  }

}
