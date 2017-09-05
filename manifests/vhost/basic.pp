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
#   IPv6 address for accessing to this website. Use false to listen on all
#   available IPv6 addresses (except if ipv6only is true).
#   Default: false
#
# [*ipv4*]
#   IPv4 address for accessing to this website. Use false to listen on all
#   available IPv4 addresses (except if ipv6only is true).
#   Default: false
#
# [*ipv6only*]
#   True to disable IPv4 listening. Incompatible with ipv4only.
#   Default: false
#
# [*ipv4only*]
#   True to disable IPv6 listening. Incompatible with ipv6only.
#   Please use it only when strictly necessary!
#   Default: false
#
# [*https*]
#   True to force a SSL secure connection for this website. If true then
#   defining a cert and key with the following parameters is mandatory.
#   Default: false
#
# [*ssl_cert_source*]
#   See the parameter definition with ssl::certificate/ssl_cert_source.
#   Default: false
#
# [*ssl_cert_content*]
#   See the parameter definition with ssl::certificate/ssl_cert_content.
#   Default: false
#
# [*ssl_key_source*]
#   See the parameter definition with ssl::certificate/ssl_key_source.
#   Default: false
#
# [*ssl_key_content*]
#   See the parameter definition with ssl::certificate/ssl_key_content.
#   Default: false
#
# [*ssl_dhparam_source*]
#   See the parameter definition with ssl::certificate/ssl_dhparam_source.
#   Default: false
#
# [*ssl_dhparam_content*]
#   See the parameter definition with ssl::certificate/ssl_dhparam_content.
#   Default: false
#
# [*ssl_ocsp_dns1*]
#   DNS resolver for obtaining the IP address of the OCSP responder. Use IP
#   address or name. IPv6 address is supported starting from nginx 1.2.2
#   and resolving IPv6 address is supported starting from nginx 1.5.8.
#   An optional port can be set with IP:port or name:port, starting from
#   nginx 1.2.2. If false, system dns will be used.
#   Default: false
#
# [*ssl_ocsp_dns2*]
#   See the parameter definition with ssl_ocsp_dns1.
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
# [*html_index*]
#   HTML file to use as default index.
#   Default: index.html
#
# [*use_php*]
#   True if you to want use php-fpm (FastCGI) with this vhost. nginxphp must be
#   called previously with enable_php=true. Legacy CGI (below) cannot be
#   enabled at the same time.
#   Default: false
#
# [*php_index*]
#   PHP file to use as default index.
#   Default: index.php
#
# [*php_acceptpathinfo*]
#   True if you to want activate AcceptPathInfo with PHP.
#   See: https://httpd.apache.org/docs/2.2/mod/core.html#AcceptPathInfo
#   Default: false
#
# [*use_legacycgi*]
#   True if you to want use legacy CGI (thanks to a FastCGI wrapping) with this
#   vhost. nginxphp must be called previously with enable_legacycgi=true. PHP
#   (above) cannot be enabled at the same time.
#   Default: false
#
# [*legacycgi_path*]
#   Absolute web path of the cgi-bin directory (e.g. /mailman).
#   Default: /cgi-bin
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
# [*htpasswd_msg*]
#   Set http authentication message.
#   Default: "Restricted"
#
# [*forbidden*]
#   Array of regexps corresponding to forbidden urls. If your vhost targets
#   /var/www/myvhost/ and that your logs directory is /var/www/myvhost/logs
#   you should use forbidden => [ '^/logs/' ].
#   Default: false
#
# [*files_dir*]
#   Location of the website content. Directories will be created if it do not
#   already exist.
#   Default: /var/www/<name>/
#
# [*try_files*]
#   Additional default try_files in the location / (e.g. tryfiles => '@foobar',
#   with a location "@foobar" defined in add_config_* for use in last resort).
#   Default: =404
#
# [*listing*]
#   True if you want to enable files auto indexing (directory index).
#   Default: false
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
  $domains             = [ 'localhost' ],
  $enable              = true,
  $ipv6                = false,
  $ipv4                = false,
  $ipv6only            = false,
  $ipv4only            = false,
  $https               = false,
  $ssl_cert_source     = false,
  $ssl_key_source      = false,
  $ssl_dhparam_source  = false,
  $ssl_cert_content    = false,
  $ssl_key_content     = false,
  $ssl_dhparam_content = false,
  $ssl_ocsp_dns1       = false,
  $ssl_ocsp_dns2       = false,
  $port                = -1,
  $upload_max_size     = '100M',
  $injectionsafe       = false,
  $html_index          = 'index.html',
  $use_php             = false,
  $php_index           = 'index.php',
  $php_acceptpathinfo  = false,
  $use_legacycgi       = false,
  $legacycgi_path      = '/cgi-bin',
  $add_config_source   = false,
  $add_config_content  = false,
  $htpasswd            = false,
  $htpasswd_msg        = 'Restricted',
  $forbidden           = false,
  $files_dir           = "/var/www/${name}/",
  $try_files           = '=404',
  $listing             = false,
  $handlelocation      = true
) {
  if ($html_index != 'index.html' or $try_files != '=404' or $listing)
    and !$handlelocation {

    fail('Using html_index/try_files/listing with handlelocation disabled has no effect.')
  }

  if ($ssl_cert_source or $ssl_key_source or $ssl_cert_content
    or $ssl_key_content) and !$https {

    fail('Using a certificate without enabling https does not make sense.')
  }

  if ($ssl_dhparam_source or $ssl_dhparam_content) and !$https {
    fail('Using a dhparam file without enabling https does not make sense.')
  }

  if $https and ((!$ssl_cert_source and !$ssl_cert_content)
    or (!$ssl_key_source and !$ssl_key_content)) {

    fail('To have a https connection, please define a cert_pem AND a cert_key.')
  }

  if ($ssl_ocsp_dns1 or $ssl_ocsp_dns2) and !$https {
    fail('Using OCSP DNS resolvers without enabling https does not make sense.')
  }

  if $ipv6only and $ipv4only {
    fail('Using ipv6only with ipv4only does not make sens.')
  }

  if $ipv4 and $ipv4 != '' and $ipv6only {
    fail('Defining an IPv4 with ipv6only true is not consistent.')
  }

  if $ipv6 and $ipv6 != '' and $ipv4only {
    fail('Defining an IPv6 with ipv4only true is not consistent.')
  }

  if $php_acceptpathinfo and !$use_php {
    warning('AcceptPathInfo activated makes no sense when PHP is not used.')
  }

  if $php_index != 'index.php' and !$use_php {
    warning('Using a PHP index makes no sense when PHP is not used.')
  }

  if $add_config_source and $add_config_content {
    fail('Please, use source/content method to define add_config, but not both.')
  }

  if $htpasswd_msg != 'Restricted' and !$htpasswd {
    fail('You need to use htpasswd with htpasswd_msg.')
  }

  if $legacycgi_path and !$use_legacycgi {
    warning('Legacy CGI Path set makes no sense when legacy CGI is not used.')
  }

  if $use_php and $use_legacycgi {
    fail('PHP and legacy CGI cannot be enabled at the same time.')
  }

  if $use_php {
    notice('Using PHP in at least 1 vhost implies to use init with enable_php set.')
    notice('Fix this if necessary, or ignore this notice.')
  }

  if $use_legacycgi {
    notice('Using legacy CGI in at least 1 vhost implies to use init with enable_legacycgi set.')
    notice('Fix this if necessary, or ignore this notice.')
  }

  if $port == -1 {
    $portval = $https ? { true => 443, false => 80 }
  } else {
    $portval = $port
  }

  if $https {
    nginxpack::ssl::certificate { $name:
      ssl_cert_source     => $ssl_cert_source,
      ssl_key_source      => $ssl_key_source,
      ssl_dhparam_source  => $ssl_dhparam_source,
      ssl_cert_content    => $ssl_cert_content,
      ssl_key_content     => $ssl_key_content,
      ssl_dhparam_content => $ssl_dhparam_content,
    }
  }

  file { "/etc/nginx/sites-available/${name}":
    ensure  => file,
    mode    => '0644',
    content => template('nginxpack/nginx/vhost.erb'),
    require => [
      Package['nginx'],
      Exec["${name}_mkdir_${files_dir}"],
      File["/var/log/nginx/${name}/"],
    ],
    notify  => [
      Exec['find_default_listen'],
      Service['nginx'],
    ],
  }

  exec { "${name}_mkdir_${files_dir}":
    command => "/bin/mkdir -p ${files_dir}",
    unless  => "/usr/bin/test -d ${files_dir}",
  }

  file { "/var/log/nginx/${name}/":
    ensure => directory,
    mode   => '0770',
    owner  => 'root',
    group  => 'root',
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
      notify => Service['nginx'],
    }
  }

  if $add_config_content {
    file { "/etc/nginx/include/${name}.conf":
      ensure  => file,
      mode    => '0644',
      content => $add_config_content,
      notify  => Service['nginx'],
    }
  }
}
