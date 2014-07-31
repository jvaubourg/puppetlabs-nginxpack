# == Class: nginxpack
#
# Install and configure Nginx, and - optionally - PHP5-FastCGI.
#
# More explanations: https://forge.puppetlabs.com/jvaubourg/nginxpack
# Sources: https://github.com/jvaubourg/puppetlabs-nginxpack
#
# === Parameters
#
# [*logrotate*]
#   See the parameter definition with logrotate/enable.
#   Default: true
#
# [*ssl_default_cert_source*]
#   See the parameter definition with ssl::default/ssl_cert_source
#   Default: false
#
# [*ssl_default_cert_content*]
#   See the parameter definition with ssl::default/ssl_cert_content
#   Default: Nginxpack default cert
#
# [*ssl_default_key_source*]
#   See the parameter definition with ssl::default/ssl_key_source
#   Default: false
#
# [*ssl_default_key_content*]
#   See the parameter definition with ssl::default/ssl_key_content
#   Default: Nginxpack default key
#
# [*default_https_blackhole*]
#   False if you don't want a default https blackhole (useful if you
#   have no https vhosts and you don't want Nginx listening 443).
#   Default: true
#
# [*enable_php*]
#   See the parameter definition with php::cgi/enable
#   Default: false
#
# [*php_mysql*]
#   See the parameter definition with php::cgi/mysql
#   Default: false
#
# [*php_timezone*]
#   See the parameter definition with php::cgi/timezone
#   Default: Europe/Paris
#
# [*php_upload_max_filesize*]
#   See the parameter definition with php::cgi/upload_max_filesize
#   Default: 10M
#
# [*php_upload_max_files*]
#   See the parameter definition with php::cgi/upload_max_files
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
# More examples: https://forge.puppetlabs.com/jvaubourg/nginxpack
#
# === Authors
#
# Julien Vaubourg
# http://julien.vaubourg.com
#
# === Copyright
#
# Copyright (C) 2013 Julien Vaubourg
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

class nginxpack (
  $logrotate                = true,
  $ssl_default_cert_source  = false,
  $ssl_default_key_source   = false,
  $ssl_default_cert_content = false,
  $ssl_default_key_content  = false,
  $default_https_blackhole  = true,
  $enable_php               = false,
  $php_mysql                = false,
  $php_timezone             = 'Europe/Paris',
  $php_upload_max_filesize  = '10M',
  $php_upload_max_files     = 10,
) {

  if ($ssl_default_cert_source or $ssl_default_key_source or $ssl_default_cert_content
    or $ssl_default_key_content) and !$default_https_blackhole {

    fail('Use a default certificate without enable default_https_blackhole')
    fail('does not make sense.')
  }

  class { 'nginxpack::logrotate':
    enable => $logrotate,
  }

  if $default_https_blackhole {
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

  file_line { 'nginx.conf-server_names_hash_bucket_size':
    path    => '/etc/nginx/nginx.conf',
    match   => 'server_names_hash_bucket_size',
    line    => 'server_names_hash_bucket_size 64;',
    require => Package['nginx'],
    notify  => Service['nginx'],
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
