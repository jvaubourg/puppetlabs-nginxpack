# == Class: nginxpack::php::cgi
#
# Install PHP5-FPM or classical PHP5-FastCGI.
#
# Should be used through the main nginxpack class.
#
# More explanations: https://forge.puppetlabs.com/jvaubourg/nginxpack
# Sources: https://github.com/jvaubourg/puppetlabs-nginxpack
#
# === Parameters
#
# [*enable*]
#   False to be sure that PHP CGI is uninstalled.
#   Default: true
#
# [*fpm*]
#   False if you want to use classical PHP5-FastCGI instead of PHP5-FPM.
#   FPM seems have better performance.
#   See: http://php-fpm.org
#   Default: true
#
# [*mysql*]
#   True to have a PHP-MySQL connector available.
#   Default: false
#
# [*timezone*]
#   Define the default timezone for PHP.
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
#     upload_max_filesize => '100M',
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
class nginxpack::php::cgi (
  $enable              = true,
  $fpm                 = true,
  $mysql               = false,
  $timezone            = 'Europe/Paris',
  $upload_max_filesize = '10M',
  $upload_max_files    = '10'
) {

  if !$enable and ($mysql or $timezone != 'Europe/Paris'
    or $upload_max_filesize != '10M' or $upload_max_files != '10') {

    warning('You use PHP options without enabling PHP.')
  }

  if $enable {
    file { [ '/var/local/run/' ]:
      ensure  => directory,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
    }

    if $fpm {

      package { [ 'php5-fpm' ]:
        ensure  => present,
      }

      file { '/var/local/run/php.sock':
        ensure => link,
        force  => true,
        target => '/var/run/php5-fpm.sock',
      }

      service { 'php5-fpm':
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
      }

      $php_package = 'php5-fpm'
      $php_service = 'php5-fpm'
      $php_confdir = 'fpm'

    } else {

      package { [ 'php5-cgi', 'spawn-fcgi' ]:
        ensure  => present,
        require => Package['nginx'],
      }
  
      Package['php5-cgi'] -> Package['spawn-fcgi']

      file { '/var/local/run/php.sock':
        ensure => link,
        force  => true,
        target => '/var/run/php-fastcgi/php-fastcgi.socket',
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

      service { 'php-fastcgi':
        ensure     => running,
        enable     => true,
        hasrestart => false,
        hasstatus  => false,
        pattern    => 'php5-cgi',
        require    => File['/etc/init.d/php-fastcgi'],
      }

      $php_package = 'php5-cgi'
      $php_service = 'php-fastcgi'
      $php_confdir = 'cgi'
    }

    file_line { 'php.ini-upload_max_filesize':
      path    => "/etc/php5/${php_confdir}/php.ini",
      match   => 'upload_max_filesize',
      line    => "upload_max_filesize = ${upload_max_filesize}",
      require => Package[$php_package],
      notify  => Service[$php_service],
    }

    file_line { 'php.ini-max_file_uploads':
      path    => "/etc/php5/${php_confdir}/php.ini",
      match   => 'max_file_uploads',
      line    => "max_file_uploads = ${upload_max_files}",
      require => Package[$php_package],
      notify  => Service[$php_service],
    }

    file_line { 'php.ini-post_max_size':
      path    => "/etc/php5/${php_confdir}/php.ini",
      match   => 'post_max_size',
      line    => inline_template('post_max_size = <%= \
        (@upload_max_files.to_i * @upload_max_filesize[0..-2].to_i).to_s\
        + @upload_max_filesize[-1] %>'),
      require => Package[$php_package],
      notify  => Service[$php_service],
    }

    file { "/etc/php5/${php_confdir}/conf.d/timezone.ini":
      ensure  => file,
      mode    => '0644',
      content => "date.timezone = '${timezone}'",
      require => Package[$php_package],
      notify  => Service[$php_service],
    }

    if $mysql {
      package { 'php5-mysql':
        ensure  => present,
        require => Package[$php_package],
      }
    } else {
      package { 'php5-mysql':
        ensure => absent,
      }
    }

  } else {

    if $fpm {

      package { [ 'php5-fpm', 'php5-mysql' ]:
        ensure => absent,
      }

      Package['php5-mysql'] -> Package['php5-fpm']

    } else {

      package { [ 'php5-mysql', 'php5-cgi', 'spawn-fcgi' ]:
        ensure => absent,
      }
  
      Package['spawn-fcgi'] -> Package['php5-mysql'] -> Package['php5-cgi']
  
      ensure_packages([ 'psmisc' ])
  
      file { '/usr/bin/php-fastcgi.sh':
        ensure => absent,
      }
  
      file { '/etc/init.d/php-fastcgi':
        ensure => absent,
        notify => [
          Exec['kill-php-fastcgi'],
          Exec['remove-php-service']
        ],
      }
  
      exec { 'kill-php-fastcgi':
        command     => '/usr/bin/killall php5-cgi',
        onlyif      => '/bin/ps aux | /bin/grep -q php5-cgi',
        refreshonly => true,
        require     => Package['psmisc'],
      }
  
      exec { 'remove-php-service':
        command     => '/usr/sbin/update-rc.d php-fastcgi remove',
        refreshonly => true,
      }
    }
  }
}
