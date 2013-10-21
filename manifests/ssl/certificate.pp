# == Define: nginxpack::ssl::certificate
#
# Install a given ssl certificate to use with a vhost.
#
# Should be used via nginxpack::vhost::* types.
#
# === Parameters
#
# [*ssl_cert_source*]
#   Path of the ssl certificate file (pem / crt). The next parameter must be set
#   to false.
#   Default: false
#
# [*ssl_cert_content*]
#   Set the ssl certificate directly from a string. The previous parameter must
#   be set to false.
#   Default: false
#
# [*ssl_key_source*]
#   Path of the ssl key file. The next parameter must be set to false.
#   Default: false
#
# [*ssl_key_content*]
#   Set the ssl key directly from a string. The previous parameter must be set
#   to false.
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
#   nginxpack::ssl::certificate { 'mycert':
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
define nginxpack::ssl::certificate (
  $ssl_cert_source  = false,
  $ssl_key_source   = false,
  $ssl_cert_content = false,
  $ssl_key_content  = false
) {

  if ($ssl_cert_source and $ssl_cert_content) or
    ($ssl_key_source and $ssl_key_content) {

    fail('Please, choose the source/content method to define a certificate but not the both.')
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
