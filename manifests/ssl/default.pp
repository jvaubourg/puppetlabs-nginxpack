# == Class: nginxpack::ssl::default
#
# Default vhost listening on the 443 port with a default (and probably wildcard)
# SSL certificat. If you want to use https on two vhosts with the same IP and
# the same port, Nginx will use this default vhost. Thus, this vhost has to be
# able to propose a valid SSL certificate for the both domains.
# See:
#  https://github.com/jvaubourg/puppetlabs-nginxpack#well-known-problem-with-ssl
#
# Should be used through the main nginxpack class.
#
# More explanations: https://forge.puppetlabs.com/jvaubourg/nginxpack
# Sources: https://github.com/jvaubourg/puppetlabs-nginxpack
#
# === Parameters
#
# [*ssl_default_cert_source*]
#   Location of the SSL certificate file (pem or crt) to use with the default
#   vhost listening on port 443. If not false then the next parameter must
#   be false.
#   Default: false
#
# [*ssl_default_cert_content*]
#   SSL certificate directly from a string (or through hiera). If not false then
#   the previous parameter must be false.
#   Default: false
#
# [*ssl_default_key_source*]
#   Location of the SSL key certificate to use with the default vhost listening
#   on port 443. If not false then the next parameter must be false.
#   Default: false
#
# [*ssl_default_key_content*]
#   SSL key certificate directly from a string (or through hiera). If not false
#   then the previous parameter must be false.
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
