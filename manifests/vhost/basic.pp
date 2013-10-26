# == Define: nginxpack::vhost::basic
#
# Standard vhost (website).
#
# More explanations: https://forge.puppetlabs.com/jvaubourg/nginxpack
# Sources: https://github.com/jvaubourg/puppetlabs-nginxpack
#
# === Parameters
#
# [*domains*]
#   Array of domains (FQDN) with which the website can be accessed.
#   Default: [ 'localhost' ]
#
# [*enable*]
#   False to have this website unavailable.
#   Default: true
#
# [*ipv6*]
#   IPv6 address usable to access to this website. Use false to disable ipv6
#   (but please never use this possibily). Use :: to listen on all available
#   IPv6 addresses. If IPv6 and IPv4 are false, Nginx will listen on all
#   available IP on the server (default behavior).
#   Default: false
#
# [*ipv4*]
#   IPv4 address usable to access to this website. Use false or to disable IPv4
#   (real _wo_men do that!). Use 0.0.0.0 to listen on all available IPv4
#   addresses. If IPv6 and IPv4 are false, Nginx will listen on all available
#   IP on the server (default behavior).
#   Default: false
#
# [*https*]
#   True to force a SSL secure connection for this website. If true then
#   defining a cert and key with the following parameters is mandatory.
#   Default: false
#
# [*ssl_cert_source*]
#   Location of the SSL certificate file (pem or crt). If not false then the
#   https parameter must be true and the next one must be false.
#   Default: false
#
# [*ssl_cert_content*]
#   SSL certificate directly from a string (or through hiera). If not false then
#   the https parameter must be true and the previous one must be false.
#   Default: false
#
# [*ssl_key_source*]
#   Location of the SSL key certificate file. If not false then the https
#   parameter must be true and the next one must be false.
#   Default: false
#
# [*ssl_key_content*]
#   SSL key certificate directly from a string (or through hiera). If not false
#   then the https parameter must be true and the previous one must be false.
#   Default: false
#
# [*port*]
#   TCP port available to access to this website.
#   Default (https = false): 80
#   Default (https = true): 443
#
# [*upload_max_size*]
#   Maximum size of a POST upload. If PHP was enabled in your nginxpack main
#   class call, it should be in line with:
#     (php_upload_max_filesize * php_upload_max_files).
#   Default: 100M
#
# [*injectionsafe*]
#   Apply a set of URL protections to avoid XSS injections. These restrictions
#   might be incompatible with your applications.
#   See http://www.howtoforge.com/nginx-how-to-block-exploits-sql-injections
#      -file-injections-spam-user-agents-etc
#   Default: false
#
# [*use_php*]
#   True if you to want use php-cgi with this vhost. nginxphp must be called
#   previously with enable_php=true.
#   Default: false
#
# [*add_config_source*]
#   Config files are generated from Puppet but you could need to add specific
#   rules in your vhost definition. The content of the file targeted will be
#   added at the end of it, inside the server block. If not false then the next
#   parameter must be false.
#   Default: false
#
# [*add_config_content*]
#   Set the custom additional config directly from a string. If not false then
#   the previous parameter must be false.
#   Default: false
#
# [*htpasswd*]
#   Set a http authentication to your whole website by providing a couple of
#   user/password. The couple should be in htpasswd format (apache2-utils):
#     $ htpasswd -nb user1 secretpassword
#   Default: false
#
# [*files_dir*]
#   Location of the website content. Directories will be created if it do not
#   already exist.
#   Default: /var/www/<name>/
#
# === Examples
#
#   nginxpack::vhost::basic { 'blog':
#     domains       => [ 'blog.example.com' ],
#     use_php       => true,
#     injectionsafe => true,
#   }
#
#   nginxpack::vhost::basic { 'wiki':
#     domains         => [ 'wiki.example.com' ],
#     use_php         => true,
#     upload_max_size => '1G',
#     https           => true,
#     ssl_cert_source => 'puppet:///certificates/wiki.pem',
#     ssl_key_source  => 'puppet:///certificates/wiki.key',
#     ipv6            => '2001:db8::42',
#   }
#
#   nginxpack::vhost::basic { 'admin':
#     domains  => [ 'panel-admin.example.com' ],
#     htpasswd => 'adm:$apr1$Z6nIVYSV$VlErmzL53l0sFbbi2NPuQ/',
#     ipv4     => false,
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
define nginxpack::vhost::basic (
  $domains            = [ 'localhost' ],
  $enable             = true,
  $ipv6               = false,
  $ipv4               = false,
  $https              = false,
  $ssl_cert_source    = false,
  $ssl_key_source     = false,
  $ssl_cert_content   = false,
  $ssl_key_content    = false,
  $port               = -1,
  $upload_max_size    = '100M',
  $injectionsafe      = false,
  $use_php            = false,
  $add_config_source  = false,
  $add_config_content = false,
  $htpasswd           = false,
  $files_dir          = "/var/www/${name}/"
) {

  if ($ssl_cert_source or $ssl_key_source or $ssl_cert_content
    or $ssl_key_content) and !$https {

    fail('Use a certificate without enable https does not make sense.')
  }

  if $https and ((!$ssl_cert_source and !$ssl_cert_content)
    or (!$ssl_key_source and !$ssl_key_content)) {

    fail('To have a https connection, please define a cert_pem AND a cert_key.')
  }

  if !defined_with_params(File['/etc/nginx/sites-enabled/default_https'], {
    'ensure' => 'link',
  }) and $https and ($ipv4 or (!$ipv4 and !$ipv6)) and $ipv4 != '' {
    warning('With IPv4 listening and https, you should define ssl_default_*.')
    warning('See Def. Vhosts: http://github.com/jvaubourg/puppetlabs-nginxpack')
  }

  if $add_config_source and $add_config_content {
    fail('Use source/content method to define add_config but not the both.')
  }

  if !defined_with_params(File['/etc/init.d/php-fastcgi'], {
    'ensure' => 'file',
  }) and $use_php {
    warning('Nginxpack class seems not to have been called with enable_php.')
  }

  if $port == -1 {
    $portval = $https ? { true => 443, false => 80 }
  } else {
    $portval = $port
  }

  if $https {
    nginxpack::ssl::certificate { $name:
      ssl_cert_source  => $ssl_cert_source,
      ssl_key_source   => $ssl_key_source,
      ssl_cert_content => $ssl_cert_content,
      ssl_key_content  => $ssl_key_content,
    }
  }

  file { "/etc/nginx/sites-available/${name}":
    ensure  => file,
    mode    => '0644',
    content => template('nginxpack/nginx/vhost.erb'),
    require => [
      Package['nginx'],
      Exec["mkdir_${files_dir}"],
      File["/var/log/nginx/${name}/"],
    ],
    notify  => [
      Exec['find_default_listen'],
      Service['nginx'],
    ],
  }

  exec { "mkdir_${files_dir}":
    command => "/bin/mkdir -p ${files_dir}",
    unless  => "/usr/bin/test -d ${files_dir}",
  }

  file { "/var/log/nginx/${name}/":
    ensure => directory,
    mode   => '0770',
    owner  => 'www-data',
    group  => 'www-data',
  }

  if $htpasswd {
    file { "/etc/nginx/htpasswd/${name}":
      ensure  => file,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0440',
      content => $htpasswd,
    }
  } else {
    file { "/etc/nginx/htpasswd/${name}":
      ensure => absent,
    }
  }

  $ensure_enable = $enable ? {
    true  => link,
    false => absent,
  }

  file { "/etc/nginx/sites-enabled/${name}":
    ensure  => $ensure_enable,
    target  => "/etc/nginx/sites-available/${name}",
    require => File["/etc/nginx/sites-available/${name}"],
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
