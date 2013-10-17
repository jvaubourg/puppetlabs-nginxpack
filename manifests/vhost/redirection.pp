# == Define: nginxpack::vhost::redirection
#
# Define a visible web redirection returning a 301 (Moved Permanently)
# http code.
#
# === Parameters
#
# [*domains*]
#   Array of domains (fqdn) with which the redirection can be accessed.
#   Default: [ 'localhost' ]
#
# [*enable*]
#   False if you want have this redirection unavailable.
#   Default: true
#
# [*ipv6*]
#   Ipv6 address usable to access to this redirection. Use false to disable ipv6
#   but please never use this possibily! Use :: to listen on all available ipv6
#   addresses. If ipv6 and ipv4 are both false, nginx will listen on all ip
#   available on the server (default).
#   Default: false
#
# [*ipv4*]
#   Ipv4 address usable to access to this redirection. Use false to disable ipv4
#   (the strong _wo_men do that!). Use 0.0.0.0 to listen on all available ipv4
#   addresses. If ipv6 and ipv4 are both false, nginx will listen on all ip
#   available on the server (default).
#   Default: false
#
# [*port*]
#   Define the tcp port available to access to this redirection.
#   Default: 80
#
# [*to_domain*]
#   Domain of the remote website.
#   Default: the first domain available (domains[0])
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
#   nginxpack::vhost::redirection { 'www-blog':
#     domains   => [ 'www.blog.example.com' ],
#     to_domain => 'blog.example.com',
#   }
#
#   nginxpack::vhost::redirection { 'http-blog':
#     domains  => [ 'blog.example.com' ],
#     to_https => true,
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
define nginxpack::vhost::redirection (
  $domains            = [ 'localhost' ],
  $ipv6               = false,
  $ipv4               = false,
  $port               = 80,
  $to_domain          = $domains[0],
  $to_port            = -1,
  $to_https           = false,
  $enable             = true,
  $add_config_source  = false,
  $add_config_content = false
) {

  if $add_config_source and $add_config_content {
    fail('Please, choose the source/content method to define additional config but not the both.')
  }

  $portval = $port

  if $to_port == -1 {
    $to_portval = $to_https ? { true => 443, false => 80 }
  } else {
    $to_portval = $to_port
  }

  file { "/etc/nginx/sites-available/${name}_redirection":
    ensure  => file,
    mode    => '0644',
    content => template('nginxpack/nginx/vhost_redirection.erb'),
    require => Package['nginx'],
    notify  => [
      Exec['find_default_listen'],
      Service['nginx'],
    ],
  }

  $ensure_enable = $enable ? {
    true  => link,
    false => absent,
  }

  file { "/etc/nginx/sites-enabled/${name}_redirection":
    ensure  => $ensure_enable,
    target  => "/etc/nginx/sites-available/${name}_redirection",
    require => File["/etc/nginx/sites-available/${name}_redirection"],
    notify  => [
      Exec['find_default_listen'],
      Service['nginx'],
    ],
  }

  if $add_config_source {
    file { "/etc/nginx/include/${name}.conf":
      ensure => file,
      mode   => '0644',
      source => $add_config_source,
    }
  }

  if $add_config_content {
    file { "/etc/nginx/include/${name}.conf":
      ensure  => file,
      mode    => '0644',
      content => $add_config_content,
    }
  }
}
