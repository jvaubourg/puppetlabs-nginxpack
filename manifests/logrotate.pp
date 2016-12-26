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
# [*frequency*]
#   The log rotation frequency, should be daily, weekly or monthly.
#   hourly - Log  files  are  rotated every hour.
#     Note that usually logrotate is configured to be run by cron daily.
#     You have to change this configuration and run logrotate hourly to
#     be able to really rotate logs hourly.
#   daily - Log files are rotated every day
#   weekly - Log files are rotated if the current weekday is less than
#     the weekday of the last rotation or if more than a week has passed
#     since the last rotation.
#     This is normally the same as rotating logs on the first day of
#     the week, but it works better if logrotate is not run every night.
#   monthly - Log files are rotated the first time logrotate is run
#     in a month (this is normally on the first day of the month).
#   yearly - Log files are rotated if the current year is not the same
#     as the last rotation.
#   Default: weekly
#
# [*rotate*]
#   Log files are rotated $rotate times before being removed or mailed
#   to the address specified in a mail directive.
#   If $rotate is 0, old versions are removed rather than rotated.
#   Be aware that due to some legals constraints you must to keep
#   HTTP logs during one year.
#   Default: 52
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
  $enable    = true,
  $frequency = 'weekly',
  $rotate    = 52,
) {

  if $enable {

    validate_re("$frequency", '^(hourly|daily|weekly|monthly|yearly)$',
      "${frequency} is not supported for frequency. Allowed values are 'hourly', 'daily', 'weekly', 'monthly' or 'yearly'.")
    validate_re("$rotate", '^\d+$', 'rotate is not a valid number')

    ensure_packages([ 'logrotate', 'psmisc' ])

    file { '/etc/logrotate.d/nginx':
      ensure  => file,
      mode    => '0644',
      content => template('nginxpack/logrotate/logrotate.erb'),
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
