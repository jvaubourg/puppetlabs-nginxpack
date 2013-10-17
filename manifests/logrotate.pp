# == Class: nginxpack::logrotate
#
# Install and configure logrotate for nginx.
#
# Should be used via the main nginxpack class.
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
class nginxpack::logrotate {
  package { [ 'logrotate', 'psmisc' ]:
    ensure => installed,
  }

  file { '/etc/logrotate.d/nginx':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/nginxpack/logrotate/logrotate',
    require => [
      Package['nginx'],
      File['/var/log/nginx/'],
      Package['logrotate'],
      Package['psmisc'],
    ],
  }
}
