# == Define: nginxpack::vhost::redirection
#
# Not seamlessly web redirection, returning a 301
# (Moved Permanently) HTTP code.
#
# More explanations: https://forge.puppetlabs.com/jvaubourg/nginxpack
# Sources: https://github.com/jvaubourg/puppetlabs-nginxpack
#
# === Parameters
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
# [*port*]
#   See the parameter definition with vhost::basic/port.
#   Default: 80
#
# [*to_domain*]
#   See the parameter definition with vhost::proxy/to_domain.
#   Default: $domains[0] (first value of the domains parameter)
#
# [*to_https*]
#   See the parameter definition with vhost::proxy/to_https.
#   Default: false
#
# [*to_port*]
#   See the parameter definition with vhost::proxy/to_port.
#   Default (to_https=true): 443
#   Default (to_https=false): 80
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
define nginxpack::vhost::redirection (
  $domains            = [ 'localhost' ],
  $ipv6               = false,
  $ipv4               = false,
  $port               = 80,
  $to_domain          = -1,
  $to_port            = -1,
  $to_https           = false,
  $enable             = true,
  $add_config_source  = false,
  $add_config_content = false
) {

  if $add_config_source and $add_config_content {
    fail('Use source/content method to define add_config but not the both.')
  }

  $portval = $port

  if $to_port == -1 {
    $to_portval = $to_https ? { true => 443, false => 80 }
  } else {
    $to_portval = $to_port
  }

  if $to_domain == -1 {
    $to_domainval = $domains[0]
  } else {
    $to_domainval = $to_domain
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
    file { "/etc/nginx/include/${name}_redirection.conf":
      ensure => file,
      mode   => '0644',
      source => $add_config_source,
    }
  }

  if $add_config_content {
    file { "/etc/nginx/include/${name}_redirection.conf":
      ensure  => file,
      mode    => '0644',
      content => $add_config_content,
    }
  }
}
