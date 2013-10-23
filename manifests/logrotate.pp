# == Class: nginxpack::logrotate
#
# Install and configure logrotate for Nginx (daily rotate vhosts logs).
#
# Should be used through the main nginxpack class.
#
# More explanations: https://forge.puppetlabs.com/jvaubourg/nginxpack
# Sources: https://github.com/jvaubourg/puppetlabs-nginxpack
#
# === Parameters
#
# [*enable*]
#   False to be sure that the logrotate rules for Nginx are removed. Please note
#   that logrotate and psmisc packages will not are automatically uninstalled
#   due to possible conflicts.
#   Default: true
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
