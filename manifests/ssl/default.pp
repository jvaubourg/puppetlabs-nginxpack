# == Class: nginxpack::ssl::default
#
# Default vhost listening on 443 port with a default (and probably wildcard)
# SSL certificat. If you want to use https on two vhosts with the same IP and
# the same port, Nginx will use this default vhost. Thus, this vhost has to be
# able to propose a valid SSL certificate for the two domains.
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
# [*ssl_cert_source*]
#   Location of the SSL certificate file (pem or crt) to use with the default
#   vhost listening on port 443. Its content will be copied in another file.
#   Only one ssl_cert_* parameter can be used at the same time.
#   Default: false
#
# [*ssl_cert_path*]
#   Location of the SSL certificate file (pem or crt) to use with the default
#   vhost listening on port 443. This location path will be directly used without
#   copying the content of the file. Only one ssl_cert_* parameter can be used at
#   the same time.
#   Default: false
#
# [*ssl_cert_content*]
#   SSL certificate directly from a string (or through hiera). Only one
#   ssl_cert_* parameter can be used at the same time.
#   Default: false
#
# [*ssl_key_source*]
#   Location of the SSL key certificate to use with the default vhost listening
#   on port 443. Its content will be copied in another file. Only one ssl_key_*
#   parameter can be used at the same time.
#   Default: false
#
# [*ssl_key_path*]
#   Location of the SSL key certificate to use with the default vhost listening
#   on port 443. This location path will be directly used without copying the
#   content of the file. Only one ssl_key_* parameter can be used at the same
#   time.
#   Default: false
#
# [*ssl_key_content*]
#   SSL key certificate directly from a string (or through hiera). Only one
#   ssl_key_* parameter can be used at the same time.
#   Default: false
#
# [*ssl_dhparam_source*]
#   Location of a dhparam file to use with the default vhost listening on port
#   443. Its content will be copied in another file. Only one ssl_dhparam_*
#   parameter can be used at the same time.
#   Default: false
#
# [*ssl_dhparam_path*]
#   Location of a dhparam file to use with the default vhost listening on port
#   443. This location path will be directly used without copying the content of
#   the file. Only one ssl_dhparam_* parameter can be used at the same time.
#   Default: false
#
# [*ssl_dhparam_content*]
#   dhparam file directly from a string (or through hiera). Only one
#   ssl_dhparam_* parameter can be used at the same time.
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
#     ssl_cert_content   => hiera('default-cert'),
#     ssl_key_content    => hiera('default-key'),
#     ssl_dhparam_source => 'puppet:///certificates/dhparam.pem',
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
  $ssl_cert_source     = false,
  $ssl_key_source      = false,
  $ssl_dhparam_source  = false,
  $ssl_cert_path       = false,
  $ssl_key_path        = false,
  $ssl_dhparam_path    = false,
  $ssl_cert_content    = false,
  $ssl_key_content     = false,
  $ssl_dhparam_content = false
) {

  if ($ssl_cert_content and $ssl_key_content)
    or ($ssl_cert_source and $ssl_key_source)
    or ($ssl_cert_path and $ssl_key_path) {

    $default_cert_content = $ssl_cert_content
    $default_key_content  = $ssl_key_content

  } else {

    $default_key_content = '-----BEGIN PRIVATE KEY-----
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
SEY9sF1BhizZtEpteZ1c6cPbgdcdEA==
-----END PRIVATE KEY-----'

    $default_cert_content = '-----BEGIN CERTIFICATE-----
MIIFnDCCA4SgAwIBAgIJAIytPSWWG8P6MA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNV
BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
aWRnaXRzIFB0eSBMdGQxHDAaBgNVBAMME05naW54cGFjayBCbGFja2hvbGUwHhcN
MTcwNzIwMjE1NzI4WhcNMzcwNDA2MjE1NzI4WjBjMQswCQYDVQQGEwJBVTETMBEG
A1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkg
THRkMRwwGgYDVQQDDBNOZ2lueHBhY2sgQmxhY2tob2xlMIICIjANBgkqhkiG9w0B
AQEFAAOCAg8AMIICCgKCAgEAzdVqRDay7t2IPLf5L69CXngwoIFa2xH/fyAeYTwX
9akD5B0mHuH1hoaq2bpXrApwuKG80lHrDgPSDpxF/8uiY/HmbWI4axFgGGDb6G+p
jwxiC1luDtUQzwBOth/DFehENe5wkwbNP9hZUpRrj3QsxWQ4xCth0WOAD03pEla7
33rj7wQhMifsCdI8dnyLHyLe7lawTVdduW4cluI9GAF/K9pBMILjJZMQ0BLFY5g2
QMUBagssQBsXXn/1IXTnqj9Wa1LtcE7C53oEmWjmfR3fdujI8i6NwHgGnUNmMhsA
0MmnuLd38C+8vPzRV5Y0dMzepIGHo1UeQKYIcDehIwIccK5RdMj9GOWDGAPIbZUf
D6N3rd3q6G671CLSWjGEQmx0kFxFDtP0mdB70CVgvkxDtkyMnjNRsiv2T0c9PpuI
rmNr95Cm238B7YuFDUBFRrkGE6Etq9Os4hZi+Wg7DrRtJC6laYi00zFDm2FlWKO4
qIdUTbHZ9NowEE8Xo5j71G3I7R79/PnDA7juVxVfGoRKC7ypzWKSrQ1Av/vLBKbv
s2UsayzZXE4nZKdB8HieePVptIMxOsMw60NgjU5DPSKcsXyerVk2W0HARe3zD2wu
CY3xkfwzYKRueWx8KE5L4ipajf4cYhmjcvvBVZAHmnF7yJ3L/ZNTNNAlVMC07C/z
oJcCAwEAAaNTMFEwHQYDVR0OBBYEFAOalHlpdPeM8tNpQX9sjzJoufnaMB8GA1Ud
IwQYMBaAFAOalHlpdPeM8tNpQX9sjzJoufnaMA8GA1UdEwEB/wQFMAMBAf8wDQYJ
KoZIhvcNAQELBQADggIBAAfaX004o178TqVjnNoKmqSygH6W/+mPICIRSePlQ9bN
CbaE3HBuNcEc0vC5IJ6G4rV/NuZdcgbwJXmEOKF6yckUCZ9lbZ416h5t/0OmWQAV
B1572q6aLXrUaCgq7o2oGczGpgjVSnLlK6mxsBGKvv64YX+YqitzBJvBJ22GLkgc
8K8elNVoSLGgXlfusMFAX5yZh8hb56kR7JM7XTCOl83itcR4HzyVMoFgchHEodJe
dPl3Zd0Z7+42+9aiE7BbJjuI+MK6VNGCy9zjrpUrL0+9OnaOjCwQRK5zCM/4Lnwt
nMIHa8H/1P0Md1AFaYpOj3+Xi7pgHIJihc35eoPjZF3yBQdj6MlEwFWOLlV4Gmxz
uaqhjLRgih52Lguv3FTWadcPVvsx6FpqJljkPEPF3igSgwt+ZMXjmtyDu9P1k5Nn
3jy8mORXZOj7lChQe44A+o1nIwIbvaLvkv2bc0tY+M/XPomiMlLqQ3mvJ/gkHkpP
JKN+OkDi5dSQUiiymWICPA2x/15ZRqQSST/UJIz7hVrhZiKiDhjPqLYypMdr+hz3
5dcKbQQjFeq8uSM+iXOTgI7+yV0AoTSl3WPkd61j2ZgBObgG/MBmCfaC3Q8xG7tp
oC/AXxiPgCfzRs100eAdDUdvnNBDivWxdEhbarAganUslhmZAQWwwwR2Tc4g0R7O
-----END CERTIFICATE-----'

  }

  nginxpack::ssl::certificate { 'default':
    ssl_cert_source     => $ssl_cert_source,
    ssl_key_source      => $ssl_key_source,
    ssl_dhparam_source  => $ssl_dhparam_source,
    ssl_cert_content    => $default_cert_content,
    ssl_key_content     => $default_key_content,
    ssl_dhparam_content => $ssl_dhparam_content,
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
