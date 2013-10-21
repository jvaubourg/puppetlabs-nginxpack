# == Class: nginxpack
#
# Install and configure nginx and (optionally) php.
#
# === Parameters
#
# [*logrotate*]
#   False if you want to disable log rotating for nginx.
#   Default: true
#
# [*ssl_default_cert_source*]
#   Path of the ssl certificate file (pem / crt) to use with the default vhost
#   listening on the 443 port. If you want to use https on two vhosts with the
#   same ip, nginx will use this default vhost (typically with ipv4). Thus, this
#   vhost has to be able to propose a valid ssl certificate for the both
#   (or more) domains. You probably need to use a wildcard certificate here.
#   The next parameter must be set to false.
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
# [*enable_php*]
#   True if you want to use php-cgi with one of the future vhosts.
#   Default: false
#
# [*php_mysql*]
#   True if you want to allow mysql with php. You have to set enable_php to true
#   to use it.
#   Default: false
#
# [*php_timezone*]
#   Define the default timezone for php. You have to set enable_php to true
#   to use it.
#   Default: Europe/Paris
#
# [*php_upload_max_filesize*]
#   Define the max upload filesize in MB. You have to set enable_php to true
#   to use it.
#   Default: 10M
#
# [*php_upload_max_files*]
#   Define the max number of files that can be sent in the same upload. You have
#   to set enable_php to true to use it.
#   Default: 10
#
# === Examples
#
#   class { 'nginxpack':
#     enable_php              => true,
#     ssl_default_cert_source => 'puppet:///certificates/default.pem',
#     ssl_default_key_source  => 'puppet:///certificates/default.key',
#   }
#
#   class { 'nginxpack':
#     ssl_default_cert_content => hiera('default-cert'),
#     ssl_default_key_content  => hiera('default-key'),
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
class nginxpack (
  $logrotate                = true,
  $ssl_default_cert_source  = false,
  $ssl_default_key_source   = false,
  $ssl_default_cert_content = false,
  $ssl_default_key_content  = false,
  $enable_php               = false,
  $php_mysql                = false,
  $php_timezone             = 'Europe/Paris',
  $php_upload_max_filesize  = '10M',
  $php_upload_max_files     = 10
) {

  class { 'nginxpack::logrotate':
    enable => $logrotate,
  }

  if $ssl_default_cert_source or $ssl_default_cert_content or
      $ssl_default_key_source or $ssl_default_key_content
  {
    class { 'nginxpack::ssl::default':
      ssl_cert_source  => $ssl_default_cert_source,
      ssl_key_source   => $ssl_default_key_source,
      ssl_cert_content => $ssl_default_cert_content,
      ssl_key_content  => $ssl_default_key_content,
    }
  }

  class { 'nginxpack::php::cgi':
    enable              => $enable_php,
    mysql               => $php_mysql,
    timezone            => $php_timezone,
    upload_max_filesize => $php_upload_max_filesize,
    upload_max_files    => $php_upload_max_files,
  }

  package { 'nginx':
    ensure => present,
  }

  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['nginx'],
  }

  exec { 'find_default_listen':
    command     => '/etc/nginx/find_default_listen.sh',
    require     => Package['nginx'],
    refreshonly => true,
  }

  file { '/etc/nginx/find_default_listen.sh':
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/nginxpack/nginx/find_default_listen.sh',
    require => File['/etc/nginx/include/'],
  }

  file { [ '/etc/nginx/ssl/', '/etc/nginx/htpasswd/', '/etc/nginx/include/' ]:
    ensure  => directory,
    mode    => '0550',
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['nginx'],
  }

  file { [ '/var/log/nginx/' ]:
    ensure  => directory,
    mode    => '0770',
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['nginx'],
  }

  file { '/etc/nginx/sites-available/default':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/nginxpack/nginx/vhost_default',
    notify  => Service['nginx'],
    require => Package['nginx'],
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure  => link,
    target  => '/etc/nginx/sites-available/default',
    require => File['/etc/nginx/sites-available/default'],
  }

  file { '/etc/nginx/include/attacks.conf':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/nginxpack/nginx/attacks.conf',
    require => Package['nginx'],
    notify  => Service['nginx'],
  }
}
