# == Define: nginxpack::vhost::proxy
#
# Define a nginx proxy vhost. If you still use ipv4, you probably need a reverse
# proxy server. On this one you could use this type of vhost to reach a
# nginxpack::vhost::basic on another machine.
#
# === Parameters
#
# [*domains*]
#   Array of domains (fqdn) with which the website can be accessed.
#   Default: [ 'localhost' ]
#
# [*enable*]
#   False if you want have this website unavailable.
#   Default: true
#
# [*ipv6*]
#   Ipv6 address usable to access to this website. Use false to disable ipv6
#   but please never use this possibily! Use :: to listen on all available ipv6
#   addresses. If ipv6 and ipv4 are both false, nginx will listen on all ip
#   available on the server (default).
#   Default: false
#
# [*ipv4*]
#   Ipv4 address usable to access to this website. Use false to disable ipv4
#   (the strong _wo_men do that!). Use 0.0.0.0 to listen on all available ipv4
#   addresses. If ipv6 and ipv4 are both false, nginx will listen on all ip
#   available on the server (default).
#   Default: false
#
# [*https*]
#   True if you want to use a ssl secure connection for this website. You need have
#   a certificat corresponding to the domains for that. Please use https each
#   time you have a login process inside your pages.
#   Default: false
#
# [*ssl_cert_source*]
#   Set a path to the ssl certificate file (pem / crt) to use for the secure
#   connection. You have to use the https parameter set to true and the next
#   parameter set to false to use it.
#   Default: false
#
# [*ssl_cert_content*]
#   Set the ssl certificate directly from a string. You have to use the https
#   parameter set to true and the previous parameter set to false to use it.
#   Default: false
#
# [*ssl_key_source*]
#   Set a path to the ssl key certificate file to use for the secure connection.
#   You have to use the https parameter set to true and the next parameter set
#   to false to use it.
#   Default: false
#
# [*ssl_key_content*]
#   Set the ssl key certificate directly from a string. You have to use the
#   https parameter set to true and the previous parameter set to
#   false to use it.
#   Default: false
#
# [*upload_max_size*]
#   Define the maximum size of an upload with postdata. This value should be the
#   same as on the remote vhost.
#   Default: 100M
#
# [*port*]
#   Define the tcp port available to access to this website.
#   Default (https = false): 80
#   Default (https = true): 443
#
# [*to_domain*]
#   Domain of the remote vhost. The default value is useful to transparently use
#   a different port on the same machine.
#   Default: first domain available (domains[0])
#
# [*to_https*]
#   If true, use https instead of http to reach the remote vhost.
#   Default: false
#
# [*to_port*]
#   Define the tcp port to use to reach the remote vhost.
#   Default (to_https=true): 443
#   Default (to_https=false): 80
#
# [*add_config_source*]
#   Vhost config files are generated from puppet but you could need to add
#   specific rules for nginx. The content of the file targeted by this option
#   will be added at the end of the configuration. The next parameter must be
#   false.
#   Default: false
#
# [*add_config_content*]
#   Set the additional config directly from a string. The previous parameter
#   must be false.
#   Default: false
#
# === Examples
#
#   nginxpack::vhost::proxy { 'blog-proxy':
#     domains   => [ 'blog.example.com' ],
#     to_domain => 'blog.lan',
#   }
#
#   nginxpack::vhost::proxy { 'panel-proxy':
#     domains => [ 'panel.example.com' ],
#     to_port => 8080,
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
define nginxpack::vhost::proxy (
  $domains            = [ 'localhost' ],
  $https              = false,
  $ssl_cert_source    = false,
  $ssl_key_source     = false,
  $ssl_cert_content   = false,
  $ssl_key_content    = false,
  $to_domain          = -1,
  $to_https           = false,
  $to_port            = -1,
  $enable             = true,
  $ipv6               = false,
  $ipv4               = false,
  $port               = -1,
  $upload_max_size    = '10M',
  $add_config_source  = false,
  $add_config_content = false
) {

  if ($ssl_cert_source or $ssl_key_source or $ssl_cert_content
    or $ssl_key_content) and !$https {

    fail('Define a certificate source/content with https not enabled has no sense.')
  }

  if $https and ((!$ssl_cert_source and !$ssl_cert_content)
    or (!$ssl_key_source and !$ssl_key_content)) {

    fail('To have a https connection, please define a cert_pem AND a cert_key.')
  }

  if $add_config_source and $add_config_content {
    fail('Please, choose the source/content method to define additional config but not the both.')
  }

  if $to_port == -1 {
    $to_portval = $to_https ? { true => 443, false => 80 }
  } else {
    $to_portval = $to_port
  }

  if $port == -1 {
    $portval = $https ? { true => 443, false => 80 }
  } else {
    $portval = $port
  }

  if $to_domain == -1 {
    $to_domainval = $domains[0]
  } else {
    $to_domainval = $to_domain
  }

  file { "/var/log/nginx/${name}_proxy/":
    ensure  => directory,
    mode    => '0644',
    require => Package['nginx'],
  }

  if $https {
    nginxpack::ssl::certificate { "${name}_proxy":
      ssl_cert_source  => $ssl_cert_source,
      ssl_key_source   => $ssl_key_source,
      ssl_cert_content => $ssl_cert_content,
      ssl_key_content  => $ssl_key_content,
    }

    $vhost_require = [
      Package['nginx'],
      File["/var/log/nginx/${name}_proxy/"],
      File["/etc/nginx/ssl/${name}.pem"],
      File["/etc/nginx/ssl/${name}.key"],
    ]
  } else {
    $vhost_require = [
      Package['nginx'],
      File["/var/log/nginx/${name}_proxy/"],
    ]
  }

  file { "/etc/nginx/sites-available/${name}_proxy":
    ensure  => file,
    mode    => '0644',
    content => template('nginxpack/nginx/vhost_proxy.erb'),
    require => $vhost_require,
    notify  => [
      Exec['find_default_listen'],
      Service['nginx'],
    ],
  }

  $ensure_enable = $enable ? {
    true  => link,
    false => absent,
  }

  file { "/etc/nginx/sites-enabled/${name}_proxy":
    ensure  => $ensure_enable,
    target  => "/etc/nginx/sites-available/${name}_proxy",
    require => File["/etc/nginx/sites-available/${name}_proxy"],
    notify  => [
      Exec['find_default_listen'],
      Service['nginx'],
    ],
  }

  if $add_config_source {
    file { "/etc/nginx/include/${name}_proxy.conf":
      ensure => file,
      mode   => '0644',
      source => $add_config_source,
    }
  }

  if $add_config_content {
    file { "/etc/nginx/include/${name}_proxy.conf":
      ensure  => file,
      mode    => '0644',
      content => $add_config_content,
    }
  }
}
