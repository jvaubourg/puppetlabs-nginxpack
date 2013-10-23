# == Define: nginxpack::ssl::certificate
#
# Add a SSL certificate usable with basic/proxy vhosts.
#
# Should be used through nginxpack::vhost::{basic,proxy} types.
#
# More explanations: https://forge.puppetlabs.com/jvaubourg/nginxpack
# Sources: https://github.com/jvaubourg/puppetlabs-nginxpack
#
# === Parameters
#
# [*ssl_cert_source*]
#   Location of the SSL certificate file (pem or crt). If not false then the
#   next parameter must be false.
#   Default: false
#
# [*ssl_cert_content*]
#   SSL certificate directly from a string (or through hiera). If not false then
#   the previous parameter must be false.
#   Default: false
#
# [*ssl_key_source*]
#   Location of the SSL key certificate file. If not false then the next
#   parameter must be false.
#   Default: false
#
# [*ssl_key_content*]
#   SSL key certificate directly from a string (or through hiera). If not false
#   then the previous parameter must be false.
#   Default: false
#
# === Examples
#
#   nginxpack::ssl::certificate { 'mycert':
#     ssl_cert_source => 'puppet:///certificates/mycert.pem',
#     ssl_key_source  => 'puppet:///certificates/mycert.key',
#   }
#
#   nginxpack::ssl::certificate { 'mycert':
#     ssl_cert_content => hiera('mycert-cert'),
#     ssl_key_content  => hiera('mycert-key'),
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
define nginxpack::ssl::certificate (
  $ssl_cert_source  = false,
  $ssl_key_source   = false,
  $ssl_cert_content = false,
  $ssl_key_content  = false
) {

  if ($ssl_cert_source and $ssl_cert_content) or
    ($ssl_key_source and $ssl_key_content) {

    fail('Use source/content method to define a certificate but not the both.')
  }

  if (!$ssl_cert_source and !$ssl_cert_content)
    or (!$ssl_key_source and !$ssl_key_content) {

    fail('Please define a cert_pem AND a cert_key.')
  }

  if $ssl_cert_source {
    file { "/etc/nginx/ssl/${name}.pem":
      ensure => file,
      mode   => '0644',
      source => $ssl_cert_source,
    }
  } else {
    file { "/etc/nginx/ssl/${name}.pem":
      ensure  => file,
      mode    => '0644',
      content => $ssl_cert_content,
    }
  }

  if $ssl_key_source {
    file { "/etc/nginx/ssl/${name}.key":
      ensure => file,
      mode   => '0644',
      source => $ssl_key_source,
    }
  } else {
    file { "/etc/nginx/ssl/${name}.key":
      ensure  => file,
      mode    => '0644',
      content => $ssl_key_content,
    }
  }
}
