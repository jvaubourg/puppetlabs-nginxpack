# == Class: nginxpack::ssl::default
#
# Set the default vhost listening on the 443 port with a default (probably
# wildcard) ssl certificat. If you want to use https on two vhosts with the ip
# nginx will use this default vhost (typically with ipv4). Thus, this vhost has
# to be able to propose a valid ssl certificate for the both (or more) domains.
#
# Should be used via the main nginxpack class.
#
# === Parameters
#
# [*ssl_default_cert_source*]
#   Path of the ssl certificate file (pem / crt) to use with the default vhost
#   listening on the 443 port.  The next parameter must be set to false.
#   Default: false
#
# [*ssl_default_cert_content*]
#   Set the ssl certificate directly from a string. The previous parameter must
#   be set to false.
#   Default: false
#
# [*ssl_default_key_source*]
#   Path of the ssl key file to use with the default vhost listening on the
#   443 port. The next parameter must be set to false.
#   Default: false
#
# [*ssl_default_key_content*]
#   Set the ssl key directly from a string. The previous parameter must be set
#   to false.
#   Default: false
#
# === Examples
#
#   class { 'nginxpack::ssl::default':
#     ssl_cert_source => 'puppet:///certificates/default.pem',
#     ssl_key_source  => 'puppet:///certificates/default.key',
#   }
#
#   class { 'nginxpack::ssl::default':
#     ssl_cert_content => hiera('default-cert'),
#     ssl_key_content  => hiera('default-key'),
#   }
#
#   class { 'nginxpack::ssl::default':
#     ssl_cert_content => '...very long certificate string...',
#     ssl_key_content  => '...very long key string...',
#   }
#
# === Authors
#
# Julien Vaubourg <http://julien.vaubourg.com>
#
# === Copyright
#
# Copyleft 2013 Julien Vaubourg
# Consider this file under AGPL
#
class nginxpack::ssl::default (
  $ssl_cert_source  = false,
  $ssl_key_source   = false,
  $ssl_cert_content = false,
  $ssl_key_content  = false
) {

  nginxpack::ssl::certificate { 'default':
    ssl_cert_source  => $ssl_cert_source,
    ssl_key_source   => $ssl_key_source,
    ssl_cert_content => $ssl_cert_content,
    ssl_key_content  => $ssl_key_content,
  }

  file { '/etc/nginx/sites-available/default_https':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/nginxpack/nginx/vhost_default_https',
    notify  => Service['nginx'],
    require => [
      Package['nginx'],
      File['/etc/nginx/ssl/default.pem'],
      File['/etc/nginx/ssl/default.key'],
      Nginxpack::Ssl::Certificate['default'],
    ],
  }

  file { '/etc/nginx/sites-enabled/default_https':
    ensure  => link,
    target  => '/etc/nginx/sites-available/default_https',
    require => File['/etc/nginx/sites-available/default_https'],
  }
}
