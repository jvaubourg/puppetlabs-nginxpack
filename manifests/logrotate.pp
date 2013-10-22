# == Class: nginxpack::logrotate
#
# Install and configure logrotate for nginx.
#
# Should be used via the main nginxpack class.
#
# === Parameters
#
# [*enable*]
#   False to be sure that the logrotate rules for nginx are removed. Please note
#   that logrotate and psmisc packages will not are automatically uninstalled
#   due to possible conflicts.
#   Default: true
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
class nginxpack::logrotate (
  $enable = true,
) {

  if $enable {
    ensure_packages([ 'logrotate', 'psmisc' ])

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

  } else {

    file { '/etc/logrotate.d/nginx':
      ensure => absent,
    }
  }
}
