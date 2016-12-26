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
# [*ssl_cert_content_source*]
#   Location of the SSL certificate file (pem or crt) to use with the default
#   vhost listening on port 443. If not false then the next parameter must
#   be false.
#   Default: false
#
# [*ssl_cert_content_content*]
#   SSL certificate directly from a string (or through hiera). If not false then
#   the previous parameter must be false.
#   Default: false
#
# [*ssl_key_content_source*]
#   Location of the SSL key certificate to use with the default vhost listening
#   on port 443. If not false then the next parameter must be false.
#   Default: false
#
# [*ssl_key_content_content*]
#   SSL key certificate directly from a string (or through hiera). If not false
#   then the previous parameter must be false.
#   Default: false
#
# [*ssl_dhparam_source*]
#   Location of a dhparam file to use with the default vhost listening on port
#   443. If not false then the next parameter must be false.
#   Default: false
#
# [*ssl_dhparam_content*]
#   dhparam file directly from a string (or through hiera). If not false then
#   the previous parameter must be false.
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
  $ssl_cert_content    = false,
  $ssl_key_content     = false,
  $ssl_dhparam_content = false
) {

  if ($ssl_cert_content and $ssl_key_content)
    or ($ssl_cert_source and $ssl_key_source) {

    $default_cert_content = $ssl_cert_content
    $default_key_content  = $ssl_key_content

  } else {

    $default_cert_content = '-----BEGIN CERTIFICATE-----
MIICDzCCAbmgAwIBAgIJAOdD3ZnAmgBzMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNV
BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
aWRnaXRzIFB0eSBMdGQxHDAaBgNVBAMME05naW54cGFjayBCbGFja2hvbGUwHhcN
MTQwODA2MTkwMTM0WhcNMjQwODAzMTkwMTM0WjBjMQswCQYDVQQGEwJBVTETMBEG
A1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkg
THRkMRwwGgYDVQQDDBNOZ2lueHBhY2sgQmxhY2tob2xlMFwwDQYJKoZIhvcNAQEB
BQADSwAwSAJBANYxePuEHvfPwtIn4EaCyzTTssp5AbPifsqqh6smVb5FE5t6yuPV
VVW69VG2WcLEhXbTwKosx7Lqy1KOV6TFttUCAwEAAaNQME4wHQYDVR0OBBYEFLx0
p7Bp+k+cfEEUSxqH5xB4WB6KMB8GA1UdIwQYMBaAFLx0p7Bp+k+cfEEUSxqH5xB4
WB6KMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQELBQADQQCZnV/Dqews23DrxK5P
uCHCuM8qBbZyb6i7DtV4pclr6xDTvxLBH1lEGeD1Jn6/nVy4aT0Y2AKLSFhMm7AB
ohjJ
-----END CERTIFICATE-----'

    $default_key_content = '-----BEGIN PRIVATE KEY-----
MIIBVwIBADANBgkqhkiG9w0BAQEFAASCAUEwggE9AgEAAkEA1jF4+4Qe98/C0ifg
RoLLNNOyynkBs+J+yqqHqyZVvkUTm3rK49VVVbr1UbZZwsSFdtPAqizHsurLUo5X
pMW21QIDAQABAkEAtdcuVKkn+U5ioTPFTVdA2MpY4Ve1wFerOLdpkj1rUamY6Kiv
N4rgHiJRmj46BZ2T2fmwRK7yFwa9eWBFrTf1SQIhAPgCrFDNE2KYZ50ShJ1eOVEu
grnUYWUPCCcyxMp4a0zbAiEA3RfpQ/gH0rqqASAsiQ24s/xHl9pokSYhqA2TuNvv
gg8CIQCMVw7lJjbK+wzewCTU3AW5H4WP3FNEmW32qG7dV6j4MwIhANFlsiITqaUl
8Zl7VXLAsiyVRWFHFD5UtQ+rPDua4i51AiEAi48S/vp0XhmAG1GtZ1NC5Ne5+P6V
Wd9kn84eQtVblhU=
-----END PRIVATE KEY-----'

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
