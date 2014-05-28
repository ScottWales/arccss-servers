
node default {

  include common

  Firewall {
    require => Class['common::firewall::pre'],
    before  => Class['common::firewall::post'],
  }

  # Root mail alias
  mailalias {'root':
    recipient => 'saw562@anusf.nci.org.au',
  }

  package {'rubygems':}
  Package['rubygems'] -> Package<|provider == gem|>

  package {'python-pip':}
  Package['python-pip'] -> Package<|provider == pip|>

  package {'wget': }

  hiera_include('classes')

}
