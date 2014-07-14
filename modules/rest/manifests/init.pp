## \file    modules/rest/manifests/init.pp
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

# Query REST apis
define rest (
  $url,
  $request = 'GET',
  $data = undef,

  # Check these URLs for 200 first
  $unless = undef,
) {

  if $data {
    $_data = "-d '${data}'"
  } else {
    $_data = ''
  }

  # Redirect output to stderr so we can check the response code
  $action      = "curl -sL -w '%{http_code}' -o /dev/stderr ${url} -X${request} ${_data} | grep 200"

  if $unless {
    $unlesscheck = "curl -sL -w '%{http_code}' -o /dev/null ${unless} | grep 200"
  }

  exec {"rest ${name}":
    command => $action,
    path    => ['/bin','/usr/bin'],
    unless  => $unlesscheck,
  }
}
