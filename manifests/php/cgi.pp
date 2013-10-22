# == Class: nginxpack::php::cgi
#
# Install php5 in cgi mode with a dedicated service.
#
# Should be used via the main nginxpack class.
#
# === Parameters
#
# [*enable*]
#   False to be sure that php-cgi is uninstalled.
#   Default: true
#
# [*mysql*]
#   True if you want to use a mysql with php5.
#   Default: false
#
# [*timezone*]
#   Define the default timezone for php.
#   Default: Europe/Paris
#
# [*upload_max_filesize*]
#   Define the max upload filesize in MB.
#   Default: 10M
#
# [*upload_max_files*]
#   Define the max number of files that can be sent in the same upload.
#   Default: 10
#
# === Examples
#
#   class { 'nginxpack::php::cgi':
#     mysql               => true,
#     upload_max_filesize => '100M'
#   }
#
# === Authors
#
# Julien Vaubourg <http://http://julien.vaubourg.com>
#
# === Copyright
#
# Copyleft 2013 Julien Vaubourg
# Consider this file under AGPL
#
class nginxpack::php::cgi (
  $enable              = true,
  $mysql               = false,
  $timezone            = 'Europe/Paris',
  $upload_max_filesize = '10M',
  $upload_max_files    = '10'
) {

  if $enable {
    package { [ 'php5-cgi', 'spawn-fcgi' ]:
      ensure  => present,
      require => Package['nginx'],
    }

    Package['php5-cgi'] -> Package['spawn-fcgi']

    service { 'php-fastcgi':
      ensure     => running,
      enable     => true,
      hasrestart => false,
      hasstatus  => false,
      pattern    => 'php5-cgi',
      require    => File['/etc/init.d/php-fastcgi'],
    }

    file_line { 'php.ini-upload_max_filesize':
      path    => '/etc/php5/cgi/php.ini',
      match   => 'upload_max_filesize',
      line    => "upload_max_filesize = ${upload_max_filesize}",
      require => Package['php5-cgi'],
      notify  => Service['php-fastcgi'],
    }

    file_line { 'php.ini-max_file_uploads':
      path    => '/etc/php5/cgi/php.ini',
      match   => 'max_file_uploads',
      line    => "max_file_uploads = ${upload_max_files}",
      require => Package['php5-cgi'],
      notify  => Service['php-fastcgi'],
    }

    file_line { 'php.ini-post_max_size':
      path    => '/etc/php5/cgi/php.ini',
      match   => 'post_max_size',
      line    => inline_template('post_max_size = <%= \
        (upload_max_files.to_i * upload_max_filesize[0..-2].to_i).to_s\
        + upload_max_filesize[-1] %>'),
      require => Package['php5-cgi'],
      notify  => Service['php-fastcgi'],
    }

    file { '/etc/php5/cgi/conf.d/timezone.ini':
      ensure  => file,
      mode    => '0644',
      content => "date.timezone = '${timezone}'",
      require => Package['php5-cgi'],
      notify  => Service['php-fastcgi'],
    }

    file { '/usr/bin/php-fastcgi.sh':
      ensure  => file,
      mode    => '0755',
      source  => 'puppet:///modules/nginxpack/php/php-fastcgi.sh',
      require => Package['spawn-fcgi'],
      notify  => Service['php-fastcgi'],
    }

    file { '/etc/init.d/php-fastcgi':
      ensure  => file,
      mode    => '0755',
      source  => 'puppet:///modules/nginxpack/php/php-fastcgi',
      require => File['/usr/bin/php-fastcgi.sh'],
      notify  => Service['php-fastcgi'],
    }

    if $mysql {
      package { 'php5-mysql':
        ensure  => present,
        require => Package['php5-cgi'],
      }
    } else {
      package { 'php5-mysql':
        ensure => absent,
      }
    }

  } else {

    package { [ 'php5-mysql', 'php5-cgi', 'spawn-fcgi' ]:
      ensure  => absent,
    }

    Package['spawn-fcgi'] -> Package['php5-mysql'] -> Package['php5-cgi']

    file { [ '/usr/bin/php-fastcgi.sh', '/etc/init.d/php-fastcgi' ]:
      ensure => absent,
    }

    service { 'php-fastcgi':
      ensure => 'stopped',
      enable => false,
      before => File['/etc/init.d/php-fastcgi'],
    }
  }
}
