# == Define: nginxpack::vhost::basic
#
# Define a classic nginx vhost (website).
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
#   Ipv6 address usable to access to this website. Use false to disable ipv6 but
#   please never use this possibily! Use :: to listen on all available ipv6
#   addresses. If ipv6 and ipv4 are false, nginx will listen on all ip available
#   on the server (default).
#   Default: false
#
# [*ipv4*]
#   Ipv4 address usable to access to this website. Use false or to disable ipv4
#   (the strong _wo_men do that!). Use 0.0.0.0 to listen on all available ipv4
#   addresses. If ipv6 and ipv4 are both false, nginx will listen on all ip
#   available on the server (default).
#   Default: false
#
# [*https*]
#   True if you want to use a ssl secure connection for this website. You need
#   have a certificat corresponding to the domains for that. Please use https
#   each time you have a login process inside your pages.
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
# [*port*]
#   Define the tcp port available to access to this website.
#   Default (https = false): 80
#   Default (https = true): 443
#
# [*upload_max_size*]
#   Define the maximum size of an upload with postdata. If php was enabled in
#   your nginxpack call, you should set this option with the value of
#   (php_upload_max_filesize * php_upload_max_files).
#   Default: 100M
#
# [*injectionsafe*]
#   If true, apply a set of url protections to avoid sql injections and others
#   kind of attacks. WARNING: In some cases, these protections may cause
#   problem with your web applications. Rules are from:
#   http://www.howtoforge.com/nginx-how-to-block-exploits-sql-injections
#      -file-injections-spam-user-agents-etc
#   Default: false
#
# [*use_php*]
#   True if you to want use php-cgi with this vhost. nginxphp must be called
#   previously with enable_php=true.
#   Default: false
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
# [*htpasswd*]
#   Give a couple of user:password in htpasswd format with this option to add a
#   classical httpd authentication (couple can be generated with apache-utils:
#   /usr/bin/htpasswd -nb username password).
#   Default: false
#
# [*files_dir*]
#   Directory to create for the website files.
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
# === Authors
#
# Julien Vaubourg <http://julien.vaubourg.com>
#
# === Copyright
#
# Copyleft 2013 Julien Vaubourg
# Consider this file under AGPL
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

  if $add_config_source and $add_config_content {
    fail('Use source/content method to define add_config but not the both.')
  }

  if $use_php and !defined(File['/etc/init.d/php-fastcgi']) {
    warning("Nginxpack class seems not to have been called with enable_php.")
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
      Exec['mkdir_files_dir'],
      File["/var/log/nginx/${name}/"],
    ],
    notify  => [
      Exec['find_default_listen'],
      Service['nginx'],
    ],
  }

  exec { 'mkdir_files_dir':
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
