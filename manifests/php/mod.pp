# == Define: nginxpack::php::mod
#
# Just install a php5 module (Debian-like) package.
#
# === Examples
#
#   nginxpack::php::mod { 'gd' }
#
# === Authors
#
# Julien Vaubourg <julien@vaubourg.com>
#
# === Copyright
#
# Copyleft 2013 Julien Vaubourg
# Consider this file under AGPL
#
define nginxpack::php::mod {
  package { "php5-${name}":
    ensure  => present,
    require => Package['php5-cgi'],
  }
}
