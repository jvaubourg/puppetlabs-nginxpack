# == Define: nginxpack::vhost::proxy
#
# If you still use IPv4 with a single address, you probably need a reverse proxy
# server. On this one you could use this type of vhost to reach a
# nginxpack::vhost::basic on another machine.
#
# More explanations: https://forge.puppetlabs.com/jvaubourg/nginxpack
# Sources: https://github.com/jvaubourg/puppetlabs-nginxpack
#
# === Parameters
#
# [*to_domain*]
#   Address of the remote vhost. The default value is useful to seamlessly
#   redirect on a different port on the same machine.
#   Default: $domains[0] (first value of the domains parameter)
#
# [*to_https*]
#   True to force a SSL secure connection between the proxy and the remote
#   vhost.
#   Default: false
#
# [*to_port*]
#   TCP port to use for reaching the remote vhost.
#   Default (to_https = true): 443
#   Default (to_https = false): 80
#
# [*domains*]
#   See the parameter definition with vhost::basic/domains.
#   Default: [ 'localhost' ]
#
# [*enable*]
#   See the parameter definition with vhost::basic/enable.
#   Default: true
#
# [*ipv6*]
#   See the parameter definition with vhost::basic/ipv6.
#   Default: false
#
# [*ipv4*]
#   See the parameter definition with vhost::basic/ipv4.
#   Default: false
#
# [*ipv6only*]
#   See the parameter definition with vhost::basic/ipv6only.
#   Default: false
#
# [*ipv4only*]
#   See the parameter definition with vhost::basic/ipv4only.
#   Default: false
#
# [*https*]
#   See the parameter definition with vhost::basic/https.
#   Default: false
#
# [*ssl_cert_source*]
#   See the parameter definition with vhost::basic/ssl_cert_source.
#   Default: false
#
# [*ssl_cert_content*]
#   See the parameter definition with vhost::basic/ssl_cert_content.
#   Default: false
#
# [*ssl_key_source*]
#   See the parameter definition with vhost::basic/ssl_key_source.
#   Default: false
#
# [*ssl_key_content*]
#   See the parameter definition with vhost::basic/ssl_key_content.
#   Default: false
#
# [*upload_max_size*]
#   See the parameter definition with vhost::basic/upload_max_size.
#   Default: 100M
#
# [*port*]
#   See the parameter definition with vhost::basic/port.
#   Default (https = false): 80
#   Default (https = true): 443
#
# [*add_config_source*]
#   See the parameter definition with vhost::basic/add_config_source.
#   Default: false
#
# [*add_config_content*]
#   See the parameter definition with vhost::basic/add_config_content.
#   Default: false
#
# === Examples
#
#   nginxpack::vhost::proxy { 'blog':
#     domains   => [ 'blog.example.com' ],
#     to_domain => 'blog.lan',
#     to_https  => true,
#   }
#
#   nginxpack::vhost::proxy { 'panel':
#     domains => [ 'panel.example.com' ],
#     to_port => 8080,
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
  $ipv6only           = false,
  $ipv4only           = false,
  $port               = -1,
  $upload_max_size    = '10M',
  $add_config_source  = false,
  $add_config_content = false
) {

  if ($ssl_cert_source or $ssl_key_source or $ssl_cert_content
    or $ssl_key_content) and !$https {

    fail('Use a certificate without enable https does not make sense.')
  }

  if $https and ((!$ssl_cert_source and !$ssl_cert_content)
    or (!$ssl_key_source and !$ssl_key_content)) {

    fail('To have a https connection, please define a cert_pem AND a cert_key.')
  }

  if $ipv6only and $ipv4only {
    fail('Using ipv6only with ipv4only does not make sens.')
  }

  if $ipv4 and $ipv4 != '' and $ipv6only {
    warning('Defining an IPv4 with ipv6only true is pretty strange.')
  }

  if !defined_with_params(File['/etc/nginx/sites-enabled/default_https'], {
    'ensure' => 'link',
  }) and $https and !$ipv6only and $ipv4 and $ipv4 != '' {
    warning('With a specific IPv4 and https, if this address is used on')
    warning('several vhosts, you should define ssl_default_* (no SNI support).')
    warning('See Def. Vhosts: http://github.com/jvaubourg/puppetlabs-nginxpack')
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
